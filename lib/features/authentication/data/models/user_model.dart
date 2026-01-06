// مدل داده گسترش‌دهنده موجودیت User با قابلیت‌های سریال‌سازی
// مرتبط با: user.dart, auth_remote_datasource.dart, auth_repository_impl.dart

import 'package:apma_app/features/authentication/domain/entities/user.dart'; // موجودیت کاربر

// کلاس UserModel - مدل داده کاربر با سریال‌سازی JSON/XML برای یکپارچگی با API
class UserModel extends User {
  final String? token; // توکن احراز هویت (اختیاری)

  // سازنده کلاس با پارامترهای اجباری و اختیاری
  const UserModel({
    required super.id, // شناسه کاربر
    required super.username, // نام کاربری
    super.email, // ایمیل
    super.name, // نام
    super.avatar, // آواتار
    super.role, // نقش
    this.token, // توکن
  });

  // متد کارخانه fromJson - دیسریالایز کردن کاربر از پاسخ JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '', // شناسه کاربر
      username: json['username'] as String? ?? '', // نام کاربری
      email: json['email'] as String?, // ایمیل
      name: json['name'] as String?, // نام
      avatar: json['avatar'] as String?, // آواتار
      role: json['role'] as String?, // نقش
      token: json['token'] as String?, // توکن
    );
  }

  // متد toJson - سریال‌سازی کاربر به فرمت JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id, // شناسه
      'username': username, // نام کاربری
      'email': email, // ایمیل
      'name': name, // نام
      'avatar': avatar, // آواتار
      'role': role, // نقش
      'token': token, // توکن
    };
  }

  // متد کارخانه fromXml - دیسریالایز کردن کاربر از پاسخ SOAP XML
  factory UserModel.fromXml(Map<String, String> xmlData) {
    return UserModel(
      id: xmlData['UserId'] ?? xmlData['id'] ?? '', // شناسه کاربر
      username: xmlData['Username'] ?? xmlData['username'] ?? '', // نام کاربری
      email: xmlData['Email'] ?? xmlData['email'], // ایمیل
      name: xmlData['Name'] ?? xmlData['name'], // نام
      avatar: xmlData['Avatar'] ?? xmlData['avatar'], // آواتار
      role: xmlData['Role'] ?? xmlData['role'], // نقش
      token: xmlData['Token'] ?? xmlData['token'], // توکن
    );
  }

  // متد copyWith - ایجاد کپی با فیلدهای تغییر یافته
  UserModel copyWith({
    String? id, // شناسه جدید
    String? username, // نام کاربری جدید
    String? email, // ایمیل جدید
    String? name, // نام جدید
    String? avatar, // آواتار جدید
    String? role, // نقش جدید
    String? token, // توکن جدید
  }) {
    return UserModel(
      id: id ?? this.id, // استفاده از مقدار جدید یا فعلی
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
