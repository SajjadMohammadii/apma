import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // دسترسی‌های مورد نیاز
  static List<Permission> get requiredPermissions {
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
      // base.add(Permission.storage); // حافظه در Android
      base.add(Permission.photos); // نگاشت به READ_MEDIA_IMAGES
      base.add(Permission.videos); // // نگاشت به READ_MEDIA_VIDEO
      base.add(Permission.audio); //  نگاشت به READ_MEDIA_AUDIO
      // اگر بخوای دقیق‌تر باشی برای Android 13+
      // base.add(Permission.photos); // در نسخه‌های جدید permission_handler این رو map کرده به READ_MEDIA_IMAGES
    }

    return base;
  }

  static Future<bool> checkAllPermissions() async {
    try {
      for (Permission permission in requiredPermissions) {
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

  static Future<bool> requestAllPermissions() async {
    try {
      bool allGranted = true;
      for (Permission permission in requiredPermissions) {
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
