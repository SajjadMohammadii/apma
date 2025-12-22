// رابط پایه یوزکیس بر اساس اصول معماری تمیز (Clean Architecture)
// مرتبط با: login_usecase.dart, auth_repository.dart

import 'package:apma_app/core/errors/failures.dart'; // کلاس‌های خطا
import 'package:dartz/dartz.dart'; // کتابخانه Either

/// کلاس انتزاعی UseCase - رابط عمومی یوزکیس برای عملیات منطق تجاری
/// Type: نوع خروجی یوزکیس
/// Params: نوع پارامترهای ورودی
abstract class UseCase<Type, Params> {
  // متد call - اجرای یوزکیس با پارامترهای داده شده
  // برمی‌گرداند: Either شامل Failure (در صورت خطا) یا Type (در صورت موفقیت)
  Future<Either<Failure, Type>> call(Params params);
}

// کلاس NoParams - جایگزین برای یوزکیس‌هایی که پارامتر نیاز ندارند
class NoParams {}
