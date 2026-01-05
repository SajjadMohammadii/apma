
import 'package:apma_app/features/bank/data/models/ChequeResponse.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ChequeRequest.dart';
import '../../domain/repositories/cheque_repository.dart';
import 'cheque_event.dart';
import 'cheque_state.dart';

class ChequeBloc extends Bloc<ChequeEvent, ChequeState> {
  final ChequeRepository repository;

  ChequeBloc({
    required this.repository,
  }) : super(ChequeInitial()) {
    on<LoadCheques>(_onGetCheques);
  }

//.......................................................................................
  Future<void> _onGetCheques(
      LoadCheques event,
      Emitter<ChequeState> emit,) async {
       emit(ChequeLoading());

    // request initialist
     try {
      // final request = ChequeRequest(
      //   personId: "123",
      //   chequeNumber: "456",
      //   status: 1,
      // );

      final LoadDriverRelatedCheques? last =
      await repository.loadDriverRelatedCheques(event.request);

      // emit(ChequeLoaded(last));
      emit(ChequeLoaded(response: last));

    } catch (e) {
      emit(ChequeError(e.toString()));
    }
  }

}

// Future<void> _onGetCheques(
//     LoadCheques event,
//     Emitter<ChequeState> emit,
//     ) async {
//   emit(ChequeLoading());
//
//   try {
//     final LoadDriverRelatedCheques? last =
//     await repository.loadDriverRelatedCheques(event.request);
//
//     emit(ChequeLoaded(response: last));
//   } catch (e) {
//     emit(ChequeError(e.toString()));
//   }
// }
