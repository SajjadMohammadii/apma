// رویدادهای احراز هویت برای مدیریت state با BLoC
// مرتبط با: auth_bloc.dart, auth_state.dart, login_page.dart

import 'package:equatable/equatable.dart'; // کتابخانه مقایسه اشیاء

// کلاس انتزاعی AuthEvent - کلاس پایه برای تمام رویدادهای احراز هویت
abstract class AuthEvent extends Equatable {
  const AuthEvent(); // سازنده

  @override
  List<Object> get props => []; // لیست پراپرتی‌ها برای مقایسه
}

// کلاس LoginEvent - رویداد زمانی که کاربر تلاش می‌کند به صورت دستی وارد شود
class LoginEvent extends AuthEvent {
  final String username; // نام کاربری
  final String password; // رمز عبور

  // سازنده با نام کاربری و رمز عبور اجباری
  const LoginEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password]; // پراپرتی‌ها برای مقایسه
}

// کلاس LogoutEvent - رویداد زمانی که کاربر خارج می‌شود
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// کلاس CheckAuthStatusEvent - رویداد برای بررسی وضعیت فعلی احراز هویت
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

// کلاس AutoLoginEvent - رویداد برای ورود خودکار با اعتبارنامه‌های ذخیره شده
class AutoLoginEvent extends AuthEvent {
  final String username; // نام کاربری
  final String password; // رمز عبور

  // سازنده با نام کاربری و رمز عبور اجباری
  const AutoLoginEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password]; // پراپرتی‌ها برای مقایسه
}
