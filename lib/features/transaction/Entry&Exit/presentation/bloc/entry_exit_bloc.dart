import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'entry_exit_event.dart';
import 'entry_exit_state.dart';

class EntryExitBloc extends Bloc<EntryExitEvent, EntryExitState> {
  EntryExitBloc() : super(EntryExitInitial()) {
    on<LoadTodayRecordsEvent>(_onLoadTodayRecords);
    on<LoadWeeklyStatsEvent>(_onLoadWeeklyStats);
    on<SaveRecordEvent>(_onSaveRecord);
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<LoadCheckInStatusEvent>(_onLoadCheckInStatus);
    on<CalculateWorkDurationEvent>(_onCalculateWorkDuration);
  }

  // بارگذاری رکوردهای امروز
  Future<void> _onLoadTodayRecords(
    LoadTodayRecordsEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      emit(EntryExitLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final jalaliToday = Jalali.now();
      final todayKey = '${jalaliToday.year}${jalaliToday.month.toString().padLeft(2, '0')}${jalaliToday.day.toString().padLeft(2, '0')}';
      
      final recordsJson = prefs.getString('records_$todayKey');
      List<Map<String, dynamic>> records = [];
      
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        records = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      
      emit(TodayRecordsLoaded(records));
    } catch (e) {
      emit(EntryExitError('خطا در بارگذاری رکوردها: $e'));
    }
  }

  // بارگذاری آمار هفتگی
  Future<void> _onLoadWeeklyStats(
    LoadWeeklyStatsEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      emit(EntryExitLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final firstEntry = prefs.getString('first_entry_date');
      
      if (firstEntry == null) {
        emit(WeeklyStatsLoaded(stats: [], totalWeeks: 0, firstEntryDate: null));
        return;
      }
      
      // تبدیل اولین تاریخ ورود
      final firstYear = int.parse(firstEntry.substring(0, 4));
      final firstMonth = int.parse(firstEntry.substring(4, 6));
      final firstDay = int.parse(firstEntry.substring(6, 8));
      final firstJalali = Jalali(firstYear, firstMonth, firstDay);
      
      final jalaliToday = Jalali.now();
      final daysDiff = jalaliToday.toDateTime().difference(firstJalali.toDateTime()).inDays;
      
      // محاسبه تعداد هفته‌ها
      final totalWeeks = (daysDiff / 7).ceil();
      final firstEntryDate = '${firstJalali.year}/${firstJalali.month.toString().padLeft(2, '0')}/${firstJalali.day.toString().padLeft(2, '0')}';
      
      List<Map<String, dynamic>> stats = [];
      
      final dayNames = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'];
      
      // فقط 6 روز قبل را نمایش بده
      for (int i = 5; i >= 0; i--) {
        final day = jalaliToday.addDays(-i);
        
        // اگر این روز قبل از اولین ورود است، نمایش نده
        if (day.toDateTime().isBefore(firstJalali.toDateTime())) {
          continue;
        }
        
        final dayKey = '${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
        final recordsJson = prefs.getString('records_$dayKey');
        
        String hours = '-';
        String status = 'تعطیل';
        
        if (recordsJson != null) {
          final List<dynamic> decoded = jsonDecode(recordsJson);
          final records = decoded.map((e) => e as Map<String, dynamic>).toList();
          
          // محاسبه ساعات کار
          final entries = records.where((r) => r['type'] == 'entry').toList();
          final exits = records.where((r) => r['type'] == 'exit').toList();
          
          if (entries.isNotEmpty && exits.isNotEmpty) {
            // محاسبه مجموع ساعات
            int totalMinutes = 0;
            for (int j = 0; j < entries.length && j < exits.length; j++) {
              final entryTime = _parseTimeToDateTime(entries[j]['time']);
              final exitTime = _parseTimeToDateTime(exits[j]['time']);
              totalMinutes += exitTime.difference(entryTime).inMinutes;
            }
            
            final workHours = totalMinutes ~/ 60;
            final workMinutes = totalMinutes % 60;
            hours = '$workHours:${workMinutes.toString().padLeft(2, '0')}';
            
            // تعیین وضعیت
            if (totalMinutes >= 480) { // 8 ساعت
              status = 'کامل';
            } else if (totalMinutes >= 420) { // 7 ساعت
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
        
        final dayOfWeek = day.weekDay; // 1=شنبه، 7=جمعه
        final dayDate = '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';
        
        stats.add({
          'day': dayNames[(dayOfWeek - 1) % 7],
          'date': dayDate,
          'hours': hours,
          'status': status,
        });
      }
      
      // روز امروز
      final todayDayOfWeek = jalaliToday.weekDay;
      final todayDate = '${jalaliToday.year}/${jalaliToday.month.toString().padLeft(2, '0')}/${jalaliToday.day.toString().padLeft(2, '0')}';
      
      stats.add({
        'day': dayNames[(todayDayOfWeek - 1) % 7],
        'date': todayDate,
        'hours': '-',
        'status': 'امروز',
      });
      
      emit(WeeklyStatsLoaded(
        stats: stats,
        totalWeeks: totalWeeks,
        firstEntryDate: firstEntryDate,
      ));
    } catch (e) {
      emit(EntryExitError('خطا در بارگذاری آمار هفتگی: $e'));
    }
  }

  // ذخیره رکورد جدید
  Future<void> _onSaveRecord(
    SaveRecordEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jalaliNow = Jalali.now();
      final todayKey = '${jalaliNow.year}${jalaliNow.month.toString().padLeft(2, '0')}${jalaliNow.day.toString().padLeft(2, '0')}';
      
      // ذخیره اولین تاریخ ورود
      if (event.type == 'entry') {
        final firstEntry = prefs.getString('first_entry_date');
        if (firstEntry == null) {
          await prefs.setString('first_entry_date', todayKey);
        }
      }
      
      // گرفتن رکوردهای قبلی
      final recordsJson = prefs.getString('records_$todayKey');
      List<Map<String, dynamic>> records = [];
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        records = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      
      // افزودن رکورد جدید
      records.add({
        'type': event.type,
        'time': event.time,
        'date': event.date,
        'status': 'تایید شده',
      });
      
      // ذخیره
      await prefs.setString('records_$todayKey', jsonEncode(records));
      
      emit(RecordSaved('رکورد ذخیره شد'));
      
      // بارگذاری مجدد رکوردها و آمار
      add(LoadTodayRecordsEvent());
      add(LoadWeeklyStatsEvent());
    } catch (e) {
      emit(EntryExitError('خطا در ذخیره رکورد: $e'));
    }
  }

  // تغییر وضعیت ورود/خروج
  Future<void> _onToggleCheckIn(
    ToggleCheckInEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      DateTime? entryTime;
      
      if (event.isCheckingIn) {
        // ورود
        entryTime = DateTime.now();
        await prefs.setBool('is_checked_in', true);
        await prefs.setString('entry_time', entryTime.toIso8601String());
      } else {
        // خروج
        entryTime = null;
        await prefs.setBool('is_checked_in', false);
        await prefs.remove('entry_time');
      }
      
      // ذخیره رکورد
      add(SaveRecordEvent(
        type: event.isCheckingIn ? 'entry' : 'exit',
        time: event.currentTime,
        date: event.currentDate,
      ));
      
      emit(CheckInStatusChanged(
        isCheckedIn: event.isCheckingIn,
        entryTime: entryTime,
        message: event.isCheckingIn ? 'ورود ثبت شد' : 'خروج ثبت شد',
      ));
    } catch (e) {
      emit(EntryExitError('خطا در تغییر وضعیت: $e'));
    }
  }

  // بارگذاری وضعیت ورود
  Future<void> _onLoadCheckInStatus(
    LoadCheckInStatusEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCheckedIn = prefs.getBool('is_checked_in') ?? false;
      final entryTimeStr = prefs.getString('entry_time');
      
      DateTime? entryTime;
      if (entryTimeStr != null && isCheckedIn) {
        entryTime = DateTime.parse(entryTimeStr);
      }
      
      emit(CheckInStatusLoaded(
        isCheckedIn: isCheckedIn,
        entryTime: entryTime,
      ));
    } catch (e) {
      emit(EntryExitError('خطا در بارگذاری وضعیت: $e'));
    }
  }

  // محاسبه زمان کاری
  Future<void> _onCalculateWorkDuration(
    CalculateWorkDurationEvent event,
    Emitter<EntryExitState> emit,
  ) async {
    try {
      int totalSeconds = 0;
      
      // پیدا کردن همه ورودها و خروج‌ها
      final entries = event.todayRecords.where((r) => r['type'] == 'entry').toList();
      final exits = event.todayRecords.where((r) => r['type'] == 'exit').toList();
      
      // محاسبه زمان بین هر جفت ورود-خروج
      for (int i = 0; i < entries.length && i < exits.length; i++) {
        final entryTime = _parseTimeToDateTime(entries[i]['time']);
        final exitTime = _parseTimeToDateTime(exits[i]['time']);
        totalSeconds += exitTime.difference(entryTime).inSeconds;
      }
      
      // اگر الان در حالت ورود هستیم، زمان از آخرین ورود تا الان رو اضافه کن
      if (event.isCheckedIn && event.entryTime != null) {
        final now = DateTime.now();
        totalSeconds += now.difference(event.entryTime!).inSeconds;
      }
      
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      final seconds = totalSeconds % 60;
      
      final duration = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      
      emit(WorkDurationCalculated(duration));
    } catch (e) {
      emit(EntryExitError('خطا در محاسبه زمان کاری: $e'));
    }
  }

  // تابع کمکی: تبدیل رشته زمان به DateTime
  DateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}