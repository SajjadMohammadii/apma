import 'package:http/http.dart' as api;
import 'bank_repository.dart' as remote;

abstract class BankRepository {

  // Future<InsertCommuting?> insertCommuting({String PersonID, int IsEntry, int InsertMode, double Latitude, double Longitude});
  Future<LoadDriverRelatedCheques?> loadDriverRelatedCheques();
}

//..................................................................................

class LoadDriverRelatedCheques {
  final String? currentServerTime; // yyyyMMddHHmmss or null
  LoadDriverRelatedCheques({this.currentServerTime});
}

//..................................................................................
Future<Map<String, dynamic>> loadDriverRelatedCheques() async {
  final response = await remote.loadDriverRelatedCheques();
  return response;
}

//..................................................................................

// class ChequeRepository {
//   Future<ChequeResponse> loadDriverRelatedCheques(ChequeRequest request) async {
//     // فرض: اینجا متد LoadDriverRelatedChequesList از طریق API یا PlatformChannel صدا زده می‌شود
//     final responseString = await callLoadDriverRelatedChequesList(request.toJsonString());
//
//     final Map<String, dynamic> jsonResponse = jsonDecode(responseString);
//     return ChequeResponse.fromJson(jsonResponse);
//   }
//
//   Future<String> callLoadDriverRelatedChequesList(String requestJson) async {
//     // اینجا باید ارتباط با سرور یا Native برقرار شود
//     // برای نمونه:
//     return Future.value('{"Error":0,"Items":[{"ChequeNumber":"123","PersonID":"456","Status":1}]}');
//   }
// }
