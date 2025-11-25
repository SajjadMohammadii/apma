// Remote data source for authentication API calls.
// Relates to: auth_repository_impl.dart, soap_client.dart, user_model.dart

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:apma_app/core/errors/exceptions.dart';
import 'package:apma_app/core/network/soap_client.dart';
import 'package:apma_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> getCurrentUser(String userId);
  Future<void> logout(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SoapClient soapClient;

  static const String webServiceUrl = 'http://80.210.60.13:12345/erp.asmx';
  static const String namespace = 'http://apmaco.com/';

  static const String loginMethodName = 'AuthenticateUser';
  static const String getCurrentUserMethodName = 'LoadPerson';
  static const String logoutMethodName = 'SetPersonLastOnlineTime';

  AuthRemoteDataSourceImpl({required this.soapClient});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    developer.log('🔐 شروع ورود کاربر: $username');
    try {
      final authData = json.encode({
        'Username': username,
        'Password': password,
      });
      final soapActionUrl = '$namespace$loginMethodName';

      final response = await soapClient.call(
        method: loginMethodName,
        parameters: {'data': authData},
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      final resultString = soapClient.extractValue(
        response,
        'AuthenticateUserResult',
      );

      if (resultString == null || resultString.isEmpty) {
        throw AuthenticationException('پاسخ خالی از سرور');
      }

      final Map<String, dynamic> resultJson = json.decode(resultString);

      if (resultJson['Error'] != 0) {
        throw AuthenticationException(resultJson['Message'] ?? 'ورود ناموفق');
      }

      final userId = resultJson['ID'] ?? '';
      final name = resultJson['Name'] ?? username;
      final role = resultJson['Role'] ?? resultJson['PersonRole'] ?? 'کاربر';

      developer.log('✅ ورود موفق: $name (ID: $userId, Role: $role)');

      return UserModel(
        id: userId,
        username: username,
        email: '$username@apmaco.com',
        name: name,
        role: role,
        token: userId,
      );
    } catch (e) {
      developer.log('❌ Login Error: $e');
      throw ServerException('خطا در فرآیند ورود: $e');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String userId) async {
    developer.log('👤 دریافت اطلاعات کاربر $userId');
    try {
      final soapActionUrl = '$namespace$getCurrentUserMethodName';
      final response = await soapClient.call(
        method: getCurrentUserMethodName,
        parameters: {'id': userId},
        namespace: namespace,
        soapAction: soapActionUrl,
      );

      final jsonString =
          soapClient.extractValue(response, 'LoadPersonResult') ?? '{}';
      final Map<String, dynamic> userJson = json.decode(jsonString);

      return UserModel(
        id: userJson['UserId'] ?? '',
        username: userJson['Username'] ?? '',
        email: userJson['Email'] ?? '',
        name: userJson['Name'] ?? '',
        role: userJson['Role'] ?? userJson['PersonRole'] ?? 'کاربر',
        token: userId,
      );
    } catch (e) {
      developer.log('❌ GetCurrentUser Error: $e');
      throw ServerException('خطا در دریافت اطلاعات کاربر: $e');
    }
  }

  @override
  Future<void> logout(String userId) async {
    developer.log('🚪 در حال خروج کاربر $userId');
    try {
      final data = json.encode({'id': userId});
      final soapActionUrl = '$namespace$logoutMethodName';
      await soapClient.call(
        method: logoutMethodName,
        parameters: {'data': data},
        namespace: namespace,
        soapAction: soapActionUrl,
      );
      developer.log('✅ خروج موفق ثبت شد');
    } catch (e) {
      developer.log('❌ Logout Error: $e');
      throw ServerException('خطا در خروج: $e');
    }
  }
}
