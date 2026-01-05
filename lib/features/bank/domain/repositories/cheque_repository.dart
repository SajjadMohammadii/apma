import 'package:http/http.dart' as api;
import '../../data/models/ChequeRequest.dart';
import 'cheque_repository.dart' as remote;

/// تعریف انتزاعی ریپازیتوری
abstract class ChequeRepository {
  Future<LoadDriverRelatedCheques?> loadDriverRelatedCheques(
      ChequeRequest request);
}

/// مدل خروجی (Response)
class LoadDriverRelatedCheques {
  final int error;
  final List<Map<String, dynamic>> items;

  LoadDriverRelatedCheques({
    required this.error,
    required this.items,
  });

  factory LoadDriverRelatedCheques.fromJson(Map<String, dynamic> json) {
    return LoadDriverRelatedCheques(
      error: json["Error"] ?? 1,
      items: (json["Items"] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          [],
    );
  }
}

/// متد کمکی برای فراخوانی ریموت
Future<Map<String, dynamic>> loadDriverRelatedCheques(
    ChequeRequest request) async {
  final response = await remote.loadDriverRelatedCheques(request);
  return response;
}

