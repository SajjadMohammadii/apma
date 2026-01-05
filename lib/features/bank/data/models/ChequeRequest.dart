
class ChequeRequest {
  final String personId;
  final String chequeNumber;
  final int status;

  ChequeRequest({
    required this.personId,
    required this.chequeNumber,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "PersonID": personId,
      "ChequeNumber": chequeNumber,
      "Status": status,
    };
  }

  String toJsonString() {
    return toJson().toString();
  }
}
