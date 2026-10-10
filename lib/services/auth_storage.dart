import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT and basic user fields after verify / login.
class AuthStorage {
  AuthStorage._();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userEmailKey = 'auth_user_email';

  static Future<void> saveSession({
    required String token,
    String? userId,
    String? userEmail,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
    if (userId != null && userId.isNotEmpty) {
      await p.setString(_userIdKey, userId);
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      await p.setString(_userEmailKey, userEmail);
    }
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
    await p.remove(_userIdKey);
    await p.remove(_userEmailKey);
  }
}
