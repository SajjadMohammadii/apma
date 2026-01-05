import 'package:equatable/equatable.dart';

abstract class EntryExitEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// رویداد بارگذاری رکوردهای امروز
class LoadTodayRecordsEvent extends EntryExitEvent {}

// رویداد بارگذاری آمار هفتگی
class LoadWeeklyStatsEvent extends EntryExitEvent {}

// رویداد ذخیره رکورد جدید
class SaveRecordEvent extends EntryExitEvent {
  final String type; // 'entry' یا 'exit'
  final String time;
  final String date;

  SaveRecordEvent({
    required this.type,
    required this.time,
    required this.date,
  });

  @override
  List<Object?> get props => [type, time, date];
}

// رویداد تغییر وضعیت ورود/خروج
class ToggleCheckInEvent extends EntryExitEvent {
  final bool isCheckingIn; // true = ورود، false = خروج
  final String currentTime;
  final String currentDate;

  ToggleCheckInEvent({
    required this.isCheckingIn,
    required this.currentTime,
    required this.currentDate,
  });

  @override
  List<Object?> get props => [isCheckingIn, currentTime, currentDate];
}

// رویداد بارگذاری وضعیت ورود
class LoadCheckInStatusEvent extends EntryExitEvent {}

// رویداد محاسبه زمان کاری
class CalculateWorkDurationEvent extends EntryExitEvent {
  final List<Map<String, dynamic>> todayRecords;
  final bool isCheckedIn;
  final DateTime? entryTime;

  CalculateWorkDurationEvent({
    required this.todayRecords,
    required this.isCheckedIn,
    this.entryTime,
  });

  @override
  List<Object?> get props => [todayRecords, isCheckedIn, entryTime];
}