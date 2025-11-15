import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:developer' as developer;

class SoapClient {
  final String baseUrl;
  final http.Client httpClient;

  SoapClient({required this.baseUrl, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  /// ارسال درخواست SOAP
  Future<xml.XmlDocument> call({
    required String method,
    required Map<String, String> parameters,
    String? namespace,
    String? soapAction,
  }) async {
    final soapEnvelope = _buildSoapEnvelope(
      method: method,
      parameters: parameters,
      namespace: namespace ?? 'http://tempuri.org/',
    );

    developer.log('📤 SOAP Method: $method');
    developer.log('📤 Namespace: ${namespace ?? "http://tempuri.org/"}');
    developer.log('📤 Parameters: $parameters');

    final headers = {
      'Content-Type': 'text/xml; charset=utf-8',
      'User-Agent': 'Flutter SOAP Client',
      if (soapAction != null) 'SOAPAction': '"$soapAction"',
    };

    try {
      final response = await httpClient
          .post(Uri.parse(baseUrl), headers: headers, body: soapEnvelope)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw SoapException('Connection timeout'),
          );

      developer.log('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          return xml.XmlDocument.parse(response.body);
        } catch (e) {
          throw SoapException('خطا در پارس XML: $e');
        }
      } else if (response.statusCode == 500) {
        final errorMsg = _extractServerError(response.body);
        throw SoapException('Server Error 500: $errorMsg');
      } else {
        throw SoapException('HTTP ${response.statusCode}: ${response.body}');
      }
    } on http.ClientException catch (e) {
      throw SoapException('خطا در ارتباط با سرور: $e');
    } catch (e) {
      rethrow;
    }
  }

  /// ساخت Envelope SOAP (سازگار با .NET)
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

  /// Escape XML characters
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// استخراج خطا از response
  String _extractServerError(String body) {
    try {
      final match = RegExp(
        r'<faultstring>(.*?)</faultstring>',
        dotAll: true,
      ).firstMatch(body);
      if (match != null) return match.group(1) ?? body;
      return body.length > 300 ? body.substring(0, 300) : body;
    } catch (e) {
      return body;
    }
  }

  /// استخراج مقدار از XML
  String? extractValue(xml.XmlDocument doc, String tagName) {
    try {
      final elements = doc.findAllElements(tagName);
      if (elements.isNotEmpty) {
        final value = elements.first.innerText;
        developer.log('✅ مقدار یافت شد برای $tagName (${value.length} chars)');
        return value;
      }
      developer.log('⚠️ مقدار یافت نشد برای $tagName');
      return null;
    } catch (e) {
      developer.log('❌ Error extractValue: $e');
      return null;
    }
  }

  void dispose() => httpClient.close();
}

class SoapException implements Exception {
  final String message;
  SoapException(this.message);
  @override
  String toString() => message;
}
