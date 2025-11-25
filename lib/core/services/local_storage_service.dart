// Service for persistent local data storage and session management.
// Relates to: auth_bloc.dart, login_page.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userUsernameKey = 'userUsername';
  static const String _userNameKey = 'userName';
  static const String _userRoleKey = 'userRole';
  static const String _userPasswordKey = 'userPassword';
  static const String _userTokenKey = 'userToken';
  static const String _savePasswordKey = 'savePassword';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Login & Session Management
  Future<void> saveUserSession({
    required String username,
    required String name,
    required String token,
    String? role,
  }) async {
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userUsernameKey, username);
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userTokenKey, token);
    if (role != null) {
      await _prefs.setString(_userRoleKey, role);
    }
  }

  Future<void> savePassword(String password, String username) async {
    await _prefs.setBool(_savePasswordKey, true);
    await _prefs.setString(_userPasswordKey, password);
    await _prefs.setString(_userUsernameKey, username);
  }

  bool get isSavePasswordEnabled => _prefs.getBool(_savePasswordKey) ?? false;

  String? get savedPassword =>
      isSavePasswordEnabled ? _prefs.getString(_userPasswordKey) : null;

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  String? get savedUsername => _prefs.getString(_userUsernameKey);

  String? get savedName => _prefs.getString(_userNameKey);

  String? get savedRole => _prefs.getString(_userRoleKey);

  String? get savedToken => _prefs.getString(_userTokenKey);

  Future<void> clearUserData() async {
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userRoleKey);
    await _prefs.remove(_userTokenKey);
    // username را نگه دار
  }

  Future<void> clearPassword() async {
    await _prefs.remove(_userPasswordKey);
    await _prefs.setBool(_savePasswordKey, false);
  }

  Future<void> logout() async {
    await clearUserData();
    // فقط session را پاک کن، username و password را نگه دار
  }
}
