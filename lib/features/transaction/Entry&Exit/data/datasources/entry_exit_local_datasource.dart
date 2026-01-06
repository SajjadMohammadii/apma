import 'dart:convert';
import 'package:apma_app/features/transaction/Entry&Exit/data/models/attendance_record_model.dart';
import 'package:apma_app/features/transaction/Entry&Exit/data/models/weekly_stat_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

abstract class EntryExitLocalDataSource {
  Future<List<AttendanceRecordModel>> getTodayRecords();
  Future<void> saveRecord(AttendanceRecordModel record);
  Future<List<WeeklyStatModel>> getWeeklyStats();
  Future<int> getTotalWeeks();
  Future<String?> getFirstEntryDate();
  Future<bool> getCheckInStatus();
  Future<DateTime?> getEntryTime();
  Future<void> setCheckInStatus(bool isCheckedIn, DateTime? entryTime);
}

class EntryExitLocalDataSourceImpl implements EntryExitLocalDataSource {
  final SharedPreferences sharedPreferences;

  EntryExitLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<AttendanceRecordModel>> getTodayRecords() async {
    final jalaliToday = Jalali.now();
    final todayKey = '${jalaliToday.year}${jalaliToday.month.toString().padLeft(2, '0')}${jalaliToday.day.toString().padLeft(2, '0')}';
    
    final recordsJson = sharedPreferences.getString('records_$todayKey');
    
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      return decoded.map((e) => AttendanceRecordModel.fromJson(e)).toList();
    }
    
    return [];
  }

  @override
  Future<void> saveRecord(AttendanceRecordModel record) async {
    final jalaliNow = Jalali.now();
    final todayKey = '${jalaliNow.year}${jalaliNow.month.toString().padLeft(2, '0')}${jalaliNow.day.toString().padLeft(2, '0')}';
    
    if (record.type == 'entry') {
      final firstEntry = sharedPreferences.getString('first_entry_date');
      if (firstEntry == null) {
        await sharedPreferences.setString('first_entry_date', todayKey);
      }
    }
    
    final recordsJson = sharedPreferences.getString('records_$todayKey');
    List<Map<String, dynamic>> records = [];
    
    if (recordsJson != null) {
      final List<dynamic> decoded = jsonDecode(recordsJson);
      records = decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    
    records.add(record.toJson());
    await sharedPreferences.setString('records_$todayKey', jsonEncode(records));
  }

  @override
  Future<List<WeeklyStatModel>> getWeeklyStats() async {
    final firstEntry = sharedPreferences.getString('first_entry_date');
    
    if (firstEntry == null) {
      return [];
    }
    
    final firstYear = int.parse(firstEntry.substring(0, 4));
    final firstMonth = int.parse(firstEntry.substring(4, 6));
    final firstDay = int.parse(firstEntry.substring(6, 8));
    final firstJalali = Jalali(firstYear, firstMonth, firstDay);
    
    final jalaliToday = Jalali.now();
    
    List<WeeklyStatModel> stats = [];
    final dayNames = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'];
    
    for (int i = 5; i >= 0; i--) {
      final day = jalaliToday.addDays(-i);
      
      if (day.toDateTime().isBefore(firstJalali.toDateTime())) {
        continue;
      }
      
      final dayKey = '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
      final recordsJson = sharedPreferences.getString('records_$dayKey');
      
      String hours = '-';
      String status = 'تعطیل';
      
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        final records = decoded.map((e) => AttendanceRecordModel.fromJson(e)).toList();
        
        final entries = records.where((r) => r.type == 'entry').toList();
        final exits = records.where((r) => r.type == 'exit').toList();
        
        if (entries.isNotEmpty && exits.isNotEmpty) {
          int totalMinutes = 0;
          for (int j = 0; j < entries.length && j < exits.length; j++) {
            final entryTime = _parseTimeToDateTime(entries[j].time);
            final exitTime = _parseTimeToDateTime(exits[j].time);
            totalMinutes += exitTime.difference(entryTime).inMinutes;
          }
          
          final workHours = totalMinutes ~/ 60;
          final workMinutes = totalMinutes % 60;
          hours = '$workHours:${workMinutes.toString().padLeft(2, '0')}';
          
          if (totalMinutes >= 480) {
            status = 'کامل';
          } else if (totalMinutes >= 420) {
            status = 'کسری';
          } else {
            status = 'کسری';
          }
          
          if (totalMinutes > 480) {
            status = 'اضافه‌کار';
          }
        } else if (entries.isNotEmpty) {
          status = 'در حال کار';
        }
      }
      
      final dayOfWeek = day.weekDay;
      final dayDate = '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';
      
      stats.add(WeeklyStatModel(
        day: dayNames[(dayOfWeek - 1) % 7],
        date: dayDate,
        hours: hours,
        status: status,
      ));
    }
    
    final todayDayOfWeek = jalaliToday.weekDay;
    final todayDate = '${jalaliToday.year}/${jalaliToday.month.toString().padLeft(2, '0')}/${jalaliToday.day.toString().padLeft(2, '0')}';
    
    stats.add(WeeklyStatModel(
      day: dayNames[(todayDayOfWeek - 1) % 7],
      date: todayDate,
      hours: '-',
      status: 'امروز',
    ));
    
    return stats;
  }

  @override
  Future<int> getTotalWeeks() async {
    final firstEntry = sharedPreferences.getString('first_entry_date');
    
    if (firstEntry == null) {
      return 0;
    }
    
    final firstYear = int.parse(firstEntry.substring(0, 4));
    final firstMonth = int.parse(firstEntry.substring(4, 6));
    final firstDay = int.parse(firstEntry.substring(6, 8));
    final firstJalali = Jalali(firstYear, firstMonth, firstDay);
    
    final jalaliToday = Jalali.now();
    final daysDiff = jalaliToday.toDateTime().difference(firstJalali.toDateTime()).inDays;
    
    return (daysDiff / 7).ceil();
  }

  @override
  Future<String?> getFirstEntryDate() async {
    final firstEntry = sharedPreferences.getString('first_entry_date');
    
    if (firstEntry == null) {
      return null;
    }
    
    final firstYear = int.parse(firstEntry.substring(0, 4));
    final firstMonth = int.parse(firstEntry.substring(4, 6));
    final firstDay = int.parse(firstEntry.substring(6, 8));
    final firstJalali = Jalali(firstYear, firstMonth, firstDay);
    
    return '${firstJalali.year}/${firstJalali.month.toString().padLeft(2, '0')}/${firstJalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<bool> getCheckInStatus() async {
    return sharedPreferences.getBool('is_checked_in') ?? false;
  }

  @override
  Future<DateTime?> getEntryTime() async {
    final entryTimeStr = sharedPreferences.getString('entry_time');
    
    if (entryTimeStr != null) {
      return DateTime.parse(entryTimeStr);
    }
    
    return null;
  }

  @override
  Future<void> setCheckInStatus(bool isCheckedIn, DateTime? entryTime) async {
    await sharedPreferences.setBool('is_checked_in', isCheckedIn);
    
    if (isCheckedIn && entryTime != null) {
      await sharedPreferences.setString('entry_time', entryTime.toIso8601String());
    } else {
      await sharedPreferences.remove('entry_time');
    }
  }

  DateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
