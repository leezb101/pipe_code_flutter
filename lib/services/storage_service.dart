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

  // -------------------------
  // User-scoped helpers
  // -------------------------
  /// Try to get current logged-in user's id from saved user_data or user_id key.
  String? getCurrentUserId() {
    // Prefer user_data.id
    final userData = getUserData();
    final idFromUserData = userData != null
        ? (userData['id']?.toString())
        : null;
    if (idFromUserData != null && idFromUserData.isNotEmpty) {
      return idFromUserData;
    }

    // Fallback to explicit user_id key if present
    final id = getUserId();
    if (id != null && id.isNotEmpty) return id;
    return null;
  }

  /// Build a user-scoped key. If [userId] is null, returns the base key.
  String userScopedKey(String baseKey, {String? userId}) {
    final uid = userId ?? getCurrentUserId();
    if (uid == null || uid.isEmpty) return baseKey;
    return 'user:$uid:$baseKey';
  }

  /// Set a value for a user-scoped String key.
  Future<void> setUserString(
    String baseKey,
    String value, {
    String? userId,
  }) async {
    await setString(userScopedKey(baseKey, userId: userId), value);
  }

  /// Get a value for a user-scoped String key.
  String? getUserString(String baseKey, {String? userId}) {
    return getString(userScopedKey(baseKey, userId: userId));
  }

  /// Remove a user-scoped key.
  Future<void> removeUserKey(String baseKey, {String? userId}) async {
    await remove(userScopedKey(baseKey, userId: userId));
  }

  /// Check existence of a user-scoped key.
  bool containsUserKey(String baseKey, {String? userId}) {
    return containsKey(userScopedKey(baseKey, userId: userId));
  }

  /// Set a value for a user-scoped Int key.
  Future<void> setUserInt(String baseKey, int value, {String? userId}) async {
    await setInt(userScopedKey(baseKey, userId: userId), value);
  }

  /// Get a value for a user-scoped Int key.
  int? getUserInt(String baseKey, {String? userId}) {
    return getInt(userScopedKey(baseKey, userId: userId));
  }

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

  // -------------------------
  // Migration helpers (legacy -> user scoped)
  // -------------------------
  /// Migrate a single legacy key to user-scoped key if scoped key doesn't exist yet.
  Future<void> migrateLegacyKeyToUserScoped(
    String baseKey, {
    String? userId,
  }) async {
    final uid = userId ?? getCurrentUserId();
    final legacy = getString(baseKey);
    final scopedKey = userScopedKey(baseKey, userId: uid);
    final hasScoped = containsKey(scopedKey);
    if (legacy != null && !hasScoped) {
      await setString(scopedKey, legacy);
      // Remove legacy to avoid cross-user leakage
      await remove(baseKey);
    }
  }

  /// Convenience: migrate common project-related keys.
  Future<void> migrateProjectRelatedKeys({String? userId}) async {
    // Keys we care about for per-user isolation
    const keys = <String>[
      'current_project_id',
      'current_user_role_info',
      'last_selected_project_id',
      // NOTE: some versions may have written this unused key;
      // migrate the raw string anyway for completeness.
      'current_project_role_info',
    ];
    for (final k in keys) {
      await migrateLegacyKeyToUserScoped(k, userId: userId);
    }
  }

  // -------------------------
  // User remembered info management
  // -------------------------
  /// Clear remembered info for current user (non-sensitive preferences),
  /// e.g., last_selected_project_id and its timestamp. Optionally pass extra
  /// base keys to clear along with the defaults.
  Future<void> clearUserRememberedInfo({
    List<String> extraBaseKeys = const [],
  }) async {
    final keys = <String>{
      'last_selected_project_id',
      'last_selected_project_id_ts',
      ...extraBaseKeys,
    };
    for (final k in keys) {
      await removeUserKey(k);
      // Also clear legacy global key just in case
      await remove(k);
    }
  }
}
