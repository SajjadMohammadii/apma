// lib/features/commuting/domain/repositories/commuting_repository.dart
import 'package:http/http.dart' as api;

import 'commuting_repository.dart' as remote;

abstract class CommutingRepository {

  Future<CommutingLastStatus?> getLastStatus(String personId);
  Future<GetServerDateTime_?> getServerDateTime();
  Future<GetGeneralSettings_?> getGeneralSettings();
  Future<int> getRepeatedIntervalSeconds();
  Future<InsertCommuting?> insertCommuting({String PersonID, int IsEntry, int InsertMode, double Latitude, double Longitude});
}
//..................................................................................
//***
class CommutingLastStatus {
  final String? lastDateTime; // yyyyMMddHHmmss or null
  final int? status;          // 0 or 1 or null
  CommutingLastStatus({this.lastDateTime, this.status});
}
//..................................................................................
class GetServerDateTime_ {
  final String? currentServerTime; // yyyyMMddHHmmss or null
  GetServerDateTime_({this.currentServerTime});
}
//..................................................................................
class GetGeneralSettings_ {
  final String? generalSettingsJsonObject; // yyyyMMddHHmmss or null
  GetGeneralSettings_({this.generalSettingsJsonObject});
}
//..................................................................................
class InsertCommuting {
  final String? insertEntryExitSuccess; // yyyyMMddHHmmss or null
  InsertCommuting({this.insertEntryExitSuccess});
}
//..................................................................................
/// گرفتن آخرین وضعیت از سرور
Future<Map<String, dynamic>> getLastItem(String personId) async {
  final response = await remote.getLastItem(personId);
  return response;
}
//..................................................................................
Future<Map<String, dynamic>> getServerDateTime() async {
  final response = await remote.getServerDateTime();
  return response;
}
//..................................................................................
Future<Map<String, dynamic>> getGeneralSettings() async {
  final response = await remote.getGeneralSettings();
  return response;
}
//..................................................................................
Future<Map<String, dynamic>> insertPersonCommuting(String jsonBody) async {
  await api.post(
    Uri.parse('/InsertPersonCommuting'),
    body: jsonBody,
  );
  final response = await remote.insertPersonCommuting(jsonBody);
  return response;
}
//..................................................................................
/// ثبت commuting جدید در سرور
Future<void> registerCommuting(String personId, int status) async {
  print(" درخواست registerCommuting:");
  print("personId=$personId, status=$status");
  await remote.registerCommuting(personId, status);
  print(" پاسخ سرور registerCommuting: ثبت موفق انجام شد");
}
//..................................................................................

