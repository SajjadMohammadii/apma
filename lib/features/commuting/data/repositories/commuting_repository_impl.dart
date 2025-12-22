// lib/features/commuting/data/repositories/commuting_repository_impl.dart
import 'dart:convert';

import 'package:apma_app/features/commuting/domain/repositories/commuting_repository.dart';
import 'package:apma_app/features/commuting/data/datasources/commuting_remote_datasource.dart';
import 'package:http/http.dart' as client;

import '../../../../core/constants/app_constant.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/commuting_repository.dart';

/// پیاده‌سازی Repository برای مدیریت ورود/خروج پرسنل
/// این کلاس داده‌ها را از RemoteDataSource می‌گیرد و به مدل‌های دامنه تبدیل می‌کند
class CommutingRepositoryImpl implements CommutingRepository {
  final CommutingRemoteDataSource remote;

  CommutingRepositoryImpl({required this.remote});
//.................................................................................
  @override
  Future<CommutingLastStatus?> getLastStatus(String personId) async {
    try {
      final map = await remote.getLastItem(personId);
      if (map == null) return null;

      final lastDateRaw = map?['Time'];
      final lastDateTime =
      (lastDateRaw == null || lastDateRaw == 'NULL')
          ? null
          : lastDateRaw.toString();

      // Status
      final statusRaw = map?['State'];
      int? status;
      if (statusRaw == null) {
        status = null;
      } else if (statusRaw is num) {
        status = statusRaw.toInt();
      } else if (statusRaw is String) {
        status = int.tryParse(statusRaw);
      }

      // print("Repository → LastDateTime = $lastDateTime, Status=$status");
      print("parameters_envelope_ $lastDateTime, Status=$status");
      print("map = $map");

      return CommutingLastStatus(
        lastDateTime: lastDateTime,
        status: status,
      );
    } on ServerException catch (e) {
      print("Repository → ServerException: ${e.message}");
      return null;
    } on NetworkException catch (e) {
      print("Repository → NetworkException: ${e.message}");
      return null;
    } catch (e) {
      print("Repository → Unexpected error: $e");
      return null;
    }
  }
//.................................................................................
  @override
  Future<GetServerDateTime_?> getServerDateTime() async {
    try {
      final dateTime = await remote.getServerDateTime();
      if (dateTime == null) return null;
      // print("Repository → Raw map=$map");
      // LastDateTime
      final lastDateRaw = dateTime;
      final serverDateTime =
      (lastDateRaw == null || lastDateRaw == 'NULL')
          ? null
          : lastDateRaw.toString();
      // print("Repository → LastDateTime=$lastDateTime, Status=$status");
      return GetServerDateTime_(
        currentServerTime: serverDateTime,
      );
    } on ServerException catch (e) {
      print("Repository → ServerException: ${e.message}");
      return null;
    } on NetworkException catch (e) {
      print("Repository → NetworkException: ${e.message}");
      return null;
    } catch (e) {
      print("Repository → Unexpected error: $e");
      return null;
    }
  }
//...................................................................................
  @override
  Future<GetGeneralSettings_?> getGeneralSettings() async {
    try {
      final dateTime = await remote.getGeneralSettings();
      if (dateTime == null) return null;
      // print("Repository → Raw map=$map");
      // LastDateTime
      final generalSettingsJsonObject_ = dateTime;
      final generalSettingsJsonObject =
      (generalSettingsJsonObject_ == null || generalSettingsJsonObject_ == 'NULL')
          ? null
          : generalSettingsJsonObject_.toString();
      // print("Repository → LastDateTime=$lastDateTime, Status=$status");
      return GetGeneralSettings_(
        generalSettingsJsonObject: generalSettingsJsonObject,
      );
    } on ServerException catch (e) {
      print("Repository → ServerException: ${e.message}");
      return null;
    } on NetworkException catch (e) {
      print("Repository → NetworkException: ${e.message}");
      return null;
    } catch (e) {
      print("Repository → Unexpected error: $e");
      return null;
    }
  }

//.......................................................................................

  @override
  Future<InsertCommuting?> insertCommuting({
    int InsertMode = 1,
    int IsEntry = 1,
    double Latitude = 0,
    double Longitude = 0,
    String PersonID = '',
  }) async {
    // اگر می‌خواهید اعتبارسنجی کنید، اینجا انجام دهید
    if (PersonID.isEmpty) {
      throw ArgumentError('PersonID نباید خالی باشد');
    }
    if (IsEntry != 0 && IsEntry != 1) {
      throw ArgumentError('IsEntry باید 0 یا 1 باشد');
    }

    final payload = {
      'PersonID': PersonID,
      'IsEntry': IsEntry,
      'InsertMode': InsertMode,
      'Latitude': Latitude,
      'Longitude': Longitude,
    };

    try {
      final map = await remote.insertPersonCommuting(payload);

      final lastDateRaw = map?['Time'];
      final lastDateTime =
      (lastDateRaw == null || lastDateRaw == 'NULL') ? null : lastDateRaw.toString();

      final statusRaw = map?['Status'];
      int? status;
      if (statusRaw == null) {
        status = null;
      } else if (statusRaw is num) {
        status = statusRaw.toInt();
      } else if (statusRaw is String) {
        status = int.tryParse(statusRaw);
      }

      print("Repository → LastDateTime=$lastDateTime, Status=$status");

      return InsertCommuting(insertEntryExitSuccess: lastDateTime);
    } on ServerException catch (e) {
      print("Repository → ServerException: ${e.message}");
    } on NetworkException catch (e) {
      print("Repository → NetworkException: ${e.message}");
    } catch (e) {
      print("Repository → Unexpected error: $e");
    }
    return null;
  }


//.......................................................................................

  /// گرفتن تاریخ سرور (yyyyMMdd)
  //todo mmd
  // @override
  // Future<String> getServerDate() => remote.getServerDate();
//..................................................................................
  /// گرفتن تاریخ و زمان سرور (yyyyMMddHHmmss)
  //todo mmd
  // @override
  // Future<String> getServerDateTime() => remote.getServerDateTime();
//..................................................................................
  /// گرفتن فاصله مجاز بین ثبت‌های متوالی (ثانیه)
  @override
  Future<int> getRepeatedIntervalSeconds() =>
      remote.getRepeatedIntervalSeconds();
//..................................................................................

//..................................................................................

}
