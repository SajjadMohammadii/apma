// lib/features/commuting/data/datasources/commuting_remote_datasource.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:apma_app/core/errors/exceptions.dart';
import 'package:apma_app/core/network/soap_client.dart';

abstract class CommutingRemoteDataSource {
  Future<Map<String, dynamic>?> getLastItem(String personId);
  Future<String> getServerDateTime();       // yyyyMMddHHmmss
  Future<String> getGeneralSettings();       // yyyyMMddHHmmss
  Future<String> getServerDate();           // yyyyMMdd
  Future<int> getRepeatedIntervalSeconds(); // CommutingRepeatedInterval
  Future<Map<String, dynamic>?> insertPersonCommuting(Map<String, dynamic> payload);
}

class CommutingRemoteDataSourceImpl implements CommutingRemoteDataSource {
  final SoapClient soapClient;

  static const String namespace = 'http://apmaco.com/';

  static const String methodGetLastItem = 'PersonCommutingGetLastItem';
  static const String methodGetServerDate = 'GetServerDate';
  static const String methodGetServerDateTime = 'GetServerDateTime';
  static const String methodGetGeneralSettings = 'GetGeneralSettings';
  static const String methodInsertCommuting = 'InsertPersonCommuting';

  CommutingRemoteDataSourceImpl({required this.soapClient});

  // -------------------------------
  // Helper: SOAP call + extract text
  // -------------------------------
  //..................................................................................
  Future<String> _callAndExtract({
    required String method,
    required Map<String, dynamic> parameters,
    required String resultTag,
  }) async {
    try {
      final soapActionUrl = '$namespace$method';

      //  تبدیل Map<String, dynamic> به Map<String, String>
      final params = parameters.map(
            (key, value) => MapEntry(key, value?.toString() ?? ''),
      );

      final response = await soapClient.call(
        method: method,
        parameters: params, //  حالا Map<String, String> است
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      final result = soapClient.extractValue(response, resultTag);

      if (result == null || result.isEmpty) {
        developer.log(' پاسخ خالی از سرور برای $method');
        return '';
      }

      return result;
    } catch (e) {
      developer.log(' SOAP Error in $method: $e');
      throw ServerException('خطا در ارتباط با سرور: $e');
    }
  }

  //..................................................................................
  @override
  Future<Map<String, dynamic>?> getLastItem(String personId) async {
    developer.log(' دریافت آخرین رکورد تردد برای $personId');

    final result = await _callAndExtract(
      method: methodGetLastItem,
      parameters: {'personId': personId},
      resultTag: 'PersonCommutingGetLastItemResult',
    );

    if (result.isEmpty || result == 'NULL') return null;

    try {
      final map = jsonDecode(result) as Map<String, dynamic>;
      developer.log("RemoteDataSource → Decoded JSON: $map"); // ← اینجا لاگ درست اجرا میشه
      return map;
    } catch (e) {
      developer.log(' JSON Error getLastItem: $e');
      return null;
    }
  }
  //..................................................................................
  @override
  Future<String> getServerDateTime() async {
    developer.log(' دریافت تاریخ سرور');

    return await _callAndExtract(
      method: methodGetServerDateTime,
      parameters: {},
      resultTag: 'GetServerDateTimeResult',
    );
  }
//..................................................................................
  @override
  Future<String> getGeneralSettings() async {
    developer.log(' دریافت تاریخ سرور');

    return await _callAndExtract(
      method: methodGetGeneralSettings,
      parameters: {},
      resultTag: 'GetGeneralSettingsResult',
    );
  }
//..................................................................................

  @override
  Future<int> getRepeatedIntervalSeconds() async {
    developer.log(' دریافت تنظیمات تردد');

    final result = await _callAndExtract(
      method: methodGetGeneralSettings,
      parameters: {},
      resultTag: 'GetGeneralSettingsResult',
    );

    try {
      final jsonObj = jsonDecode(result);

      if (jsonObj is Map<String, dynamic>) {
        final val = jsonObj['CommutingRepeatedInterval'];
        if (val is num) return val.toInt();
        if (val is String) return int.tryParse(val) ?? 0;
      }
    } catch (e) {
      developer.log(' JSON Error getRepeatedIntervalSeconds: $e');
    }

    return 0;
  }
//..................................................................................

  @override
  Future<Map<String, dynamic>?> insertPersonCommuting(Map<String, dynamic> payload) async {
    final jsonBody = jsonEncode(payload); // کل payload را JSON کن

    final params = {
      'data': jsonBody, // سرور انتظار دارد کل JSON در پارامتر data باشد
    };

    final result = await _callAndExtract(
      method: methodInsertCommuting,
      parameters: params,
      resultTag: 'InsertPersonCommutingResult',
    );

    if (result.isEmpty) {
      throw ServerException('InsertPersonCommuting بدون Result');
    }
    // return null;
    try {
      final map = jsonDecode(result) as Map<String, dynamic>;
      developer.log("RemoteDataSourceInsertPersonCommutingResult → Decoded JSON: $map");
      return map;
    } catch (e) {
      developer.log(' JSON Error insertPersonCommutingResult: $e');
      return null;
    }
  }



//..................................................................................
  @override
  Future<String> getServerDate() {
    // TODO: implement getServerDate
    throw UnimplementedError();
  }
//..................................................................................

}
