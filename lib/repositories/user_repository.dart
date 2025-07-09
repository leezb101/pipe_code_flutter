/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:55:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:55:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/user/wx_login_vo.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 内存缓存，避免频繁读取存储
  WxLoginVO? _cachedWxLoginVO;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  UserRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// 从存储加载用户数据
  Future<WxLoginVO?> loadUserFromStorage() async {
    try {
      // 检查缓存是否有效
      if (_cachedWxLoginVO != null && _isCacheValid()) {
        return _cachedWxLoginVO;
      }

      final userData = await _storageService.getUserData();
      if (userData == null) {
        _clearUserCache();
        return null;
      }

      final wxLoginVO = WxLoginVO.fromJson(userData);
      
      // 更新缓存
      _cachedWxLoginVO = wxLoginVO;
      _lastCacheTime = DateTime.now();
      return wxLoginVO;
    } catch (e) {
      _clearUserCache();
      return null;
    }
  }

  /// 保存用户数据到存储
  Future<void> saveUserData(WxLoginVO wxLoginVO) async {
    try {
      await _storageService.saveUserData(wxLoginVO.toJson());
      
      // 更新缓存
      _cachedWxLoginVO = wxLoginVO;
      _lastCacheTime = DateTime.now();
    } catch (e) {
      // 保存失败，清除缓存
      _clearUserCache();
      rethrow;
    }
  }

  /// 更新用户基本信息
  Future<WxLoginVO?> updateUserProfile({
    String? name,
    String? nick,
    String? avatar,
    String? address,
    String? phone,
  }) async {
    try {
      final currentUser = await loadUserFromStorage();
      if (currentUser == null) {
        return null;
      }

      // 创建更新后的用户对象
      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        nick: nick ?? currentUser.nick,
        avatar: avatar ?? currentUser.avatar,
        address: address ?? currentUser.address,
        phone: phone ?? currentUser.phone,
      );

      // 保存更新后的用户数据
      await saveUserData(updatedUser);
      return updatedUser;
    } catch (e) {
      return null;
    }
  }

  /// 清除用户数据
  Future<void> clearUserData() async {
    try {
      await _storageService.clearUserData();
      _clearUserCache();
    } catch (e) {
      // 即使清除失败，也要清除缓存
      _clearUserCache();
    }
  }

  /// 获取用户ID
  String? getUserId() {
    return _cachedWxLoginVO?.id;
  }

  /// 获取用户名称
  String? getUserName() {
    return _cachedWxLoginVO?.name;
  }

  /// 获取用户token
  String? getUserToken() {
    return _cachedWxLoginVO?.tk;
  }

  /// 检查缓存是否有效
  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }

  /// 清除用户缓存
  void _clearUserCache() {
    _cachedWxLoginVO = null;
    _lastCacheTime = null;
  }

  /// 刷新用户缓存
  void refreshCache() {
    _clearUserCache();
  }
}