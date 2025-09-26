/*
 * @Author: LeeZB
 * @Date: 2025-09-26 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-26 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../services/storage_service.dart';

/// 隐私政策服务
/// 负责管理用户隐私政策同意状态，确保符合加固平台的合规要求
class PrivacyPolicyService {
  final StorageService _storageService;

  static const String _privacyConsentKey = 'privacy_policy_consent';
  static const String _privacyConsentVersionKey =
      'privacy_policy_consent_version';
  static const String _privacyConsentTimestampKey =
      'privacy_policy_consent_timestamp';

  // 当前隐私政策版本，更新内容时需要更新此版本号
  static const String currentPrivacyVersion = '1.0.0';

  PrivacyPolicyService(this._storageService);

  /// 检查用户是否已同意当前版本的隐私政策
  bool hasUserConsentedToCurrentVersion() {
    final hasConsented = _storageService.getBool(_privacyConsentKey) ?? false;
    final consentedVersion =
        _storageService.getString(_privacyConsentVersionKey) ?? '';

    // 用户必须同意，且同意的版本必须是当前版本
    return hasConsented && consentedVersion == currentPrivacyVersion;
  }

  /// 检查是否为首次启动（从未显示过隐私政策）
  bool isFirstLaunch() {
    return !_storageService.containsKey(_privacyConsentKey);
  }

  /// 记录用户同意隐私政策
  Future<void> recordUserConsent() async {
    await _storageService.setBool(_privacyConsentKey, true);
    await _storageService.setString(
      _privacyConsentVersionKey,
      currentPrivacyVersion,
    );
    await _storageService.setString(
      _privacyConsentTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// 记录用户不同意隐私政策
  Future<void> recordUserDenial() async {
    await _storageService.setBool(_privacyConsentKey, false);
    await _storageService.setString(
      _privacyConsentVersionKey,
      currentPrivacyVersion,
    );
    await _storageService.setString(
      _privacyConsentTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// 清除隐私政策同意记录（用于测试或重置）
  Future<void> clearConsentRecord() async {
    await _storageService.remove(_privacyConsentKey);
    await _storageService.remove(_privacyConsentVersionKey);
    await _storageService.remove(_privacyConsentTimestampKey);
  }

  /// 获取用户同意时间
  DateTime? getConsentTimestamp() {
    final timestampStr = _storageService.getString(_privacyConsentTimestampKey);
    if (timestampStr == null) return null;
    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  /// 获取用户同意的隐私政策版本
  String? getConsentedVersion() {
    return _storageService.getString(_privacyConsentVersionKey);
  }

  /// 检查是否需要显示隐私政策（首次启动或版本更新）
  bool shouldShowPrivacyPolicy() {
    return isFirstLaunch() || !hasUserConsentedToCurrentVersion();
  }
}
