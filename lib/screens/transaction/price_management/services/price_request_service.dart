// سرویس درخواست‌های تغییر قیمت - ارتباط با API
// مرتبط با: price_management_bloc.dart, soap_client.dart

import 'dart:convert'; // کتابخانه JSON
import 'dart:developer' as developer; // ابزار لاگ‌گیری
import 'package:apma_app/core/network/soap_client.dart'; // کلاینت SOAP
import 'package:apma_app/screens/transaction/price_management/models/price_request_model.dart'; // مدل

// کلاس PriceRequestService - سرویس API درخواست‌های قیمت
class PriceRequestService {
  final SoapClient soapClient; // کلاینت SOAP
  static const String namespace = 'http://apmaco.com/'; // فضای نام وب‌سرویس

  // سازنده
  PriceRequestService({required this.soapClient});

  // متد loadPriceChangeRequestsList - دریافت لیست درخواست‌های تغییر قیمت
  Future<List<PriceRequestModel>> loadPriceChangeRequestsList({
    String? fromDate, // تاریخ شروع
    String? toDate, // تاریخ پایان
    int status = 0, // وضعیت (۰=همه)
    String criteria = '', // کلمات کلیدی
  }) async {
    try {
      // اگر تاریخ خالی یا null است، NULL ارسال کنید
      final Map<String, dynamic> filterData = {
        'FromDate': (fromDate == null || fromDate.isEmpty) ? 'NULL' : fromDate,
        'ToDate': (toDate == null || toDate.isEmpty) ? 'NULL' : toDate,
        'Status': status,
        'Criteria': criteria,
      };

      final String dataParam = jsonEncode(filterData); // تبدیل به JSON

      developer.log('🔍 LoadPriceChangeRequestsList');

      // فراخوانی متد SOAP
      final response = await soapClient.call(
        method: 'LoadPriceChangeRequestsList',
        parameters: {'data': dataParam, 'isNested': '0'},
        namespace: namespace,
        soapAction: '${namespace}LoadPriceChangeRequestsList',
      );

      // استخراج نتیجه از پاسخ
      final resultString = soapClient.extractValue(
        response,
        'LoadPriceChangeRequestsListResult',
      );

      if (resultString == null || resultString.isEmpty) {
        throw Exception('پاسخ سرور خالی است');
      }

      developer.log('📦 پاسخ سرور: ${resultString.length} کاراکتر');
      developer.log('📄 محتوای پاسخ: $resultString');

      // پارس JSON
      final Map<String, dynamic> resultJson = jsonDecode(resultString);
      final int error = resultJson['Error'] ?? 1;

      // بررسی خطا
      if (error != 0) {
        final String errorMessage =
            resultJson['Message'] ?? 'خطای نامشخص از سرور';
        developer.log(' خطا: $errorMessage');
        throw Exception(errorMessage);
      }

      // استخراج جزئیات
      final detailsData = resultJson['Details'];
      if (detailsData == null) {
        developer.log(' لیست خالی');
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

      developer.log(' ${detailsList.length} مورد دریافت شد');

      // شمارش وضعیت‌ها برای دیباگ
      final statusCounts = <int, int>{};
      for (var item in detailsList) {
        final status = item['ConfirmationStatus'];
        developer.log(
          '🔍 DEBUG - ID: ${item['ID']}, ConfirmationStatus: $status (type: ${status.runtimeType})',
        );

        // شمارش هر status
        final statusInt =
            status is int
                ? status
                : int.tryParse(status?.toString() ?? '0') ?? 0;
        statusCounts[statusInt] = (statusCounts[statusInt] ?? 0) + 1;
      }

      developer.log('📊 خلاصه وضعیت‌ها:');
      statusCounts.forEach((status, count) {
        developer.log('   Status $status: $count مورد');
      });

      // تبدیل به لیست مدل
      return detailsList
          .map(
            (json) => PriceRequestModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      developer.log(' خطا: $e');
      rethrow;
    }
  }

  // متد setPriceChangeRequestConfirmationStatus - تنظیم وضعیت تایید درخواست
  Future<void> setPriceChangeRequestConfirmationStatus(
    String id, // شناسه درخواست
    int confirmationStatus, // وضعیت جدید
  ) async {
    try {
      final Map<String, dynamic> data = {
        'ID': id,
        'ConfirmationStatus': confirmationStatus,
      };

      final String dataParam = jsonEncode(data);

      developer.log('💾 ذخیره وضعیت: ID=$id, Status=$confirmationStatus');

      // فراخوانی متد SOAP
      await soapClient.call(
        method: 'SetPriceChangeRequestConfirmationStatus',
        parameters: {'data': dataParam},
        namespace: namespace,
        soapAction: '${namespace}SetPriceChangeRequestConfirmationStatus',
      );

      developer.log(' وضعیت ذخیره شد');
    } catch (e) {
      developer.log(' خطا در ذخیره: $e');
      rethrow;
    }
  }

  // متد saveAllChanges - ذخیره تمام تغییرات
  Future<void> saveAllChanges(List<PriceRequestModel> changedRequests) async {
    for (var request in changedRequests) {
      await setPriceChangeRequestConfirmationStatus(
        request.id,
        request.confirmationStatus,
      );
    }
  }

  // متد groupByOrderNumber - گروه‌بندی بر اساس شماره سفارش
  Map<String, List<PriceRequestModel>> groupByOrderNumber(
    List<PriceRequestModel> requests,
  ) {
    final Map<String, List<PriceRequestModel>> grouped = {};
    for (var request in requests) {
      final key = request.number; // شماره سفارش به عنوان کلید
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(request);
    }
    return grouped;
  }
}
