
class ChequeResponse {
  final int error;
  final List<ChequeItem> items;

  ChequeResponse({required this.error, required this.items});

  factory ChequeResponse.fromJson(Map<String, dynamic> json) {
    return ChequeResponse(
      error: json["Error"] ?? 1,
      items: (json["Items"] as List<dynamic>)
          .map((e) => ChequeItem.fromJson(e))
          .toList(),
    );
  }
}

class ChequeItem {
  final String chequeNumber;
  final String personId;
  final int status;

  ChequeItem({
    required this.chequeNumber,
    required this.personId,
    required this.status,
  });

  factory ChequeItem.fromJson(Map<String, dynamic> json) {
    return ChequeItem(
      chequeNumber: json["ChequeNumber"] ?? "",
      personId: json["PersonID"] ?? "",
      status: json["Status"] ?? 0,
    );
  }
}
