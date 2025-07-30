/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:57:49
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:pipe_code_flutter/repositories/interfaces/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  // 内存缓存，避免频繁读取存储
  WxLoginVO? _cachedWxLoginVO;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  UserRepositoryImpl({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  @override
  Future<WxLoginVO?> loadUserFromStorage() async {
    try {
      // 检查缓存是否有效
      if (_cachedWxLoginVO != null && _isCacheValid()) {
        return _cachedWxLoginVO;
      }

      final userData = _storageService.getUserData();
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

  @override
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

  @override
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

  @override
  Future<void> clearUserData() async {
    try {
      await _storageService.clearUserData();
      _clearUserCache();
    } catch (e) {
      // 即使清除失败，也要清除缓存
      _clearUserCache();
    }
  }

  @override
  String? getUserId() {
    return _cachedWxLoginVO?.id;
  }

  @override
  String? getUserName() {
    return _cachedWxLoginVO?.name;
  }

  @override
  String? getUserToken() {
    return _cachedWxLoginVO?.tk;
  }

  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }

  void _clearUserCache() {
    _cachedWxLoginVO = null;
    _lastCacheTime = null;
  }

  @override
  void refreshCache() {
    _clearUserCache();
  }
}
