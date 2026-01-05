
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../commuting/domain/repositories/commuting_repository.dart';
import '../../../commuting/presentation/bloc/commuting_event.dart';
import '../../../commuting/presentation/bloc/commuting_state.dart';
import '../../domain/repositories/bank_repository.dart';
import 'bank_event.dart';
import 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final BankRepository repository;

  BankBloc({
    required this.repository,
  }) : super(ChequeInitial()) {
    on<LoadDriverRelatedChequesEvent>(_onGetServerDateTime);
  }

//.......................................................................................
  Future<void> _onGetServerDateTime(LoadDriverRelatedChequesEvent event,
      Emitter<BankState> emit,) async {
    emit(ChequeLoading());

    try {
      // String? formattedDate;
      // String? serverTime;
      // String? serverDate;

      final last = await repository.loadDriverRelatedCheques();

      // formattedDate = last?.currentServerTime;
      //
      //
      // final raw = formattedDate!; // مثل 20251214174319
      // final parsed = DateTime(
      //   int.parse(raw.substring(0, 4)),   // سال
      //   int.parse(raw.substring(4, 6)),   // ماه
      //   int.parse(raw.substring(6, 8)),   // روز
      //   int.parse(raw.substring(8, 10)),  // ساعت
      //   int.parse(raw.substring(10, 12)), // دقیقه
      //   int.parse(raw.substring(12, 14)), // ثانیه
      // );
      // final jalali = Jalali.fromDateTime(parsed);
      // serverDate = "${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}";
      // serverTime = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";
      //
      // print("currentServerTime : $serverDate + $serverTime");
      //
      // //todo
      // // _tryInsertCommuting();

      emit(LoadDriverRelatedChequesReady(
        // serverRaw: raw,
        // serverTime: serverTime,
        // serverDate: serverDate,
        // تستی
        serverRaw: "raw",
        serverTime: "serverTime",
        serverDate: "serverDate",
      ));

      // _serverRaw = raw;

    } catch (e) {
      emit(BankError(e.toString()));
    }
  }
//.......................................................................................

  // class ChequeBloc extends Bloc<ChequeEvent, ChequeState> {
  // final ChequeRepository repository;
  //
  // ChequeBloc(this.repository) : super(ChequeInitial()) {
  // on<LoadCheques>((event, emit) async {
  // emit(ChequeLoading());
  // try {
  // final response = await repository.loadDriverRelatedCheques(event.request);
  // if (response.error == 0) {
  // emit(ChequeLoaded(response));
  // } else {
  // emit(ChequeError("خطا در دریافت اطلاعات"));
  // }
  // } catch (e) {
  // emit(ChequeError(e.toString()));
  // }
  // });
  // }
  // }


}