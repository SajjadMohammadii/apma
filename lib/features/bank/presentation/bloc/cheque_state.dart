import 'package:equatable/equatable.dart';

abstract class BankState extends Equatable {
  @override
  List<Object?> get props => [];
}
//..........................................................................
class ChequeInitial extends BankState {}
//..........................................................................
class ChequeLoading extends BankState {}

class LoadChequeSuccess extends BankState {}
//..........................................................................

class LoadDriverRelatedChequesReady extends BankState {
  final String serverRaw;     // 20251214174319
  final String serverTime;
  final String serverDate;

  LoadDriverRelatedChequesReady({
    required this.serverRaw,
    required this.serverTime,
    required this.serverDate,
  });
}

// class BankReady extends BankState {
//   final String? lastDate;
//   final int? lastStatus;
//   final String? lastTime;
//   final String? rawLastDateTime;
//
//   BankReady({
//     required this.lastDate,
//     required this.lastStatus,
//     required this.lastTime,
//     required this.rawLastDateTime,
//   });
//
//   @override
//   List<Object?> get props => [/*lastDate, lastStatus, lastTime*/];
// }

class BankError extends BankState {
  final String message;
  BankError(this.message);
  @override
  List<Object?> get props => [message];
}