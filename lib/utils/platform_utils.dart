// platform_utils.dart

import 'dart:io';

class PlatformUtils {
  /// 检查是否为iOS平台
  static bool get isIOS => Platform.isIOS;

  /// 检查是否为Android平台
  static bool get isAndroid => Platform.isAndroid;

  /// 检查是否支持语音识别（目前仅iOS支持）
  static bool get supportsSpeechToText => isIOS || isAndroid;

  /// 获取当前平台名称
  static String get platformName {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
