import 'dart:convert';
import 'dart:developer' as developer;
import 'package:apma_app/core/network/soap_client.dart';
import 'package:apma_app/screens/transaction/price_management/models/price_request_model.dart';

class PriceRequestService {
  final SoapClient soapClient;
  static const String namespace = 'http://apmaco.com/';

  PriceRequestService({required this.soapClient});

  Future<List<PriceRequestModel>> loadPriceChangeRequestsList({
    String? fromDate,
    String? toDate,
    int status = 0,
    String criteria = '',
  }) async {
    try {
      // اگر تاریخ خالی یا null است، NULL ارسال کنید
      final Map<String, dynamic> filterData = {
        'FromDate': (fromDate == null || fromDate.isEmpty) ? 'NULL' : fromDate,
        'ToDate': (toDate == null || toDate.isEmpty) ? 'NULL' : toDate,
        'Status': status,
        'Criteria': criteria,
      };

      final String dataParam = jsonEncode(filterData);

      developer.log('🔍 LoadPriceChangeRequestsList');

      final response = await soapClient.call(
        method: 'LoadPriceChangeRequestsList',
        parameters: {'data': dataParam, 'isNested': '0'},
        namespace: namespace,
        soapAction: '${namespace}LoadPriceChangeRequestsList',
      );

      final resultString = soapClient.extractValue(
        response,
        'LoadPriceChangeRequestsListResult',
      );

      if (resultString == null || resultString.isEmpty) {
        throw Exception('پاسخ سرور خالی است');
      }

      developer.log('📦 پاسخ سرور: ${resultString.length} کاراکتر');
      developer.log('📄 محتوای پاسخ: $resultString');

      final Map<String, dynamic> resultJson = jsonDecode(resultString);
      final int error = resultJson['Error'] ?? 1;

      if (error != 0) {
        final String errorMessage =
            resultJson['Message'] ?? 'خطای نامشخص از سرور';
        developer.log('❌ خطا: $errorMessage');
        throw Exception(errorMessage);
      }

      final detailsData = resultJson['Details'];
      if (detailsData == null) {
        developer.log('⚠️ لیست خالی');
        return [];
      }

      List<dynamic> detailsList;
      if (detailsData is String) {
        if (detailsData.isEmpty) {
          return [];
        }
        detailsList = jsonDecode(detailsData);
      } else if (detailsData is List) {
        detailsList = detailsData;
      } else {
        developer.log('⚠️ فرمت نامعتبر Details');
        return [];
      }

      developer.log('✅ ${detailsList.length} مورد دریافت شد');

      return detailsList
          .map(
            (json) => PriceRequestModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      developer.log('❌ خطا: $e');
      rethrow;
    }
  }

  Future<void> setPriceChangeRequestConfirmationStatus(
    String id,
    int confirmationStatus,
  ) async {
    try {
      final Map<String, dynamic> data = {
        'ID': id,
        'ConfirmationStatus': confirmationStatus,
      };

      final String dataParam = jsonEncode(data);

      developer.log('💾 ذخیره وضعیت: ID=$id, Status=$confirmationStatus');

      await soapClient.call(
        method: 'SetPriceChangeRequestConfirmationStatus',
        parameters: {'data': dataParam},
        namespace: namespace,
        soapAction: '${namespace}SetPriceChangeRequestConfirmationStatus',
      );

      developer.log('✅ وضعیت ذخیره شد');
    } catch (e) {
      developer.log('❌ خطا در ذخیره: $e');
      rethrow;
    }
  }

  Future<void> saveAllChanges(List<PriceRequestModel> changedRequests) async {
    for (var request in changedRequests) {
      await setPriceChangeRequestConfirmationStatus(
        request.id,
        request.confirmationStatus,
      );
    }
  }

  Map<String, List<PriceRequestModel>> groupByOrderNumber(
    List<PriceRequestModel> requests,
  ) {
    final Map<String, List<PriceRequestModel>> grouped = {};
    for (var request in requests) {
      final key = request.number;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(request);
    }
    return grouped;
  }
}
