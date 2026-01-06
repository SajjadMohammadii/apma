import 'dart:developer' as developer;
import 'package:apma_app/core/errors/exceptions.dart';
import 'package:apma_app/core/network/soap_client.dart';

abstract class ChequeRemoteDataSource {
  /// فراخوانی سرویس LoadDriverRelatedChequesList
  /// ورودی: رشته JSON شامل PersonID, ChequeNumber, Status
  /// خروجی: رشته JSON شامل Error و Items
  Future<String> loadDriverRelatedChequesList(String requestJson);
}

class ChequeRemoteDataSourceImpl implements ChequeRemoteDataSource {
  final SoapClient soapClient;

  static const String namespace = 'http://apmaco.com/';
  static const String methodLoadDriverRelatedChequesList =
      'LoadDriverRelatedChequesList';

  ChequeRemoteDataSourceImpl({required this.soapClient});

  // ---------------------------------------------------------------------------------------
  // Helper: SOAP call + extract text
  Future<String> _callAndExtract({
    required String method,
    required Map<String, dynamic> parameters,
    required String resultTag,
  }) async {
    try {
      final soapActionUrl = '$namespace$method';

      // تبدیل Map<String, dynamic> به Map<String, String>
      final params = parameters.map(
            (key, value) => MapEntry(key, value?.toString() ?? ''),
      );

      final response = await soapClient.call(
        method: method,
        parameters: params, // حالا Map<String, String> است
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      final result = soapClient.extractValue(response, resultTag);

      if (result == null || result.isEmpty) {
        developer.log('پاسخ خالی از سرور برای $method');
        return '';
      }

      return result;
    } catch (e) {
      developer.log('SOAP Error in $method: $e');
      throw ServerException('خطا در ارتباط با سرور: $e');
    }
  }

  // ---------------------------------------------------------------------------------------
  @override
  Future<String> loadDriverRelatedChequesList(String requestJson) async {
    developer.log('فراخوانی سرویس LoadDriverRelatedChequesList با ورودی: $requestJson');

    return await _callAndExtract(
      method: methodLoadDriverRelatedChequesList,
      parameters: {
        "requestJson": requestJson, // پارامتر ورودی به سرویس
      },
      resultTag: 'LoadDriverRelatedChequesListResult',
    );
  }
}
