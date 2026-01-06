import '../entities/attendance_record.dart';
import '../entities/weekly_stat.dart';
import '../repositories/entry_exit_repository.dart';

class GetTodayRecords {
  final EntryExitRepository repository;
  GetTodayRecords(this.repository);
  Future<List<AttendanceRecord>> call() async => await repository.getTodayRecords();
}

class SaveRecord {
  final EntryExitRepository repository;
  SaveRecord(this.repository);
  Future<void> call(AttendanceRecord record) async => await repository.saveRecord(record);
}

class GetWeeklyStats {
  final EntryExitRepository repository;
  GetWeeklyStats(this.repository);
  Future<List<WeeklyStat>> call() async => await repository.getWeeklyStats();
}

class GetTotalWeeks {
  final EntryExitRepository repository;
  GetTotalWeeks(this.repository);
  Future<int> call() async => await repository.getTotalWeeks();
}

class GetFirstEntryDate {
  final EntryExitRepository repository;
  GetFirstEntryDate(this.repository);
  Future<String?> call() async => await repository.getFirstEntryDate();
}

class GetCheckInStatus {
  final EntryExitRepository repository;
  GetCheckInStatus(this.repository);
  Future<bool> call() async => await repository.getCheckInStatus();
}

class GetEntryTime {
  final EntryExitRepository repository;
  GetEntryTime(this.repository);
  Future<DateTime?> call() async => await repository.getEntryTime();
}

class SetCheckInStatus {
  final EntryExitRepository repository;
  SetCheckInStatus(this.repository);
  Future<void> call(bool isCheckedIn, DateTime? entryTime) async {
    return await repository.setCheckInStatus(isCheckedIn, entryTime);
  }
}

class CalculateWorkDuration {
  Future<String> call(
    List<AttendanceRecord> todayRecords,
    bool isCheckedIn,
    DateTime? entryTime,
  ) async {
    int totalSeconds = 0;
    
    final entries = todayRecords.where((r) => r.isEntry).toList();
    final exits = todayRecords.where((r) => r.isExit).toList();
    
    for (int i = 0; i < entries.length && i < exits.length; i++) {
      final entryTimeValue = _parseTimeToDateTime(entries[i].time);
      final exitTimeValue = _parseTimeToDateTime(exits[i].time);
      totalSeconds += exitTimeValue.difference(entryTimeValue).inSeconds;
    }
    
    if (isCheckedIn && entryTime != null) {
      final now = DateTime.now();
      totalSeconds += now.difference(entryTime).inSeconds;
    }
    
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  DateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
