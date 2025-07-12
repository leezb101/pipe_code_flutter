/*
 * @Author: LeeZB
 * @Date: 2025-07-12 19:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 15:52:36
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'logger.dart';

/// RSA加密工具类
/// 提供基于固定公钥的RSA加密功能，支持密码和通用数据加密
class RSAEncryptionUtil {
  /// 固定的RSA公钥 (Base64格式)
  static const String _publicKeyString = '''
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdLGep37lcc/CL1+NuapkFKT4MWFn0FC2BvA2ZSwVVOzM0hvgRJdVcF7xxbgeV0qXFm6MzS/suPeyT41xhXmFN+xKsg6/qd2Kt3aM9GcEXrMc3bwiOctm0q6BYu3WuavlzoGxYuwYs3ncysz8ZKsJMO2hSNkWOPr7j1HYALYjBLQIDAQAB
-----END PUBLIC KEY-----
''';

  /// 缓存的RSA公钥实例
  static RSAPublicKey? _cachedPublicKey;

  /// 缓存的Encrypter实例
  static Encrypter? _cachedEncrypter;

  /// 加密密码 - 使用时间戳:密码格式
  /// [password] 原始密码
  /// 返回加密后的base64字符串
  static String encryptPassword(String password) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final plaintext = '$timestamp:$password';

      Logger.info('开始RSA密码加密', tag: 'RSA_ENCRYPT');
      Logger.info('加密前格式: $timestamp:[密码已隐藏]', tag: 'RSA_ENCRYPT');

      final encrypted = encryptData(plaintext);

      Logger.info('RSA密码加密成功，密文长度: ${encrypted.length}', tag: 'RSA_ENCRYPT');
      return encrypted;
    } catch (e) {
      Logger.error('RSA密码加密失败: $e', tag: 'RSA_ENCRYPT', error: e);
      rethrow;
    }
  }

  /// 通用数据加密方法
  /// [data] 要加密的数据
  /// 返回加密后的base64字符串
  static String encryptData(String data) {
    try {
      Logger.info('开始RSA数据加密，数据长度: ${data.length}', tag: 'RSA_ENCRYPT');

      final encrypter = _getEncrypter();
      final encrypted = encrypter.encrypt(data);
      final result = encrypted.base64;

      Logger.info('RSA数据加密成功，密文长度: ${result.length}', tag: 'RSA_ENCRYPT');
      return result;
    } catch (e) {
      Logger.error('RSA数据加密失败: $e', tag: 'RSA_ENCRYPT', error: e);
      rethrow;
    }
  }

  /// 获取或创建Encrypter实例
  static Encrypter _getEncrypter() {
    if (_cachedEncrypter != null) {
      return _cachedEncrypter!;
    }

    try {
      final publicKey = _getPublicKey();
      _cachedEncrypter = Encrypter(RSA(publicKey: publicKey));
      Logger.info('RSA Encrypter实例创建成功', tag: 'RSA_ENCRYPT');
      return _cachedEncrypter!;
    } catch (e) {
      Logger.error('创建RSA Encrypter失败: $e', tag: 'RSA_ENCRYPT', error: e);
      rethrow;
    }
  }

  /// 获取或解析RSA公钥
  static RSAPublicKey _getPublicKey() {
    if (_cachedPublicKey != null) {
      return _cachedPublicKey!;
    }

    try {
      Logger.info('开始解析RSA公钥', tag: 'RSA_ENCRYPT');

      // 使用encrypt包解析DER格式公钥
      final parser = RSAKeyParser();
      _cachedPublicKey =
          parser.parse(_formatPublicKeyPEM(_publicKeyString)) as RSAPublicKey;

      Logger.info('RSA公钥解析成功', tag: 'RSA_ENCRYPT');
      Logger.info(
        '公钥模数长度: ${_cachedPublicKey!.modulus!.bitLength} bits',
        tag: 'RSA_ENCRYPT',
      );

      return _cachedPublicKey!;
    } catch (e) {
      Logger.error('RSA公钥解析失败: $e', tag: 'RSA_ENCRYPT', error: e);
      rethrow;
    }
  }

  /// 将Base64公钥格式化为PEM格式
  /// [base64Key] Base64格式的公钥字符串
  static String _formatPublicKeyPEM(String base64Key) {
    const pemHeader = '-----BEGIN PUBLIC KEY-----';
    const pemFooter = '-----END PUBLIC KEY-----';

    // 每64个字符换行
    final formattedKey = base64Key.replaceAllMapped(
      RegExp(r'.{64}'),
      (match) => '${match.group(0)}\n',
    );

    return '$pemHeader\n$formattedKey$pemFooter';
  }

  /// 清除缓存的密钥和加密器实例
  /// 主要用于测试或重置场景
  static void clearCache() {
    _cachedPublicKey = null;
    _cachedEncrypter = null;
    Logger.info('RSA缓存已清除', tag: 'RSA_ENCRYPT');
  }

  /// 验证加密功能是否正常
  /// 返回true表示加密功能可用
  static bool validateEncryption() {
    try {
      const testData = 'test_encryption_validation';
      final encrypted = encryptData(testData);
      final isValid = encrypted.isNotEmpty && encrypted.length > 50;

      Logger.info('RSA加密验证${isValid ? '成功' : '失败'}', tag: 'RSA_ENCRYPT');
      return isValid;
    } catch (e) {
      Logger.error('RSA加密验证失败: $e', tag: 'RSA_ENCRYPT', error: e);
      return false;
    }
  }

  /// 获取当前时间戳
  /// 返回13位毫秒级时间戳
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 创建时间戳格式的数据
  /// [data] 原始数据
  /// 返回格式化后的"时间戳:数据"字符串
  static String createTimestampData(String data) {
    final timestamp = getCurrentTimestamp();
    return '$timestamp:$data';
  }
}
