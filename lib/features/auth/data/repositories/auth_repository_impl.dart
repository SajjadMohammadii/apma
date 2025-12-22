// پیاده‌سازی AuthRepository با منابع داده راه دور و محلی
// مرتبط با: auth_repository.dart, auth_remote_datasource.dart, network_info.dart

import 'package:apma_app/core/errors/exceptions.dart'; // کلاس‌های استثنا
import 'package:apma_app/core/errors/failures.dart'; // کلاس‌های خطا
import 'package:apma_app/features/auth/data/datasources/auth_remote_datasource.dart'; // منبع داده راه دور
import 'package:apma_app/features/auth/domain/entities/user.dart'; // موجودیت کاربر
import 'package:apma_app/features/auth/domain/repositories/auth_repository.dart'; // رابط ریپازیتوری
import 'package:dartz/dartz.dart'; // کتابخانه Either

// کلاس AuthRepositoryImpl - پیاده‌سازی ریپازیتوری احراز هویت
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource; // منبع داده راه دور

  // سازنده - دریافت منبع داده راه دور
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  // متد login - ورود کاربر با نام کاربری و رمز عبور
  Future<Either<Failure, User>> login({
    required String username, // نام کاربری
    required String password, // رمز عبور
  }) async {
    try {
      // فراخوانی متد login از منبع داده راه دور
      final user = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(user); // برگرداندن کاربر در صورت موفقیت
    } on AuthenticationException catch (e) {
      // خطای احراز هویت
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      // خطای سرور
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // خطای شبکه
      return Left(NetworkFailure(e.message));
    } catch (e) {
      // خطای غیرمنتظره
      return Left(GeneralFailure('خطای غیرمنتظره: $e'));
    }
  }

  @override
  // متد register - ثبت‌نام کاربر جدید
  Future<Either<Failure, User>> register({
    required String username, // نام کاربری
    required String password, // رمز عبور
    required String email, // ایمیل
  }) async {
    // TODO: پیاده‌سازی ثبت‌نام
    return const Left(GeneralFailure('این قابلیت هنوز پیاده‌سازی نشده است'));
  }

  @override
  // متد logout - خروج کاربر
  Future<Either<Failure, void>> logout() async {
    // TODO: پیاده‌سازی خروج
    return const Right(null); // برگرداندن موفقیت
  }

  @override
  // متد getCurrentUser - دریافت کاربر فعلی
  Future<Either<Failure, User>> getCurrentUser() async {
    // TODO: پیاده‌سازی دریافت کاربر فعلی
    return const Left(GeneralFailure('کاربری وارد نشده است'));
  }

  @override
  // متد isLoggedIn - بررسی ورود کاربر
  Future<Either<Failure, bool>> isLoggedIn() async {
    // TODO: پیاده‌سازی بررسی ورود
    return const Right(false); // برگرداندن false (وارد نشده)
  }
}
