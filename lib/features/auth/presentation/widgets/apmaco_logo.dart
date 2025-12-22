// ویجت لوگوی ApmaCo - برای صفحات احراز هویت
// مرتبط با: login_page.dart, core/widgets/apmaco_logo.dart

import 'package:flutter/material.dart'; // ویجت‌های متریال دیزاین

// کلاس ApmacoLogo - ویجت نمایش لوگوی شرکت
class ApmacoLogo extends StatelessWidget {
  final double width; // عرض لوگو
  final double height; // ارتفاع لوگو

  // سازنده با مقادیر پیش‌فرض برای عرض و ارتفاع
  const ApmacoLogo({super.key, this.width = 200, this.height = 80});

  @override
  // متد build - ساخت ویجت تصویر لوگو
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/apma_logo.png', // مسیر فایل تصویر لوگو
      width: width, // عرض تصویر
      height: height, // ارتفاع تصویر
      fit: BoxFit.contain, // نحوه قرارگیری تصویر در فضا
    );
  }
}
