// سرویس مدیریت دسترسی‌های برنامه
// مرتبط با: permission_mixin.dart, permission_dialog.dart

import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class PermissionService {
  // دسترسی‌های مورد نیاز
  static const List<Permission> requiredPermissions = [
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

  static Future<bool> checkAllPermissions() async {
    try {
      for (Permission permission in requiredPermissions) {
        final status = await permission.status;
        if (!status.isGranted && !status.isLimited) {
          developer.log('❌ ${permission.toString()}');
          return false;
        }
      }
      developer.log('✅ تمام دسترسی‌ها موجود است');
      return true;
    } catch (e) {
      developer.log('⚠️ خطا: $e');
      return false;
    }
  }

  static Future<bool> requestAllPermissions() async {
    try {
      bool allGranted = true;

      for (Permission permission in requiredPermissions) {
        final status = await permission.request();
        if (status.isGranted || status.isLimited) {
          developer.log('✅ ${permission.toString()}');
        } else {
          allGranted = false;
          developer.log('❌ ${permission.toString()}');
        }
      }

      return allGranted;
    } catch (e) {
      developer.log('⚠️ خطا: $e');
      return false;
    }
  }

  static Future<List<String>> getDeniedPermissions() async {
    List<String> denied = [];
    for (Permission permission in requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted && !status.isLimited) {
        denied.add(_getPermissionName(permission));
      }
    }
    return denied;
  }

  static String _getPermissionName(Permission permission) {
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
}
