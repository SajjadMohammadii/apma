// lib/features/commuting/presentation/bloc/commuting_state.dart
import 'package:equatable/equatable.dart';

/// حالت‌های مربوط به مدیریت ورود/خروج پرسنل
abstract class CommutingState extends Equatable {
  @override
  List<Object?> get props => [];
}
//..........................................................................
class CommutingInitial extends CommutingState {}
//..........................................................................
class CommutingLoading extends CommutingState {}

class InsertCommutingSuccess extends CommutingState {}
//..........................................................................

class CommutingReady extends CommutingState {
  final String? lastDate;
  final int? lastStatus;
  final String? lastTime;
  final String? rawLastDateTime;

  CommutingReady({
    required this.lastDate,
    required this.lastStatus,
    required this.lastTime,
    required this.rawLastDateTime,
  });

  @override
  List<Object?> get props => [lastDate, lastStatus, lastTime];
}

//..........................................................................
class GetServerTimeReady extends CommutingState {
  final String serverRaw;     // 20251214174319
  final String serverTime;

  GetServerTimeReady({
    required this.serverRaw,
    required this.serverTime,
  });
}

//..........................................................................

class GetGeneralSettingsReady extends CommutingState {
  final int? commutingRepeatedInterval;

  GetGeneralSettingsReady({this.commutingRepeatedInterval});
}

//..........................................................................
/// حالت خطا (نمایش پیام خطا در UI)
class CommutingError extends CommutingState {
  final String message;

  CommutingError(this.message);
  @override
  List<Object?> get props => [message];
}
//..........................................................................
/// حالت بعد از ثبت موفق ورود/خروج
class CommutingSubmitted extends CommutingState {
  final String? lastStatus;

  CommutingSubmitted({
    required this.lastStatus,
  });

}