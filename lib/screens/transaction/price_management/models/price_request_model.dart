// مدل درخواست تغییر قیمت
// مرتبط با: price_management_bloc.dart, price_request_service.dart

import 'dart:developer' as developer; // ابزار لاگ‌گیری

// کلاس PriceRequestModel - مدل داده‌ای درخواست تغییر قیمت
class PriceRequestModel {
  final String orderID; // شناسه سفارش
  final String orderDate; // تاریخ سفارش
  final String personId; // شناسه شخص
  final String personName; // نام شخص
  final String personSurname; // نام خانوادگی شخص
  final String number; // شماره درخواست
  final String date; // تاریخ درخواست
  final String sherkat; // نام شرکت/مشتری
  final String typeSherkat; // نوع شرکت
  final String orderDetailID; // شناسه جزئیات سفارش
  final String codekalaID; // شناسه کد کالا
  final String id; // شناسه یکتا
  final int priceTag; // برچسب قیمت (۰=حداقل، ۱=حداکثر)
  int confirmationStatus; // وضعیت تایید (۱=بررسی، ۲=تایید، ۳=رد)
  final String title; // عنوان کالا
  final String kindID; // شناسه نوع
  final double currentPrice; // قیمت فعلی
  final double requestedPrice; // قیمت درخواستی

  // سازنده
  PriceRequestModel({
    required this.orderID,
    required this.orderDate,
    required this.personId,
    required this.personName,
    required this.personSurname,
    required this.number,
    required this.date,
    required this.sherkat,
    required this.typeSherkat,
    required this.orderDetailID,
    required this.codekalaID,
    required this.id,
    required this.priceTag,
    required this.confirmationStatus,
    required this.title,
    required this.kindID,
    required this.currentPrice,
    required this.requestedPrice,
  });

  // متد fromJson - ساخت مدل از JSON
  factory PriceRequestModel.fromJson(Map<String, dynamic> json) {
    return PriceRequestModel(
      orderID: json['OrderID']?.toString() ?? '',
      orderDate: json['OrderDate']?.toString() ?? '',
      personId: json['PersonId']?.toString() ?? '',
      personName: json['PersonName']?.toString() ?? '',
      personSurname: json['PersonSurname']?.toString() ?? '',
      number: json['Number']?.toString() ?? '',
      date: json['Date']?.toString() ?? '',
      sherkat: json['Sherkat']?.toString() ?? '',
      typeSherkat: json['TypeSherkat']?.toString() ?? '',
      orderDetailID: json['OrderDetailID']?.toString() ?? '',
      codekalaID: json['CodekalaID']?.toString() ?? '',
      id: json['ID']?.toString() ?? '',
      priceTag:
          json['PriceTag'] is int
              ? json['PriceTag']
              : int.tryParse(json['PriceTag']?.toString() ?? '0') ?? 0,
      confirmationStatus:
          json['ConfirmationStatus'] is int
              ? json['ConfirmationStatus']
              : int.tryParse(json['ConfirmationStatus']?.toString() ?? '0') ??
                  0, // تغییر از 1 به 0 تا متوجه بشویم کی null است
      title: json['Title']?.toString() ?? '',
      kindID: json['KindID']?.toString() ?? '',
      currentPrice:
          json['CurrentPrice'] is double
              ? json['CurrentPrice']
              : double.tryParse(json['CurrentPrice']?.toString() ?? '0') ?? 0,
      requestedPrice:
          json['RequestedPrice'] is double
              ? json['RequestedPrice']
              : double.tryParse(json['RequestedPrice']?.toString() ?? '0') ?? 0,
    );
  }

  // متد toJson - تبدیل مدل به JSON
  Map<String, dynamic> toJson() {
    return {'ID': id, 'ConfirmationStatus': confirmationStatus};
  }

  // getter persianOrderDate - تاریخ سفارش به فرمت شمسی
  String get persianOrderDate {
    if (orderDate.length == 8) {
      final year = orderDate.substring(0, 4);
      final month = orderDate.substring(4, 6);
      final day = orderDate.substring(6, 8);
      return '$year/$month/$day';
    }
    return orderDate;
  }

  // getter persianDate - تاریخ درخواست به فرمت شمسی
  String get persianDate {
    if (date.length >= 8) {
      final year = date.substring(0, 4);
      final month = date.substring(4, 6);
      final day = date.substring(6, 8);
      return '$year/$month/$day';
    }
    return date;
  }

  // getter requestType - نوع درخواست (حداقل/حداکثر)
  String get requestType {
    return priceTag == 0 ? 'حداقل قیمت' : 'حداکثر قیمت';
  }

  // getter fullPersonName - نام کامل شخص
  String get fullPersonName => '$personName $personSurname'.trim();

  // getter statusString - وضعیت به صورت رشته فارسی
  String get statusString {
    switch (confirmationStatus) {
      case 1:
        return 'در حال بررسی';
      case 2:
        return 'تایید شده';
      case 3:
        return 'رد شده';
      default:
        // اگر status ناشناخته بود، مقدار واقعی را هم لاگ کن
        developer.log('⚠️ Status ناشناخته: $confirmationStatus');
        return 'نامشخص';
    }
  }

  // getter formattedCurrentPrice - قیمت فعلی با جداکننده هزارگان
  String get formattedCurrentPrice {
    return currentPrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // getter formattedRequestedPrice - قیمت درخواستی با جداکننده هزارگان
  String get formattedRequestedPrice {
    return requestedPrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
