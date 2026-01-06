import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/weekly_stat.dart';
import '../../domain/repositories/entry_exit_repository.dart';
import '../datasources/entry_exit_local_datasource.dart';
import '../models/attendance_record_model.dart';

class EntryExitRepositoryImpl implements EntryExitRepository {
  final EntryExitLocalDataSource localDataSource;

  EntryExitRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AttendanceRecord>> getTodayRecords() async {
    return await localDataSource.getTodayRecords();
  }

  @override
  Future<void> saveRecord(AttendanceRecord record) async {
    final model = AttendanceRecordModel.fromEntity(record);
    return await localDataSource.saveRecord(model);
  }

  @override
  Future<List<WeeklyStat>> getWeeklyStats() async {
    return await localDataSource.getWeeklyStats();
  }

  @override
  Future<int> getTotalWeeks() async {
    return await localDataSource.getTotalWeeks();
  }

  @override
  Future<String?> getFirstEntryDate() async {
    return await localDataSource.getFirstEntryDate();
  }

  @override
  Future<bool> getCheckInStatus() async {
    return await localDataSource.getCheckInStatus();
  }

  @override
  Future<DateTime?> getEntryTime() async {
    return await localDataSource.getEntryTime();
  }

  @override
  Future<void> setCheckInStatus(bool isCheckedIn, DateTime? entryTime) async {
    return await localDataSource.setCheckInStatus(isCheckedIn, entryTime);
  }
}
