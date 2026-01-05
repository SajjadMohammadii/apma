import 'dart:convert';
import 'package:apma_app/features/bank/domain/repositories/cheque_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/cheque_repository.dart' as domain;
import '../datasource/cheque_remote_datasource.dart';
import '../models/ChequeRequest.dart';

class ChequeRepositoryImpl implements ChequeRepository {
  final ChequeRemoteDataSource remote;

  ChequeRepositoryImpl({required this.remote});

  @override
  Future<LoadDriverRelatedCheques?> loadDriverRelatedCheques(
      ChequeRequest request) async {
    try {
      final String responseString =
      await remote.loadDriverRelatedChequesList(request.toJsonString());

      final Map<String, dynamic> jsonResponse = jsonDecode(responseString);

      return LoadDriverRelatedCheques.fromJson(jsonResponse);
    } on ServerException catch (e) {
      // باید پیام بدهید
      throw ServerException("Server error: ${e.toString()}");
    } catch (e) {
      throw Exception("Unexpected error: $e");
    }
  }



}
