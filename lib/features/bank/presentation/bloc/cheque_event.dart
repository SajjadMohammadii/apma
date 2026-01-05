import 'package:equatable/equatable.dart';

abstract class BankEvent extends Equatable{

  @override
  List<Object?> get props => [];
}

//.......................................................................
class LoadDriverRelatedChequesEvent extends BankEvent {
  // GetServerDateTimeEvent({String? lastDateTime});
  LoadDriverRelatedChequesEvent();
  @override
  List<Object?> get props => [];
}

//.......................................................................

// Event
// abstract class ChequeEvent {}
//
// class LoadCheques extends ChequeEvent {
//   final ChequeRequest request;
//   LoadCheques(this.request);
// }
//
// // State
// abstract class ChequeState {}
//
// class ChequeInitial extends ChequeState {}
// class ChequeLoading extends ChequeState {}
// class ChequeLoaded extends ChequeState {
//   final ChequeResponse response;
//   ChequeLoaded(this.response);
// }
// class ChequeError extends ChequeState {
//   final String message;
//   ChequeError(this.message);
// }
