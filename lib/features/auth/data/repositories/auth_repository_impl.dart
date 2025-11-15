import 'package:apma_app/core/errors/exceptions.dart';
import 'package:apma_app/core/errors/failures.dart';
import 'package:apma_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:apma_app/features/auth/domain/entities/user.dart';
import 'package:apma_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(user);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('خطای غیرمنتظره: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String email,
  }) async {
    // TODO: پیاده‌سازی ثبت‌نام
    return const Left(GeneralFailure('این قابلیت هنوز پیاده‌سازی نشده است'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // TODO: پیاده‌سازی خروج
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // TODO: پیاده‌سازی دریافت کاربر فعلی
    return const Left(GeneralFailure('کاربری وارد نشده است'));
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    // TODO: پیاده‌سازی بررسی ورود
    return const Right(false);
  }
}
