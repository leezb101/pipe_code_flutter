// base_voice_recording_service.dart

import 'dart:async';

/// 语音录制服务状态
enum VoiceRecordingStatus {
  idle,
  recording,
  processing,
  uploading,
  completed,
  error,
}

/// 语音录制服务的基础抽象类
/// 提供录音、上传、获取文件路径等功能
abstract class BaseVoiceRecordingService {
  /// 录制状态流
  Stream<VoiceRecordingStatus> get statusStream;

  /// 录制进度流 (0.0 - 1.0)
  Stream<double> get progressStream;

  /// 错误信息流
  Stream<String> get errorStream;

  /// 初始化录制服务
  Future<void> initialize();

  /// 开始录制
  /// [onResult] 录制完成并上传后的回调，包含服务器返回的文件路径
  Future<void> startRecording({
    required Function(String filePath) onResult,
    Function(String error)? onError,
  });

  /// 停止录制
  Future<void> stopRecording();

  /// 取消录制
  Future<void> cancelRecording();

  /// 检查录制权限
  Future<bool> hasPermission();

  /// 请求录制权限
  Future<bool> requestPermission();

  /// 检查当前平台是否支持录制
  bool get isSupported;

  /// 释放资源
  void dispose();
}

/// 录制结果
class VoiceRecordingResult {
  final String localPath;
  final String serverPath;
  final int duration; // 录制时长，毫秒
  final int fileSize; // 文件大小，字节
  final DateTime recordingTime;

  VoiceRecordingResult({
    required this.localPath,
    required this.serverPath,
    required this.duration,
    required this.fileSize,
    required this.recordingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'localPath': localPath,
      'serverPath': serverPath,
      'duration': duration,
      'fileSize': fileSize,
      'recordingTime': recordingTime.toIso8601String(),
    };
  }

  factory VoiceRecordingResult.fromJson(Map<String, dynamic> json) {
    return VoiceRecordingResult(
      localPath: json['localPath'] ?? '',
      serverPath: json['serverPath'] ?? '',
      duration: json['duration'] ?? 0,
      fileSize: json['fileSize'] ?? 0,
      recordingTime: json['recordingTime'] != null
          ? DateTime.parse(json['recordingTime'])
          : DateTime.now(),
    );
  }
}
