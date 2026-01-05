// میکسین مدیریت دسترسی‌ها - برای استفاده در صفحات نیازمند دسترسی خاص
// مرتبط با: permission_service.dart, permission_dialog.dart

import 'dart:io'; // کتابخانه سیستم‌عامل
import 'package:apma_app/core/services/permission_service.dart'; // سرویس دسترسی‌ها
import 'package:apma_app/core/widgets/permission_dialog.dart'; // دیالوگ درخواست دسترسی
import 'package:flutter/foundation.dart'; // ابزارهای پایه
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'dart:developer' as developer; // ابزار لاگ‌گیری

// میکسین PermissionMixin - اضافه کردن قابلیت مدیریت دسترسی‌ها به StatefulWidget
mixin PermissionMixin<T extends StatefulWidget> on State<T> {
  bool _permissionsGranted = false; // متغیر وضعیت دسترسی‌ها

  /// getter _isMobile - بررسی آیا پلتفرم موبایل است
  bool get _isMobile {
    if (kIsWeb) return false; // وب موبایل نیست
    return Platform.isAndroid || Platform.isIOS; // بررسی اندروید یا iOS
  }

  @override
  // متد initState - مقداردهی اولیه و بررسی دسترسی‌ها
  void initState() {
    super.initState();
    _checkAndRequestPermissions(); // بررسی و درخواست دسترسی‌ها
  }

  // متد _checkAndRequestPermissions - بررسی و درخواست دسترسی‌ها
  Future<void> _checkAndRequestPermissions() async {
    // فقط در موبایل چک دسترسی انجام شود
    if (!_isMobile) {
      developer.log(' پلتفرم دسکتاپ/وب - نیازی به چک دسترسی نیست');
      setState(
            () => _permissionsGranted = true,
      ); // در دسکتاپ دسترسی‌ها همیشه OK
      return;
    }

    developer.log(' بررسی دسترسی‌ها شروع شد');

    //todo
    final int sdkInt = int.tryParse(Platform.version.split(' ').first) ?? 0;
    if (sdkInt >= 33) {
      final hasPermissions =
      await PermissionService.checkAllPermissionsUp33(); // بررسی دسترسی‌ها

      if (!hasPermissions) {
        // اگر دسترسی‌ها کامل نیست
        developer.log(' دسترسی‌های ناقص - نمایش dialog');
        _showPermissionDialog(); // نمایش دیالوگ درخواست دسترسی
      } else {
        setState(() => _permissionsGranted = true); // تنظیم وضعیت به true
        developer.log(' تمام دسترسی‌ها موجود است');
        // Navigator.pop(context);
      }
    }else{
      final hasPermissions =
      await PermissionService.checkAllPermissionsUnder33(); // بررسی دسترسی‌ها

      if (!hasPermissions) {
        // اگر دسترسی‌ها کامل نیست
        developer.log(' دسترسی‌های ناقص - نمایش dialog');
        _showPermissionDialog(); // نمایش دیالوگ درخواست دسترسی
      } else {
        setState(() => _permissionsGranted = true); // تنظیم وضعیت به true
        developer.log(' تمام دسترسی‌ها موجود است');
        // Navigator.pop(context);
      }
    }

  }

  // متد _showPermissionDialog - نمایش دیالوگ درخواست دسترسی
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // کاربر نتواند دیالوگ را با کلیک بیرون ببندد
      builder:
          (context) => PermissionDialog(
        onPermissionsGranted: () {
          // callback هنگام اعطای دسترسی‌ها
          setState(() => _permissionsGranted = true);
          developer.log(' دسترسی‌ها اعطا شدند');
          // Navigator.pop(context);
        },
      ),
    );
  }



  // getter hasPermissions - آیا دسترسی‌ها داده شده است
  bool get hasPermissions => _permissionsGranted;

  // متد retryPermissions - تلاش مجدد برای دریافت دسترسی‌ها
  void retryPermissions() {
    _checkAndRequestPermissions();
  }
}
