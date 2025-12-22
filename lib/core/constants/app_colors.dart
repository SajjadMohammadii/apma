// ثابت‌های پالت رنگ برنامه
// مرتبط با: app_theme.dart, کامپوننت‌های UI

import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس AppColors - رنگ‌های ثابت برنامه
class AppColors {
  // رنگ‌های اصلی
  static const Color primaryGreen = Color(0xFF488250); // سبز اصلی
  static const Color primaryOrange = Color(0xFFFF8C42); // نارنجی اصلی
  static const Color primaryGray = Color(0xFFA8A8A8); // خاکستری اصلی
  static const Color primaryPurple = Color(0xFF4A4667); // بنفش اصلی

  // رنگ‌های پس‌زمینه
  static const Color backgroundColor = primaryGreen; // رنگ پس‌زمینه کلی
  static const Color cardBackground = Colors.white; // رنگ پس‌زمینه کارت‌ها

  // رنگ‌های متن
  static const Color textPrimary = Color(0xFF2C2C2C); // متن اصلی (تیره)
  static const Color textSecondary = Color(0xFF757575); // متن ثانویه (خاکستری)
  static const Color textHint = Color(0xFFBDBDBD); // متن راهنما (کم‌رنگ)
  static const Color textWhite = Colors.white; // متن سفید

  // رنگ‌های دکمه
  static const Color buttonPrimary = primaryPurple; // دکمه اصلی
  static const Color buttonDisabled = Color(0xFFE0E0E0); // دکمه غیرفعال

  // رنگ‌های ورودی
  static const Color inputBackground = Colors.white; // پس‌زمینه فیلد ورودی
  static const Color inputBorder = Color(0xFFE0E0E0); // حاشیه فیلد ورودی
  static const Color inputFocused = primaryOrange; // حاشیه هنگام فوکوس

  // رنگ‌های وضعیت
  static const Color success = Color(0xFF4CAF50); // موفقیت (سبز)
  static const Color error = Color(0xFFF44336); // خطا (قرمز)
  static const Color warning = Color(0xFFFF9800); // هشدار (نارنجی)
  static const Color info = Color(0xFF2196F3); // اطلاعات (آبی)
}
