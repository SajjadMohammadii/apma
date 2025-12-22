// lib/features/commuting/presentation/bloc/commuting_bloc.dart
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/commuting_repository.dart' as remote;
import 'commuting_event.dart';
import 'commuting_state.dart';
import 'package:apma_app/core/services/location_service.dart';
import 'package:apma_app/features/commuting/domain/repositories/commuting_repository.dart' hide GetServerDateTime_, GetGeneralSettings_;

class CommutingBloc extends Bloc<CommutingEvent, CommutingState> {
  final CommutingRepository repository;
  final LocationService locationService;
  String? _serverRaw;
  int? _commutingRepeatedInterval;
  int? _status;

  CommutingBloc({
    required this.repository,
    required this.locationService,
  }) : super(CommutingInitial()) {
    on<LoadLastStatusEvent>(_onLoadLastStatus);
    on<GetServerDateTimeEvent>(_onGetServerDateTime);
    on<GetGeneralSettingsEvent>(_onGetGeneralSettings);
    on<SubmitCommutingEvent>(_onSubmitCommuting as EventHandler<SubmitCommutingEvent, CommutingState>);
    on<InsertCommutingEvent>(_onInsertCommuting);
  }

//.......................................................................................
  Future<void> _onLoadLastStatus(
      LoadLastStatusEvent event,
      Emitter<CommutingState> emit,
      ) async {
    // emit(CommutingLoading());

    try {
      final last = await repository.getLastStatus(event.personId);
      final lastStatus = last?.status;

      // تبدیل تاریخ
      String? formattedDate;
      String? formattedTime;
      String? rawDateTime;

      try {
        final raw = last!.lastDateTime!; // مثل 20251214174319
        rawDateTime = raw; // ذخیره برای SharedPreferences

        final parsed = DateTime(
          int.parse(raw.substring(0, 4)),   // سال
          int.parse(raw.substring(4, 6)),   // ماه
          int.parse(raw.substring(6, 8)),   // روز
          int.parse(raw.substring(8, 10)),  // ساعت
          int.parse(raw.substring(10, 12)), // دقیقه
          int.parse(raw.substring(12, 14)), // ثانیه
        );

        final jalali = Jalali.fromDateTime(parsed);
        formattedDate = "${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}";
        formattedTime = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";

        // ذخیره در SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_commuting_raw', raw);
        await prefs.setString('last_commuting_saved_at', DateTime.now().toIso8601String());
        await prefs.setString('lastDate', formattedDate);
        await prefs.setString('lastTime', formattedTime);
        await prefs.setInt('lastStatus', lastStatus!);

        print(' ذخیره lastStatus $lastStatus');
        print(' ذخیره در SharedPreferences: $raw');

      } catch (e) {
        print("Date parsing error: $e");
        // formattedDate = last?.lastDateTime;
      }

      emit(CommutingReady(
        lastDate: formattedDate,
        lastStatus: lastStatus,
        lastTime: formattedTime,
        rawLastDateTime: rawDateTime, // اضافه کردن به state
      ));
    } catch (e) {
      emit(CommutingError(e.toString()));
    }
  }
//.......................................................................................
  Future<void> _onGetServerDateTime(
      GetServerDateTimeEvent event,
      Emitter<CommutingState> emit,
      ) async {
    emit(CommutingLoading());

    try {
      String? formattedDate;
      String? serverTime;
      String? serverDate;

      final last = await repository.getServerDateTime();

      formattedDate = last?.currentServerTime;


        final raw = formattedDate!; // مثل 20251214174319
        final parsed = DateTime(
          int.parse(raw.substring(0, 4)),   // سال
          int.parse(raw.substring(4, 6)),   // ماه
          int.parse(raw.substring(6, 8)),   // روز
          int.parse(raw.substring(8, 10)),  // ساعت
          int.parse(raw.substring(10, 12)), // دقیقه
          int.parse(raw.substring(12, 14)), // ثانیه
        );
        final jalali = Jalali.fromDateTime(parsed);
         serverDate = "${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}";
         serverTime = "${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}";

         print("currentServerTime : $serverDate + $serverTime");

         //todo
        // _tryInsertCommuting();

        emit(GetServerTimeReady(
        serverRaw: raw,
        serverTime: serverTime,
      ));

      _serverRaw = raw;

    } catch (e) {
      emit(CommutingError(e.toString()));
    }
  }
//.......................................................................................
  Future<void> _onGetGeneralSettings(
      GetGeneralSettingsEvent event,
      Emitter<CommutingState> emit,
      ) async {
    emit(CommutingLoading());

    try {
      final last = await repository.getGeneralSettings();
      String? generalSettingsJson = last?.generalSettingsJsonObject;

      if (generalSettingsJson != null) {
        // تبدیل رشته JSON به Map
        Map<String, dynamic> jsonData = jsonDecode(generalSettingsJson);
        // استخراج مقدار مورد نظر
        int? commutingRepeatedInterval = jsonData['CommutingRepeatedInterval'];
        print('استخراج شده: $commutingRepeatedInterval');
        emit(GetGeneralSettingsReady(
          commutingRepeatedInterval: commutingRepeatedInterval,
        ));
        _commutingRepeatedInterval = commutingRepeatedInterval;
      } else {
        // emit(GetGeneralSettingsReady(generalSettingsJsonObject: null));
      }
      // _tryInsertCommuting();
    } catch (e) {
      emit(CommutingError(e.toString()));
    }
    //................................................................................
  }


  Future<void> _tryInsertCommuting() async {
    if (_serverRaw == null || _commutingRepeatedInterval == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final personId = prefs.getString("personId");
      final status = prefs.getInt("lastStatus");
      if (personId == null) return;
      final position = await LocationService().getCurrentPosition();

      add(InsertCommutingEvent(
        PersonID: personId,
        IsEntry: (status==1) ? 1 : 0,
        InsertMode: (status==1) ? 1 : 0,
        Latitude: position.latitude,
        Longitude: position.longitude,
      ));
    } catch (e) {
      debugPrint('tryInsertCommuting error: $e');
    }
  }
  // Future<void> _tryInsertCommuting() async {
  //   if (_serverRaw == null || _commutingRepeatedInterval == null) return;
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final personId = prefs.getString("personId");
  //     if (personId == null) return;
  //     final position = await LocationService().getCurrentPosition();
  //
  //     // فقط وقتی وضعیت آخر ورود بوده، خروج ثبت کن
  //     if (_status == 1) {
  //       add(InsertCommutingEvent(
  //         PersonID: personId,
  //         IsEntry: 0, // خروج
  //         InsertMode: 0,
  //         Latitude: position.latitude,
  //         Longitude: position.longitude,
  //       ));
  //     }
  //   } catch (e) {
  //     debugPrint('tryInsertCommuting error: $e');
  //   }
  // }

  //.......................................................................................
  DateTime parseRaw(String raw) {
    return DateTime(
      int.parse(raw.substring(0, 4)),
      int.parse(raw.substring(4, 6)),
      int.parse(raw.substring(6, 8)),
      int.parse(raw.substring(8, 10)),
      int.parse(raw.substring(10, 12)),
      int.parse(raw.substring(12, 14)),
    );
  }
//....................................................................................
//   _insertRequested = true;
  Future<void> _onInsertCommuting(
      InsertCommutingEvent event,
      Emitter<CommutingState> emit,
      ) async {
    emit(CommutingLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRaw = prefs.getString('last_commuting_raw');

      // DateTime serverTime = parseRaw(event.serverRaw);
      DateTime? lastTime =
      lastRaw != null ? parseRaw(lastRaw) : null;

      await repository.insertCommuting(
        PersonID: event.PersonID!,
        IsEntry: event.IsEntry,
        InsertMode: event.InsertMode,
        Latitude: event.Latitude,
        Longitude: event.Longitude,
      );
      // add(LoadLastStatusEvent(event.PersonID));

      emit(InsertCommutingSuccess());
    } catch (e) {
      emit(CommutingError(e.toString()));
    } finally {
      // _insertRequested = false; // ⭐ حیاتی
    }
  }


  //.......................................................................................

  Future<void> _onSubmitCommuting(
      SubmitCommutingEvent event,
      Emitter<CommutingState> emit,
     ) async {
    emit(CommutingLoading());

    try {

      final last = await repository.insertCommuting(PersonID: event.personId,
          IsEntry: event.selectedStatus, InsertMode: 1, Latitude: 0.0, Longitude: 0.0);

      //todo
      // add(LoadLastStatusEvent(event.personId));

      final insertEntryExitStatus = last?.insertEntryExitSuccess;
      final prefs = await SharedPreferences.getInstance();
      final personId = prefs.getString("personId");
      if(insertEntryExitStatus != null){
        // add(LoadLastStatusEvent(personId!));
      }
      emit(CommutingSubmitted(lastStatus: insertEntryExitStatus));
    } catch (e) {
      print(" خطا در SubmitCommuting: $e");
      emit(CommutingError(e.toString()));
    }
  }
  // Future<void> _onSubmitCommuting(
  //     SubmitCommutingEvent event,
  //     Emitter<CommutingState> emit,
  //     ) async {
  //   emit(CommutingLoading());
  //
  //   try {
  //     // ورود همیشه IsEntry = 1 و InsertMode = 1
  //     final position = await LocationService().getCurrentPosition();
  //     final last = await repository.insertCommuting(
  //       PersonID: event.personId,
  //       IsEntry: 1, // ورود
  //       InsertMode: 1,
  //       // Latitude: event.latitude ?? 0.0,
  //       // Longitude: event.longitude ?? 0.0,
  //       Latitude: position.latitude ?? 0.0,
  //       Longitude: position.longitude ?? 0.0,
  //     );
  //
  //     add(LoadLastStatusEvent(event.personId));
  //
  //     final insertEntryExitStatus = last?.insertEntryExitSuccess;
  //     emit(CommutingSubmitted(lastStatus: insertEntryExitStatus));
  //   } catch (e) {
  //     print("خطا در SubmitCommuting: $e");
  //     emit(CommutingError(e.toString()));
  //   }
  // }
//.......................................................................................
  /// محاسبه فاصله زمانی بین دو تاریخ (yyyyMMddHHmmss)
  int _diffSeconds(String fromYmdHms, String toYmdHms) {
    final f = _parseYmdHms(fromYmdHms);
    final t = _parseYmdHms(toYmdHms);
    return t.difference(f).inSeconds;
  }
//.......................................................................................
  /// تبدیل رشته تاریخ به DateTime
  DateTime _parseYmdHms(String s) {
    final y = int.parse(s.substring(0, 4));
    final m = int.parse(s.substring(4, 6));
    final d = int.parse(s.substring(6, 8));
    final hh = int.parse(s.substring(8, 10));
    final mm = int.parse(s.substring(10, 12));
    final ss = int.parse(s.substring(12, 14));
    return DateTime.utc(y, m, d, hh, mm, ss);
  }
}
//.......................................................................................
