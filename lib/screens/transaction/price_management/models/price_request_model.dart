class PriceRequestModel {
  final String orderID;
  final String orderDate;
  final String personID;
  final String personName;
  final String personSurname;
  final String number;
  final String date;
  final String sherkat;
  final String typeSherkat;
  final String orderDetailID;
  final String codekalaID;
  final String id;
  final int priceTag;
  int confirmationStatus;
  final String title;
  final String kindID;
  final double currentPrice;
  final double requestedPrice;

  PriceRequestModel({
    required this.orderID,
    required this.orderDate,
    required this.personID,
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

  factory PriceRequestModel.fromJson(Map<String, dynamic> json) {
    return PriceRequestModel(
      orderID: json['OrderID']?.toString() ?? '',
      orderDate: json['OrderDate']?.toString() ?? '',
      personID: json['PersonID']?.toString() ?? '',
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
              : int.tryParse(json['ConfirmationStatus']?.toString() ?? '1') ??
                  1,
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

  Map<String, dynamic> toJson() {
    return {'ID': id, 'ConfirmationStatus': confirmationStatus};
  }

  String get persianOrderDate {
    if (orderDate.length == 8) {
      final year = orderDate.substring(0, 4);
      final month = orderDate.substring(4, 6);
      final day = orderDate.substring(6, 8);
      return '$year/$month/$day';
    }
    return orderDate;
  }

  String get persianDate {
    if (date.length >= 8) {
      final year = date.substring(0, 4);
      final month = date.substring(4, 6);
      final day = date.substring(6, 8);
      return '$year/$month/$day';
    }
    return date;
  }

  String get requestType {
    return priceTag == 0 ? 'حداقل قیمت' : 'حداکثر قیمت';
  }

  String get fullPersonName => '$personName $personSurname'.trim();

  String get statusString {
    switch (confirmationStatus) {
      case 1:
        return 'در حال بررسی';
      case 2:
        return 'تایید شده';
      case 3:
        return 'رد شده';
      default:
        return 'نامشخص';
    }
  }

  String get formattedCurrentPrice {
    return currentPrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get formattedRequestedPrice {
    return requestedPrice
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
