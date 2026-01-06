// منبع داده راه دور برای فراخوانی‌های API احراز هویت
// مرتبط با: auth_repository_impl.dart, soap_client.dart, user_model.dart

import 'dart:convert'; // کتابخانه تبدیل JSON
import 'dart:developer' as developer; // ابزار لاگ‌گیری

import 'package:apma_app/core/errors/exceptions.dart'; // کلاس‌های استثنا
import 'package:apma_app/core/network/soap_client.dart'; // کلاینت SOAP
import 'package:apma_app/features/authentication/data/models/user_model.dart';

import '../../../../core/constants/app_constant.dart'; // مدل کاربر

// کلاس انتزاعی AuthRemoteDataSource - رابط منبع داده راه دور
abstract class AuthRemoteDataSource {
  // متد login - ورود کاربر
  Future<UserModel> login({required String username, required String password});
  // متد getCurrentUser - دریافت کاربر فعلی
  Future<UserModel> getCurrentUser(String userId);
  // متد logout - خروج کاربر
  Future<void> logout(String userId);
}

// کلاس AuthRemoteDataSourceImpl - پیاده‌سازی منبع داده راه دور
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SoapClient soapClient; // کلاینت SOAP برای ارتباط با سرور

  // ثابت‌های URL و namespace وب‌سرویس
  static const String webServiceUrl = AppConstants.serverUrl; // آدرس1 وب‌سرویس
  //static const String webServiceUrl = AppConstants.serverUrl; // آدرس2 وب‌سرویس

  static const String namespace = 'http://apmaco.com/'; // فضای نام SOAP

  // نام متدهای وب‌سرویس
  static const String loginMethodName = 'AuthenticateUser'; // نام متد ورود
  static const String getCurrentUserMethodName =
      'LoadPerson'; // نام متد دریافت کاربر
  static const String logoutMethodName =
      'SetPersonLastOnlineTime'; // نام متد خروج

  // سازنده - دریافت کلاینت SOAP
  AuthRemoteDataSourceImpl({required this.soapClient});

  @override
  // متد login - ورود کاربر با نام کاربری و رمز عبور
  Future<UserModel> login({
    required String username, // نام کاربری
    required String password, // رمز عبور
  }) async {
    developer.log(' شروع ورود کاربر: $username'); // لاگ شروع ورود
    try {
      // ساخت داده‌های احراز هویت به صورت JSON
      final authData = json.encode({
        'Username': username,
        'Password': password,
      });
      final soapActionUrl = '$namespace$loginMethodName'; // آدرس SOAP Action

      // فراخوانی متد SOAP
      final response = await soapClient.call(
        method: loginMethodName,
        parameters: {'data': authData},
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      // استخراج نتیجه از پاسخ
      final resultString = soapClient.extractValue(
        response,
        'AuthenticateUserResult',
      );

      // بررسی پاسخ خالی
      if (resultString == null || resultString.isEmpty) {
        throw AuthenticationException('پاسخ خالی از سرور');
      }

      // تبدیل پاسخ به JSON
      final Map<String, dynamic> resultJson = json.decode(resultString);

      // بررسی خطا در پاسخ
      if (resultJson['Error'] != 0) {
        throw AuthenticationException(resultJson['Message'] ?? 'ورود ناموفق');
      }

      // استخراج اطلاعات کاربر
      final userId = resultJson['ID'] ?? ''; // شناسه کاربر
      final name = resultJson['Name'] ?? username; // نام کاربر
      final role =
          resultJson['Role'] ??
          resultJson['PersonRole'] ??
          'کاربر'; // نقش کاربر

      developer.log(
        ' ورود موفق: $name (ID: $userId, Role: $role)',
      ); // لاگ موفقیت

      // برگرداندن مدل کاربر
      return UserModel(
        id: userId,
        username: username,
        email: '$username@apmaco.com',
        name: name,
        role: role,
        token: userId,
      );
    } catch (e) {
      developer.log(' Login Error: $e'); // لاگ خطا
      throw ServerException('خطا در فرآیند ورود: $e');
    }
  }

  @override
  // متد getCurrentUser - دریافت اطلاعات کاربر با شناسه
  Future<UserModel> getCurrentUser(String userId) async {
    developer.log('👤 دریافت اطلاعات کاربر $userId'); // لاگ شروع
    try {
      final soapActionUrl =
          '$namespace$getCurrentUserMethodName'; // آدرس SOAP Action
      // فراخوانی متد SOAP
      final response = await soapClient.call(
        method: getCurrentUserMethodName,
        parameters: {'id': userId},
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      // استخراج و تبدیل نتیجه به JSON
      final jsonString =
          soapClient.extractValue(response, 'LoadPersonResult') ?? '{}';
      final Map<String, dynamic> userJson = json.decode(jsonString);

      // برگرداندن مدل کاربر
      return UserModel(
        id: userJson['UserId'] ?? '',
        username: userJson['Username'] ?? '',
        email: userJson['Email'] ?? '',
        name: userJson['Name'] ?? '',
        role: userJson['Role'] ?? userJson['PersonRole'] ?? 'کاربر',
        token: userId,
      );
    } catch (e) {
      developer.log(' GetCurrentUser Error: $e'); // لاگ خطا
      throw ServerException('خطا در دریافت اطلاعات کاربر: $e');
    }
  }

  @override
  // متد logout - خروج کاربر با شناسه
  Future<void> logout(String userId) async {
    developer.log(' در حال خروج کاربر $userId'); // لاگ شروع خروج
    try {
      final data = json.encode({'id': userId}); // داده‌های خروج
      final soapActionUrl = '$namespace$logoutMethodName'; // آدرس SOAP Action
      // فراخوانی متد SOAP
      await soapClient.call(
        method: logoutMethodName,
        parameters: {'data': data},
        namespace: namespace,
        soapAction: soapActionUrl,
      );
      developer.log(' خروج موفق ثبت شد'); // لاگ موفقیت
    } catch (e) {
      developer.log(' Logout Error: $e'); // لاگ خطا
      throw ServerException('خطا در خروج: $e');
    }
  }
}
