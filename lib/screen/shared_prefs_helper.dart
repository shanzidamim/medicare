import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SPrefs {
  static const _userIdKey = 'user_id';
  static const _userTypeKey = 'user_type';
  static const _tokenKey = 'access_token';
  static const _divisionKey = 'division_name';
  static const _isLoggedInKey = 'is_logged_in';
  static const _nameKey = 'name';

  /// Save full session
  static Future<void> saveSession({
    required String token,
    required int userId,
    required int userType,
    required String divisionName,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setInt(_userTypeKey, userType);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_divisionKey, divisionName);
    await prefs.setString(_nameKey, name ?? '');
    await prefs.setBool(_isLoggedInKey, true);
    debugPrint("✅ Session saved (userId=$userId, userType=$userType)");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<int?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userTypeKey);
  }

  static Future<String> getDivisionName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_divisionKey) ?? 'Dhaka';
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<Map<String, dynamic>?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!isIn) return null;
    return {
      'user_id': prefs.getInt(_userIdKey),
      'user_type': prefs.getInt(_userTypeKey),
      'access_token': prefs.getString(_tokenKey),
      'division_name': prefs.getString(_divisionKey) ?? 'Dhaka',
      'name': prefs.getString(_nameKey) ?? '',
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_divisionKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_isLoggedInKey);
    debugPrint("🚪 Session cleared");
  }
}
