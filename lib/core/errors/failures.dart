// کلاس‌های خطا برای مدیریت خطا در سراسر برنامه
// مرتبط با: exceptions.dart, auth_repository.dart, auth_bloc.dart

import 'package:equatable/equatable.dart'; // کتابخانه مقایسه اشیاء

// کلاس انتزاعی Failure - کلاس پایه برای تمام خطاها
abstract class Failure extends Equatable {
  final String message; // پیام خطا
  const Failure(this.message); // سازنده

  @override
  List<Object?> get props => [message]; // پراپرتی‌ها برای مقایسه
}

// کلاس ServerFailure - خطاهای سرور
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// کلاس NetworkFailure - خطاهای شبکه
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// کلاس CacheFailure - خطاهای کش
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// کلاس AuthenticationFailure - خطاهای احراز هویت
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

// کلاس ValidationFailure - خطاهای اعتبارسنجی
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// کلاس GeneralFailure - خطاهای عمومی
class GeneralFailure extends Failure {
  const GeneralFailure(super.message);
}
