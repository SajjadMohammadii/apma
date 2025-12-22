// فایل stub برای سرویس پرینت در پلتفرم‌های غیر وب
// مرتبط با: print_service.dart, print_service_web.dart

import 'dart:io'; // کتابخانه کار با فایل‌ها
import 'dart:typed_data'; // کتابخانه داده‌های باینری
import 'package:flutter/material.dart'; // ویجت‌های متریال
import 'package:path_provider/path_provider.dart'; // دسترسی به مسیر فایل‌ها

// getter isDesktopOrWeb - بررسی اینکه پلتفرم دسکتاپ یا وب است
bool get isDesktopOrWeb {
  return Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isLinux; // بررسی سیستم‌عامل‌های دسکتاپ
}

// تابع downloadFile - دانلود و ذخیره فایل در دسکتاپ
// پارامتر bytes: داده‌های باینری فایل
// پارامتر fileName: نام فایل
// پارامتر mimeType: نوع MIME فایل
// پارامتر context: کانتکست برای نمایش پیام
Future<void> downloadFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  required BuildContext context,
}) async {
  // فقط در دسکتاپ اجرا می‌شود
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    final directory =
        await getApplicationDocumentsDirectory(); // دریافت مسیر Documents
    final file = File('${directory.path}/$fileName'); // ساخت آدرس فایل
    await file.writeAsBytes(bytes); // نوشتن بایت‌ها در فایل

    // نمایش پیام موفقیت
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فایل ذخیره شد: ${file.path}')));
    }
  }
}
