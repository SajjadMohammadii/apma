// یوزکیس ورود به سیستم - پیاده‌سازی منطق تجاری احراز هویت
// مرتبط با: auth_repository.dart, auth_bloc.dart, user.dart, usecase.dart

import 'package:apma_app/core/errors/failures.dart'; // کلاس‌های خطا
import 'package:apma_app/core/usecases/usecase.dart'; // رابط یوزکیس پایه
import 'package:apma_app/features/authentication/domain/entities/user.dart'; // موجودیت کاربر
import 'package:apma_app/features/authentication/domain/repositories/auth_repository.dart'; // ریپازیتوری احراز هویت
import 'package:dartz/dartz.dart'; // کتابخانه Either
import 'package:equatable/equatable.dart'; // کتابخانه مقایسه اشیاء

// کلاس LoginUseCase - یوزکیس برای مدیریت عملیات ورود کاربر
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository; // ریپازیتوری احراز هویت

  // سازنده - دریافت ریپازیتوری
  LoginUseCase(this.repository);

  @override
  // متد call - اجرای عملیات ورود
  // پارامتر params: پارامترهای ورود شامل نام کاربری و رمز عبور
  // برمی‌گرداند: Either شامل Failure یا User
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      username: params.username, // نام کاربری
      password: params.password, // رمز عبور
    );
  }
}

// کلاس LoginParams - پارامترهای مورد نیاز برای عملیات ورود
class LoginParams extends Equatable {
  final String username; // نام کاربری
  final String password; // رمز عبور

  // سازنده - دریافت نام کاربری و رمز عبور
  const LoginParams({required this.username, required this.password});

  @override
  // لیست پراپرتی‌ها برای مقایسه اشیاء
  List<Object> get props => [username, password];
}
