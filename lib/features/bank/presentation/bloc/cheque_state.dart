import 'package:equatable/equatable.dart';
import '../../domain/repositories/cheque_repository.dart';

abstract class ChequeState extends Equatable {
  @override
  List<Object?> get props => [];
}
//..........................................................................
class ChequeInitial extends ChequeState {}

//..........................................................................
class ChequeLoading extends ChequeState {}

//..........................................................................

// class ChequeLoaded extends ChequeState {
//   final ChequeResponse response;
//   //   final String responseString;
//   ChequeLoaded(this.response);
//   // @override
//   // List<Object?> get props => [response];
// }
class ChequeLoaded extends ChequeState {
  final LoadDriverRelatedCheques? response;
  ChequeLoaded({required this.response});
}

//..........................................................................

class ChequeError extends ChequeState {
  final String message;
  ChequeError(this.message);
  @override
  List<Object?> get props => [message];
}
