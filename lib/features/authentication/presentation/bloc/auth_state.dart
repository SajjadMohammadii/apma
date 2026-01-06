// وضعیت‌های احراز هویت - نمایانگر مراحل مختلف احراز هویت
// مرتبط با: auth_bloc.dart, auth_event.dart, login_page.dart

import 'package:apma_app/features/authentication/domain/entities/user.dart'; // موجودیت کاربر
import 'package:equatable/equatable.dart'; // کتابخانه مقایسه اشیاء

// کلاس انتزاعی AuthState - کلاس پایه برای تمام وضعیت‌های احراز هویت
abstract class AuthState extends Equatable {
  const AuthState(); // سازنده

  @override
  List<Object?> get props => []; // لیست پراپرتی‌ها برای مقایسه
}

// کلاس AuthInitial - وضعیت اولیه (هنوز هیچ عملیاتی انجام نشده)
class AuthInitial extends AuthState {
  const AuthInitial();
}

// کلاس AuthLoading - وضعیت در حال بارگذاری (عملیات در حال انجام است)
class AuthLoading extends AuthState {
  const AuthLoading();
}

// کلاس AuthAuthenticated - وضعیت احراز هویت شده (کاربر با موفقیت وارد شده)
class AuthAuthenticated extends AuthState {
  final User user; // کاربر احراز هویت شده
  final bool showSavePasswordDialog; // آیا دیالوگ ذخیره رمز نمایش داده شود

  // سازنده با کاربر و گزینه نمایش دیالوگ
  const AuthAuthenticated(this.user, {this.showSavePasswordDialog = false});

  @override
  List<Object> get props => [user, showSavePasswordDialog]; // پراپرتی‌ها برای مقایسه
}

// کلاس AuthUnauthenticated - وضعیت خارج شده (کاربر وارد نشده)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// کلاس AuthError - وضعیت خطا (خطایی رخ داده)
class AuthError extends AuthState {
  final String message; // پیام خطا

  const AuthError(this.message); // سازنده با پیام خطا

  @override
  List<Object> get props => [message]; // پراپرتی‌ها برای مقایسه
}
