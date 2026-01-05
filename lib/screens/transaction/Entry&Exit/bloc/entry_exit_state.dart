import 'package:equatable/equatable.dart';

abstract class EntryExitState extends Equatable {
  @override
  List<Object?> get props => [];
}

// حالت اولیه
class EntryExitInitial extends EntryExitState {}

// حالت در حال بارگذاری
class EntryExitLoading extends EntryExitState {}

// حالت بارگذاری رکوردهای امروز
class TodayRecordsLoaded extends EntryExitState {
  final List<Map<String, dynamic>> records;

  TodayRecordsLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

// حالت بارگذاری آمار هفتگی
class WeeklyStatsLoaded extends EntryExitState {
  final List<Map<String, dynamic>> stats;
  final int totalWeeks;
  final String? firstEntryDate;

  WeeklyStatsLoaded({
    required this.stats,
    required this.totalWeeks,
    this.firstEntryDate,
  });

  @override
  List<Object?> get props => [stats, totalWeeks, firstEntryDate];
}

// حالت ذخیره موفق رکورد
class RecordSaved extends EntryExitState {
  final String message;

  RecordSaved(this.message);

  @override
  List<Object?> get props => [message];
}

// حالت تغییر وضعیت ورود/خروج
class CheckInStatusChanged extends EntryExitState {
  final bool isCheckedIn;
  final DateTime? entryTime;
  final String message;

  CheckInStatusChanged({
    required this.isCheckedIn,
    this.entryTime,
    required this.message,
  });

  @override
  List<Object?> get props => [isCheckedIn, entryTime, message];
}

// حالت بارگذاری وضعیت ورود
class CheckInStatusLoaded extends EntryExitState {
  final bool isCheckedIn;
  final DateTime? entryTime;

  CheckInStatusLoaded({
    required this.isCheckedIn,
    this.entryTime,
  });

  @override
  List<Object?> get props => [isCheckedIn, entryTime];
}

// حالت محاسبه زمان کاری
class WorkDurationCalculated extends EntryExitState {
  final String duration;

  WorkDurationCalculated(this.duration);

  @override
  List<Object?> get props => [duration];
}

// حالت خطا
class EntryExitError extends EntryExitState {
  final String message;

  EntryExitError(this.message);

  @override
  List<Object?> get props => [message];
}