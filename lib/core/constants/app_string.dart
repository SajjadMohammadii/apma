// ثابت‌های متنی و رشته‌ای برنامه
// مرتبط با: login_page.dart, splash_screen.dart, صفحات UI

// کلاس AppStrings - تمام رشته‌های ثابت برنامه
class AppStrings {
  // نام برنامه
  static const String appName = 'Apmaco'; // نام برنامه

  // رشته‌های صفحه ورود
  static const String username = 'نام کاربری'; // برچسب نام کاربری
  static const String password = 'رمز عبور'; // برچسب رمز عبور
  static const String login = 'ورود'; // متن دکمه ورود
  static const String loginTitle = 'خوش آمدید'; // عنوان صفحه ورود
  static const String forgotPassword = 'فراموشی رمز عبور'; // لینک فراموشی رمز
  static const String dontHaveAccount = 'حساب کاربری ندارید؟'; // متن ثبت‌نام
  static const String register = 'ثبت نام'; // لینک ثبت‌نام

  // پیام‌های اعتبارسنجی
  static const String emptyUsername =
      'نام کاربری نمی‌تواند خالی باشد'; // خطای نام کاربری خالی
  static const String emptyPassword =
      'رمز عبور نمی‌تواند خالی باشد'; // خطای رمز عبور خالی
  static const String invalidUsername =
      'نام کاربری نامعتبر است'; // خطای نام کاربری نامعتبر
  static const String invalidPassword =
      'رمز عبور باید حداقل 6 کاراکتر باشد'; // خطای رمز کوتاه

  // پیام‌های خطا
  static const String generalError = 'خطایی رخ داده است'; // خطای عمومی
  static const String networkError = 'خطا در اتصال به اینترنت'; // خطای شبکه
  static const String serverError = 'خطا در سرور'; // خطای سرور
  static const String unauthorizedError =
      'نام کاربری یا رمز عبور اشتباه است'; // خطای احراز هویت

  // پیام‌های موفقیت
  static const String loginSuccess = 'ورود موفقیت‌آمیز'; // پیام ورود موفق
}
