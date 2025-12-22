// تنظیمات تم برنامه برای متریال دیزاین
// مرتبط با: main.dart, app_colors.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/core/constants/app_constant.dart'; // ثابت‌های برنامه
import 'package:flutter/material.dart'; // ویجت‌های متریال

// کلاس AppTheme - تم‌های برنامه
class AppTheme {
  // getter lightTheme - تم روشن برنامه
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // استفاده از Material 3
      fontFamily: 'Vazir', // فونت پیش‌فرض وزیر
      // طرح رنگ
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen, // رنگ اصلی
        secondary: AppColors.primaryOrange, // رنگ ثانویه
        surface: Colors.white, // رنگ پس‌زمینه
        error: AppColors.error, // رنگ خطا
      ),

      // پس‌زمینه Scaffold
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // تم AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryGreen, // پس‌زمینه AppBar
        foregroundColor: AppColors.textWhite, // رنگ متن و آیکون
        elevation: 0, // بدون سایه
        centerTitle: true, // عنوان در مرکز
        titleTextStyle: TextStyle(
          fontFamily: 'Vazir',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
      ),

      // تم فیلدهای ورودی
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // پر شده با رنگ
        fillColor: AppColors.inputBackground, // رنگ پس‌زمینه
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingMedium,
        ),
        border: OutlineInputBorder(
          // حاشیه پیش‌فرض
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none, // بدون خط
        ),
        enabledBorder: OutlineInputBorder(
          // حاشیه فعال
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          // حاشیه هنگام فوکوس
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.inputFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          // حاشیه هنگام خطا
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: AppColors.textHint,
          fontSize: 14,
        ), // استایل راهنما
      ),

      // تم دکمه ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary, // رنگ پس‌زمینه
          foregroundColor: AppColors.textWhite, // رنگ متن
          minimumSize: Size(
            double.infinity,
            AppConstants.buttonHeight,
          ), // اندازه حداقل
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          elevation: 0, // بدون سایه
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Vazir',
          ),
        ),
      ),

      // تم متن‌ها
      textTheme: TextTheme(
        displayLarge: TextStyle(
          // متن نمایشی بزرگ
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          // متن نمایشی متوسط
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          // متن نمایشی کوچک
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          // عنوان متوسط
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          // عنوان بزرگ
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ), // متن بدنه بزرگ
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ), // متن بدنه متوسط
        labelLarge: TextStyle(
          // برچسب بزرگ
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
