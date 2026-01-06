// قرارداد ریپازیتوری احراز هویت - تعریف عملیات احراز هویت در لایه دامین
// مرتبط با: auth_repository_impl.dart, login_usecase.dart, user.dart

import 'package:apma_app/core/errors/failures.dart'; // کلاس‌های خطا
import 'package:apma_app/features/authentication/domain/entities/user.dart'; // موجودیت کاربر
import 'package:dartz/dartz.dart'; // کتابخانه برنامه‌نویسی تابعی (Either)

/// کلاس انتزاعی AuthRepository - رابط ریپازیتوری برای عملیات احراز هویت
abstract class AuthRepository {
  /// متد login - احراز هویت کاربر با نام کاربری و رمز عبور
  /// پارامتر username: نام کاربری
  /// پارامتر password: رمز عبور
  /// برمی‌گرداند: Either شامل Failure (در صورت خطا) یا User (در صورت موفقیت)
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  /// متد register - ثبت‌نام حساب کاربری جدید
  /// پارامتر username: نام کاربری
  /// پارامتر password: رمز عبور
  /// پارامتر email: آدرس ایمیل
  /// برمی‌گرداند: Either شامل Failure یا User
  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String email,
  });

  /// متد logout - خروج کاربر فعلی از سیستم
  /// برمی‌گرداند: Either شامل Failure یا void
  Future<Either<Failure, void>> logout();

  /// متد getCurrentUser - دریافت کاربر فعلی احراز هویت شده
  /// برمی‌گرداند: Either شامل Failure یا User
  Future<Either<Failure, User>> getCurrentUser();

  /// متد isLoggedIn - بررسی اینکه آیا کاربری وارد شده است
  /// برمی‌گرداند: Either شامل Failure یا bool
  Future<Either<Failure, bool>> isLoggedIn();
}
