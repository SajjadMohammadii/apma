// lib/features/commuting/presentation/bloc/commuting_event.dart
import 'dart:convert';

import 'package:equatable/equatable.dart';


abstract class CommutingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}
//.......................................................................

class LoadLastStatusEvent extends CommutingEvent {
  final String personId;
  LoadLastStatusEvent(this.personId);
  @override
  List<Object?> get props => [personId];
}
//.......................................................................
class GetServerDateTimeEvent extends CommutingEvent {
  // GetServerDateTimeEvent({String? lastDateTime});
  GetServerDateTimeEvent();
  @override
  List<Object?> get props => [];
}
//.......................................................................
class GetGeneralSettingsEvent extends CommutingEvent {
  // GetGeneralSettingsEvent({int? commutingRepeatedInterval});
  GetGeneralSettingsEvent();
  @override
  List<Object?> get props => [];
}
//.......................................................................
// class FetchServerDateTime extends CommutingEvent {}
/// رویداد: ثبت ورود یا خروج جدید
class SubmitCommutingEvent extends CommutingEvent {
  final String personId;
  final int selectedStatus; // 0 = خروج، 1 = ورود

  SubmitCommutingEvent({
    required this.personId,
    required this.selectedStatus,
  });

  @override
  List<Object?> get props => [personId, selectedStatus];
}
//.......................................................................

class InsertCommutingEvent extends CommutingEvent {
  // final String serverRaw;
  // final int commutingRepeatedInterval;
  final String PersonID;
  final int IsEntry;      // 1 ورود | 0 خروج
  final int InsertMode;   // مثلاً 1 = موبایل
  final double Latitude;
  final double Longitude;

  InsertCommutingEvent({
    // required this.serverRaw,
    // required this.commutingRepeatedInterval,
    required this.PersonID,
    required this.IsEntry,
    required this.InsertMode,
    required this.Latitude,
    required this.Longitude,
  });
}



