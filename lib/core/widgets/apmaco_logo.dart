// ویجت لوگوی ApmaCo قابل استفاده مجدد
// مرتبط با: login_page.dart, splash_screen.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس ApmacoLogo - ویجت نمایش لوگوی متنی شرکت
class ApmacoLogo extends StatelessWidget {
  final double width; // عرض ویجت
  final double height; // ارتفاع ویجت

  // سازنده با مقادیر پیش‌فرض برای عرض و ارتفاع
  const ApmacoLogo({super.key, this.width = 200, this.height = 80});

  @override
  // متد build - ساخت ویجت لوگو
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: RichText(
          // متن غنی برای نمایش دو بخش با رنگ متفاوت
          text: TextSpan(
            children: [
              TextSpan(
                text: 'apma', // بخش اول لوگو
                style: TextStyle(
                  fontSize: height * 0.5, // اندازه فونت متناسب با ارتفاع
                  fontWeight: FontWeight.bold, // ضخامت بولد
                  color: AppColors.primaryOrange, // رنگ نارنجی
                  fontFamily: 'Vazir', // فونت وزیر
                ),
              ),
              TextSpan(
                text: 'co', // بخش دوم لوگو
                style: TextStyle(
                  fontSize: height * 0.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGray, // رنگ خاکستری
                  fontFamily: 'Vazir',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
