// سرویس مدیریت دسترسی‌های برنامه
// مرتبط با: permission_mixin.dart, permission_dialog.dart

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class PermissionService {

  // دسترسی‌های مورد نیاز
  static const List<Permission> requiredPermissionsUp33 = [
    Permission.camera, // دوربین
    Permission.microphone, // میکروفن
    Permission.location, // موقعیت مکانی
    Permission.contacts, // مخاطبین
    Permission.photos, // گالری
    Permission.phone, // تماس
    Permission.sms, // پیامک
    Permission.calendar, // تقویم
    Permission.notification, // اعلان‌ها
  ];

  static Future<bool> checkAllPermissionsUp33() async {
    try {
      for (Permission permission in requiredPermissionsUp33) {
        final status = await permission.status;
        if (!status.isGranted && !status.isLimited) {
          developer.log(' ${permission.toString()}');
          return false;
        }
      }
      developer.log(' تمام دسترسی‌ها موجود است');
      return true;
    } catch (e) {
      developer.log(' خطا: $e');
      return false;
    }
  }

  static Future<bool> requestAllPermissionsUp33() async {
    try {
      bool allGranted = true;

      for (Permission permission in requiredPermissionsUp33) {
        final status = await permission.request();
        if (status.isGranted || status.isLimited) {
          developer.log(' ${permission.toString()}');
        } else {
          allGranted = false;
          developer.log(' ${permission.toString()}');
        }
      }

      return allGranted;
    } catch (e) {
      developer.log(' خطا: $e');
      return false;
    }
  }

  static Future<List<String>> getDeniedPermissionsUp33() async {
    List<String> denied = [];
    for (Permission permission in requiredPermissionsUp33) {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited) {
        denied.add(_getPermissionNameUp33(permission));
      }
    }
    return denied;
  }

  static String _getPermissionNameUp33(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'دوربین';
      case Permission.microphone:
        return 'میکروفن';
      case Permission.location:
        return 'موقعیت مکانی';
      case Permission.contacts:
        return 'مخاطبین';
      case Permission.photos:
        return 'گالری';
      case Permission.phone:
        return 'تماس';
      case Permission.sms:
        return 'پیامک';
      case Permission.calendar:
        return 'تقویم';
      case Permission.notification:
        return 'اعلان‌ها';
      default:
        return permission.toString();
    }
  }

  //.................................... android < 33 ..............................................

  static List<Permission> get requiredPermissionsUnder33 {
    final List<Permission> base = [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.contacts,
      Permission.phone,
      Permission.sms,
      Permission.calendar,
      Permission.notification,
    ];

    if (Platform.isIOS) {
      base.add(Permission.photos); // گالری در iOS
    } else if (Platform.isAndroid) {
      // تشخیص نسخه اندروید
      final int sdkInt = int.tryParse(Platform.version.split(' ').first) ?? 0;

      if (sdkInt >= 33) {
        // اندروید 13 و بالاتر
        base.add(Permission.photos); // READ_MEDIA_IMAGES
        base.add(Permission.videos); // READ_MEDIA_VIDEO
        base.add(Permission.audio);  // READ_MEDIA_AUDIO
      } else {

      }
    }

    return base;
  }

  static Future<bool> checkAllPermissionsUnder33() async {
    try {
      for (Permission permission in requiredPermissionsUnder33) {
        final status = await permission.status;
        if (!status.isGranted && !status.isLimited) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> requestAllPermissionsUnder33() async {
    try {
      bool allGranted = true;
      for (Permission permission in requiredPermissionsUnder33) {
        final status = await permission.request();
        if (!(status.isGranted || status.isLimited)) {
          allGranted = false;
        }
      }
      return allGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> getDeniedPermissionsUnder33() async {
    List<String> denied = [];
    for (Permission permission in requiredPermissionsUnder33) {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited) {
        denied.add(_getPermissionNameUnder33(permission));
      }
    }
    return denied;
  }

  static String _getPermissionNameUnder33(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'دوربین';
      case Permission.microphone:
        return 'میکروفن';
      case Permission.location:
        return 'موقعیت مکانی';
      case Permission.contacts:
        return 'مخاطبین';
      case Permission.photos:
        return 'گالری';
      case Permission.videos:
        return 'ویدیو';
      case Permission.audio:
        return 'موسیقی/صوت';
      case Permission.phone:
        return 'تماس';
      case Permission.sms:
        return 'پیامک';
      case Permission.calendar:
        return 'تقویم';
      case Permission.notification:
        return 'اعلان‌ها';
      case Permission.storage:
        return 'حافظه';
      default:
        return permission.toString();
    }
  }


//..................................................................................

}
