// ابزارهای اعتبارسنجی ورودی برای فرم‌ها
// مرتبط با: login_page.dart, فرم‌های ثبت‌نام

// کلاس InputValidator - توابع اعتبارسنجی ورودی
class InputValidator {
  // متد isValidUsername - بررسی معتبر بودن نام کاربری
  // برمی‌گرداند: true اگر نام کاربری معتبر باشد
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false; // نباید خالی باشد
    if (username.length < 3) return false; // حداقل ۳ کاراکتر
    return true;
  }

  // متد isValidPassword - بررسی معتبر بودن رمز عبور
  // برمی‌گرداند: true اگر رمز عبور معتبر باشد
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false; // نباید خالی باشد
    if (password.length < 6) return false; // حداقل ۶ کاراکتر
    return true;
  }

  // متد isValidEmail - بررسی معتبر بودن ایمیل
  // برمی‌گرداند: true اگر فرمت ایمیل صحیح باشد
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false; // نباید خالی باشد
    // الگوی regex برای ایمیل
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email); // تطبیق با الگو
  }

  // متد isValidPhone - بررسی معتبر بودن شماره تلفن ایرانی
  // برمی‌گرداند: true اگر فرمت شماره تلفن صحیح باشد
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false; // نباید خالی باشد
    // الگوی regex برای شماره موبایل ایران (شروع با ۰۹)
    final phoneRegex = RegExp(r'^09\d{9}$');
    return phoneRegex.hasMatch(phone); // تطبیق با الگو
  }
}
