// سرویس پرینت مخصوص پلتفرم وب
// مرتبط با: print_service.dart, print_service_stub.dart

import 'dart:typed_data'; // کتابخانه داده‌های باینری
import 'package:flutter/material.dart'; // ویجت‌های متریال
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // کتابخانه HTML برای وب

// getter isDesktopOrWeb - در وب همیشه true است
bool get isDesktopOrWeb => true;

// تابع downloadFile - دانلود فایل در مرورگر وب
// پارامتر bytes: داده‌های باینری فایل
// پارامتر fileName: نام فایل
// پارامتر mimeType: نوع MIME فایل
// پارامتر context: کانتکست (استفاده نمی‌شود در وب)
Future<void> downloadFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  required BuildContext context,
}) async {
  final blob = html.Blob([bytes], mimeType); // ساخت Blob از بایت‌ها
  final url = html.Url.createObjectUrlFromBlob(blob); // ساخت URL برای Blob
  html.AnchorElement(href: url) // ساخت المان لینک
    ..setAttribute('download', fileName) // تنظیم نام فایل برای دانلود
    ..click(); // شبیه‌سازی کلیک برای دانلود
  html.Url.revokeObjectUrl(url); // آزادسازی URL
}
