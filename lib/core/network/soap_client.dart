// core/network/soap_client.dart
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// کلاس SoapClient با لاگ‌گیری کامل ورودی و خروجی
class SoapClient {
  final String baseUrl;
  final http.Client httpClient;
  final bool debugMode;

  static const int _maxLogHistory = 100;

  SoapClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.debugMode = true,
  }) : httpClient = httpClient ?? http.Client();
//..................................................................................
  /// ارسال درخواست SOAP با لاگ‌گیری کامل
  Future<xml.XmlDocument> call({
    required String method,
    required Map<String, String> parameters,
    String? namespace,
    String? soapAction,
  }) async {
    final startTime = DateTime.now();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    Stopwatch? stopwatch;

    // 1. لاگ ورودی (درخواست ارسالی به سرور)
    try {
      // ساخت SOAP Envelope
      final soapEnvelope = _buildSoapEnvelope(
        method: method,
        parameters: parameters,
        namespace: namespace ?? 'http://tempuri.org/',
      );

      print("parameters_envelope_ = $parameters");

      if (debugMode) {
        developer.log( 'SOAP Request Envelope:\n$soapEnvelope',
          name: 'SoapClient', level: 800,  );
      }

      // تنظیم هدرها
      final headers = {
        'Content-Type': 'text/xml; charset=utf-8',
        'User-Agent': 'Flutter SOAP Client/1.0',
        if (soapAction != null) 'SOAPAction': '"$soapAction"',
      };

      // 2. ارسال درخواست
     stopwatch = Stopwatch()..start();
      final response = await httpClient.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: soapEnvelope,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          final duration = stopwatch?.elapsedMilliseconds ?? 0;

          throw SoapException('Connection timeout after 30 seconds');
        },
      );

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;
      final endTime = DateTime.now();

      // 4. پردازش پاسخ
      if (response.statusCode == 200) {
        try {
         final xmlDoc = xml.XmlDocument.parse(response.body);

          // استخراج نتیجه
          final resultTag = '${method}Result';
          final resultValue = extractValue(xmlDoc, resultTag);
          print("SoapClient → Extracted: $resultValue");


          if (debugMode && resultValue != null) {
            print(' Extracted $resultTag:');
            if (resultValue.length > 500) {
              print('${resultValue.substring(0, 500)}...');
            } else {
              print(resultValue);
            }
          }

          return xmlDoc;
        } catch (e) {
          final error = SoapException('XML Parse Error: $e');
          throw error;
        }
      } else if (response.statusCode == 500) {
        final errorMsg = _extractServerError(response.body);
        final error = SoapException('Server Error 500: $errorMsg');
        throw error;
      } else {
        final error = SoapException('HTTP ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) + '...' : response.body}');
        throw error;
      }
    } on http.ClientException catch (e) {
      final duration = stopwatch?.elapsedMilliseconds ?? 0;

      throw SoapException('Connection Error: $e');
    } catch (e, stackTrace) {
      final duration = stopwatch?.elapsedMilliseconds ?? 0;


      rethrow;
    } finally {

    }
  }
//..................................................................................
  /// ساخت SOAP Envelope
  String _buildSoapEnvelope({
    required String method,
    required Map<String, String> parameters,
    required String namespace,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="utf-8"?>');
    buffer.writeln(
      '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
          'xmlns:xsd="http://www.w3.org/2001/XMLSchema" '
          'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
    );
    buffer.writeln('<soap:Body>');
    buffer.writeln('<$method xmlns="$namespace">');

    parameters.forEach((key, value) {
      buffer.writeln('<$key>${_escapeXml(value)}</$key>');
    });

    buffer.writeln('</$method>');
    buffer.writeln('</soap:Body>');
    buffer.writeln('</soap:Envelope>');

    return buffer.toString();
  }
//..................................................................................
  /// فرار از کاراکترهای XML
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
//..................................................................................
  /// استخراج خطا از پاسخ سرور
  String _extractServerError(String body) {
    try {
      final patterns = [
        r'<faultstring[^>]*>(.*?)</faultstring>',
        r'<faultstring>(.*?)</faultstring>',
        r'<Message[^>]*>(.*?)</Message>',
        r'<message[^>]*>(.*?)</message>',
        r'<error[^>]*>(.*?)</error>',
        r'<Error[^>]*>(.*?)</Error>',
      ];

      for (var pattern in patterns) {
        final match = RegExp(pattern, dotAll: true).firstMatch(body);
        if (match != null && match.group(1)?.trim().isNotEmpty == true) {
          return match.group(1)!.trim();
        }
      }

      return body.length > 500
          ? body.substring(0, 500) + '...'
          : body;
    } catch (e) {
      return 'Error extracting error message: $e';
    }
  }
//..................................................................................
  /// استخراج مقدار از XML
  String? extractValue(xml.XmlDocument doc, String tagName) {
    try {
      final elements = doc.findAllElements(tagName);
      if (elements.isNotEmpty) {
        return elements.first.innerText.trim();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
//..................................................................................
  /// تست اتصال
  Future<bool> testConnection() async {
    try {
      final response = await call(
        method: 'GetServerDate',
        parameters: {},
      );
      return extractValue(response, 'GetServerDateResult') != null;
    } catch (e) {
      return false;
    }
  }
//..................................................................................
  /// بستن کلاینت
  void dispose() => httpClient.close();
}

/// استثنای SOAP
class SoapException implements Exception {
  final String message;
  final DateTime timestamp = DateTime.now();

  SoapException(this.message);

  @override
  String toString() => 'SoapException[$timestamp]: $message';
}

//..................................................................................