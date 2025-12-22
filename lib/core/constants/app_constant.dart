// مقادیر ثابت و تنظیمات سراسری برنامه
// مرتبط با: app_string.dart, soap_client.dart

// کلاس AppConstants - ثابت‌های عددی و تنظیماتی برنامه
class AppConstants {

  static const String serverUrl = "http://80.210.60.13:12345/erp.asmx";

  // static const String serverUrl = "http://80.210.60.13:16842/erp.asmx";

  // مدت زمان‌ها
  static const Duration splashDuration = Duration(
    seconds: 3,
  ); // مدت نمایش صفحه اسپلش
  static const Duration animationDuration = Duration(
    milliseconds: 300,
  ); // مدت انیمیشن‌ها

  // اندازه‌ها
  static const double borderRadius = 12.0; // شعاع گوشه‌ها
  static const double buttonHeight = 56.0; // ارتفاع دکمه‌ها
  static const double inputHeight = 56.0; // ارتفاع فیلدهای ورودی

  // پدینگ‌ها
  static const double paddingSmall = 8.0; // پدینگ کوچک
  static const double paddingMedium = 16.0; // پدینگ متوسط
  static const double paddingLarge = 24.0; // پدینگ بزرگ
  static const double paddingXLarge = 32.0; // پدینگ خیلی بزرگ

  // لوگو
  static const double logoWidth = 200.0; // عرض لوگو
  static const double logoHeight = 80.0; // ارتفاع لوگو

  // API (برای استفاده آینده)
  static const String baseUrl = 'https://api.apmaco.com'; // آدرس پایه API
  static const Duration connectionTimeout = Duration(
    seconds: 30,
  ); // timeout اتصال
  static const Duration receiveTimeout = Duration(
    seconds: 30,
  ); // timeout دریافت
}
