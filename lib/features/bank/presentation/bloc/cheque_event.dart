import 'package:apma_app/features/bank/data/models/ChequeRequest.dart';
import 'package:equatable/equatable.dart';

abstract class ChequeEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

//.......................................................................
class LoadCheques extends ChequeEvent {
  final ChequeRequest request; // از domain
  LoadCheques(this.request);
  @override
  List<Object?> get props => [];
}

//.......................................................................


