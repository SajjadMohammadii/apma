
import 'package:apma_app/features/bank/domain/repositories/bank_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/bank_repository.dart' as remote;

@override
Future<LoadDriverRelatedCheques?> loadDriverRelatedCheques() async {
  try {
    final dateTime = await remote.loadDriverRelatedCheques();
    if (dateTime == null) return null;
    // print("Repository → Raw map=$map");
    // LastDateTime
    final lastDateRaw = dateTime;
    final serverDateTime =
    (lastDateRaw == null || lastDateRaw == 'NULL')
        ? null
        : lastDateRaw.toString();
    // print("Repository → LastDateTime=$lastDateTime, Status=$status");
    return LoadDriverRelatedCheques(
      currentServerTime: serverDateTime,
    );
  } on ServerException catch (e) {
    print("Repository → ServerException: ${e.message}");
    return null;
  } on NetworkException catch (e) {
    print("Repository → NetworkException: ${e.message}");
    return null;
  } catch (e) {
    print("Repository → Unexpected error: $e");
    return null;
  }
}
//...................................................................................