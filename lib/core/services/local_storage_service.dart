// سرویس ذخیره‌سازی محلی پایدار و مدیریت سشن
// مرتبط با: auth_bloc.dart, login_page.dart

import 'package:shared_preferences/shared_preferences.dart'; // کتابخانه ذخیره‌سازی محلی

// کلاس LocalStorageService - سرویس ذخیره‌سازی داده‌های محلی
class LocalStorageService {
  // کلیدهای ثابت برای ذخیره داده‌ها
  static const String _isLoggedInKey = 'isLoggedIn'; // کلید وضعیت ورود
  static const String _userUsernameKey = 'userUsername'; // کلید نام کاربری
  static const String _userNameKey = 'userName'; // کلید نام کاربر
  static const String _userRoleKey = 'userRole'; // کلید نقش کاربر
  static const String _userPasswordKey = 'userPassword'; // کلید رمز عبور
  static const String _userTokenKey = 'userToken'; // کلید توکن
  static const String _savePasswordKey = 'savePassword'; // کلید ذخیره رمز

  late SharedPreferences _prefs; // نمونه SharedPreferences

  // متد init - مقداردهی اولیه SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // بخش مدیریت ورود و سشن
  // متد saveUserSession - ذخیره سشن کاربر
  Future<void> saveUserSession({
    required String username, // نام کاربری
    required String name, // نام کاربر
    required String token, // توکن
    String? role, // نقش (اختیاری)
    required String personId,
  }) async {
    await _prefs.setBool(_isLoggedInKey, true); // تنظیم وضعیت ورود به true
    await _prefs.setString(_userUsernameKey, username); // ذخیره نام کاربری
    await _prefs.setString(_userNameKey, name); // ذخیره نام
    await _prefs.setString(_userTokenKey, token); // ذخیره توکن
    if (role != null) {
      await _prefs.setString(_userRoleKey, role); // ذخیره نقش اگر موجود باشد
    }
    await _prefs.setString('personId', personId);
    print('localStorage_personId ذخیره شد: $personId');
  }
  String? get personId => _prefs.getString('personId');

  // متد savePassword - ذخیره رمز عبور
  Future<void> savePassword(String password, String username) async {
    await _prefs.setBool(_savePasswordKey, true); // فعال کردن ذخیره رمز
    await _prefs.setString(_userPasswordKey, password); // ذخیره رمز عبور
    await _prefs.setString(_userUsernameKey, username); // ذخیره نام کاربری
  }

  // getter isSavePasswordEnabled - آیا ذخیره رمز فعال است
  bool get isSavePasswordEnabled => _prefs.getBool(_savePasswordKey) ?? false;

  // getter savedPassword - دریافت رمز عبور ذخیره شده (اگر فعال باشد)
  String? get savedPassword =>
      isSavePasswordEnabled ? _prefs.getString(_userPasswordKey) : null;

  // getter isLoggedIn - آیا کاربر وارد شده است
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  // getter savedUsername - دریافت نام کاربری ذخیره شده
  String? get savedUsername => _prefs.getString(_userUsernameKey);

  // getter savedName - دریافت نام ذخیره شده
  String? get savedName => _prefs.getString(_userNameKey);

  // getter savedRole - دریافت نقش ذخیره شده
  String? get savedRole => _prefs.getString(_userRoleKey);

  // getter savedToken - دریافت توکن ذخیره شده
  String? get savedToken => _prefs.getString(_userTokenKey);

  // متد clearUserData - پاکسازی داده‌های کاربر (بدون نام کاربری)
  Future<void> clearUserData() async {
    await _prefs.remove(_isLoggedInKey); // حذف وضعیت ورود
    await _prefs.remove(_userNameKey); // حذف نام
    await _prefs.remove(_userRoleKey); // حذف نقش
    await _prefs.remove(_userTokenKey); // حذف توکن
    // username را نگه دار
  }

  // متد clearPassword - پاکسازی رمز عبور ذخیره شده
  Future<void> clearPassword() async {
    await _prefs.remove(_userPasswordKey); // حذف رمز عبور
    await _prefs.setBool(_savePasswordKey, false); // غیرفعال کردن ذخیره رمز
  }

  // متد logout - خروج کاربر
  Future<void> logout() async {
    await clearUserData(); // پاکسازی داده‌های سشن
    // فقط session را پاک کن، username و password را نگه دار
  }
}
