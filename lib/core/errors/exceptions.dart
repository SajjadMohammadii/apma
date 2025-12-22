// کلاس‌های  برای سناریوهای مختلف خطا
// مرتبط با: failures.dart, auth_remote_datasource.dart

// کلاس ServerException -  خطاهای سرور
class ServerException implements Exception {
  final String message; // پیام خطا

  ServerException(this.message); // سازنده

  @override
  String toString() => message; // تبدیل به رشته
}

// کلاس NetworkException -  خطاهای شبکه
class NetworkException implements Exception {
  final String message; // پیام خطا

  NetworkException(this.message); // سازنده

  @override
  String toString() => message; // تبدیل به رشته
}

// کلاس CacheException -  خطاهای کش
class CacheException implements Exception {
  final String message; // پیام خطا

  CacheException(this.message); // سازنده

  @override
  String toString() => message; // تبدیل به رشته
}

// کلاس AuthenticationException -  خطاهای احراز هویت
class AuthenticationException implements Exception {
  final String message; // پیام خطا

  AuthenticationException(this.message); // سازنده

  @override
  String toString() => message; // تبدیل به رشته
}

// کلاس ValidationException -  خطاهای اعتبارسنجی
class ValidationException implements Exception {
  final String message; // پیام خطا

  ValidationException(this.message); // سازنده

  @override
  String toString() => message; // تبدیل به رشته
}
