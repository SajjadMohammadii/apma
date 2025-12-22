// موجودیت دامین کاربر - نمایانگر یک کاربر در سیستم احراز هویت
// مرتبط با: user_model.dart, auth_repository.dart, login_usecase.dart

import 'package:equatable/equatable.dart'; // کتابخانه مقایسه اشیاء

// کلاس User - موجودیت کاربر با اطلاعات احراز هویت و پروفایل
class User extends Equatable {
  final String id; // شناسه یکتای کاربر
  final String username; // نام کاربری
  final String? email; // آدرس ایمیل (اختیاری)
  final String? name; // نام کامل کاربر (اختیاری)
  final String? avatar; // آدرس تصویر پروفایل (اختیاری)
  final String? role; // نقش کاربر (اختیاری)

  // سازنده کلاس - دریافت اطلاعات کاربر
  const User({
    required this.id, // شناسه اجباری
    required this.username, // نام کاربری اجباری
    this.email, // ایمیل اختیاری
    this.name, // نام اختیاری
    this.avatar, // آواتار اختیاری
    this.role, // نقش اختیاری
  });

  @override
  // لیست پراپرتی‌ها برای مقایسه دو شیء User
  List<Object?> get props => [id, username, email, name, avatar, role];
}
