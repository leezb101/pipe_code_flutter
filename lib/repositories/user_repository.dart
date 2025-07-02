import '../models/user/user.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 内存缓存，避免频繁读取存储
  User? _cachedUser;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  UserRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  Future<User?> loadUserFromStorage() async {
    try {
      // 检查缓存是否有效
      if (_cachedUser != null && _isCacheValid()) {
        return _cachedUser;
      }

      final userId = _storageService.getUserId();
      final username = _storageService.getUsername();
      if (userId == null || username == null) {
        _clearUserCache();
        return null;
      }

      final userDataString = _storageService.getString('user_data');
      User? user;
      if (userDataString != null) {
        final userData = Map<String, dynamic>.from(
          _storageService.decodeJsonString(userDataString),
        );
        user = User.fromJson(userData);
      } else {
        user = User(id: userId, username: username, email: '');
      }

      // 更新缓存
      _cachedUser = user;
      _lastCacheTime = DateTime.now();
      return user;
    } catch (e) {
      _clearUserCache();
      return null;
    }
  }

  Future<void> saveUserToStorage(User user) async {
    await _storageService.saveUserId(user.id);
    await _storageService.saveUsername(user.username);
    await _storageService.setString(
      'user_data',
      _storageService.encodeJsonString(user.toJson()),
    );
    
    // 更新缓存
    _cachedUser = user;
    _lastCacheTime = DateTime.now();
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.user.getUserProfile();
    final user = User.fromJson(response);
    await saveUserToStorage(user);
    return user;
  }

  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
  }) async {
    final updateData = <String, dynamic>{};
    if (firstName != null) updateData['firstName'] = firstName;
    if (lastName != null) updateData['lastName'] = lastName;
    if (email != null) updateData['email'] = email;
    if (avatar != null) updateData['avatar'] = avatar;

    final response = await _apiService.user.updateUserProfile(data: updateData);
    final user = User.fromJson(response);
    await saveUserToStorage(user);
    return user;
  }

  Future<void> clearUserData() async {
    await _storageService.remove('user_data');
    
    // 清除缓存
    _clearUserCache();
  }

  String? get currentUserId => _storageService.getUserId();
  String? get currentUsername => _storageService.getUsername();

  /// 检查缓存是否仍然有效
  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }

  /// 清除用户缓存
  void _clearUserCache() {
    _cachedUser = null;
    _lastCacheTime = null;
  }

  /// 手动清除所有缓存（用于调试或强制刷新）
  void clearCache() {
    _clearUserCache();
  }
}
