/*
 * @Author: LeeZB
 * @Date: 2025-06-28 13:17:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 17:38:51
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  StorageService(this._prefs);

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(_userIdKey);
  }

  Future<void> saveUsername(String username) async {
    await _prefs.setString(_usernameKey, username);
  }

  String? getUsername() {
    return _prefs.getString(_usernameKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool get isLoggedIn => getAuthToken() != null;

  // Generic storage methods
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  String encodeJsonString(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  Map<String, dynamic> decodeJsonString(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // User data specific methods
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setString('user_data', encodeJsonString(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userDataString = getString('user_data');
    if (userDataString == null) return null;
    return decodeJsonString(userDataString);
  }

  Future<void> clearUserData() async {
    await remove('user_data');
  }

  // Token related methods
  Future<void> saveString(String key, String value) async {
    await setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await setBool(key, value);
  }
}
