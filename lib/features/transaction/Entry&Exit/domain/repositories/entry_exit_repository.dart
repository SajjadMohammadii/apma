import '../entities/attendance_record.dart';
import '../entities/weekly_stat.dart';

abstract class EntryExitRepository {
  Future<List<AttendanceRecord>> getTodayRecords();
  Future<void> saveRecord(AttendanceRecord record);
  Future<List<WeeklyStat>> getWeeklyStats();
  Future<int> getTotalWeeks();
  Future<String?> getFirstEntryDate();
  Future<bool> getCheckInStatus();
  Future<DateTime?> getEntryTime();
  Future<void> setCheckInStatus(bool isCheckedIn, DateTime? entryTime);
}
