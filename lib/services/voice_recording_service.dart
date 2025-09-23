// voice_recording_service.dart

import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';
import 'package:record/record.dart';
import 'package:pipe_code_flutter/services/base_voice_recording_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/upload_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// 基于 record 库的语音录制服务实现
class VoiceRecordingService extends BaseVoiceRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final UploadApiService _uploadService;

  // 状态控制器
  final StreamController<VoiceRecordingStatus> _statusController =
      StreamController<VoiceRecordingStatus>.broadcast();
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // 录制相关
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Function(String filePath)? _onResult;
  Function(String error)? _onError;

  VoiceRecordingService(this._uploadService);

  @override
  Stream<VoiceRecordingStatus> get statusStream => _statusController.stream;

  @override
  Stream<double> get progressStream => _progressController.stream;

  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  bool get isSupported => true; // record 库支持多平台

  @override
  Future<void> initialize() async {
    try {
      // 检查权限
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          throw Exception('录音权限被拒绝');
        }
      }
      Logger.info('语音录制服务初始化完成', tag: '【VoiceRecording】');
    } catch (e) {
      Logger.error('语音录制服务初始化失败: $e', tag: '【VoiceRecording】');
      _emitError('初始化失败: $e');
    }
  }

  @override
  Future<void> startRecording({
    required Function(String filePath) onResult,
    Function(String error)? onError,
  }) async {
    try {
      _onResult = onResult;
      _onError = onError;

      // 检查是否已在录制
      if (await _recorder.isRecording()) {
        Logger.warning('录制已在进行中', tag: '【VoiceRecording】');
        return;
      }

      _emitStatus(VoiceRecordingStatus.recording);

      // 生成录制文件路径
      _currentRecordingPath = await _generateRecordingPath();
      _recordingStartTime = DateTime.now();

      // 开始录制
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc, // 使用 AAC 编码，兼容性好
          bitRate: 128000, // 128kbps
          sampleRate: 44100, // 44.1kHz
        ),
        path: _currentRecordingPath!,
      );

      Logger.info('开始录制语音: $_currentRecordingPath', tag: '【VoiceRecording】');

      // 启动录制进度定时器（可选，显示录制时长）
      _startRecordingTimer();
    } catch (e) {
      Logger.error('开始录制失败: $e', tag: '【VoiceRecording】');
      _emitError('开始录制失败: $e');
      _handleError('开始录制失败: $e');
    }
  }

  @override
  Future<void> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) {
        Logger.warning('没有正在进行的录制', tag: '【VoiceRecording】');
        return;
      }

      // 停止录制
      final recordingPath = await _recorder.stop();
      _stopRecordingTimer();

      if (recordingPath == null || recordingPath.isEmpty) {
        throw Exception('录制文件路径为空');
      }

      Logger.info('录制完成: $recordingPath', tag: '【VoiceRecording】');

      // 检查录制文件是否存在
      final file = File(recordingPath);
      if (!await file.exists()) {
        throw Exception('录制文件不存在');
      }

      // 计算录制时长
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds
          : 0;

      Logger.info(
        '录制时长: ${duration}ms, 文件大小: ${await file.length()}bytes',
        tag: '【VoiceRecording】',
      );

      // 开始上传
      _emitStatus(VoiceRecordingStatus.uploading);
      await _uploadRecording(file, duration);
    } catch (e) {
      Logger.error('停止录制失败: $e', tag: '【VoiceRecording】');
      _emitError('停止录制失败: $e');
      _handleError('停止录制失败: $e');
    }
  }

  @override
  Future<void> cancelRecording() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      _stopRecordingTimer();

      // 删除录制文件
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          Logger.info(
            '已删除录制文件: $_currentRecordingPath',
            tag: '【VoiceRecording】',
          );
        }
      }

      _currentRecordingPath = null;
      _recordingStartTime = null;
      _emitStatus(VoiceRecordingStatus.idle);

      Logger.info('录制已取消', tag: '【VoiceRecording】');
    } catch (e) {
      Logger.error('取消录制失败: $e', tag: '【VoiceRecording】');
      _emitError('取消录制失败: $e');
    }
  }

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// 上传录制文件
  Future<void> _uploadRecording(File file, int duration) async {
    try {
      _emitStatus(VoiceRecordingStatus.uploading);

      // 获取authBloc中的token
      final sessionState = getIt<SessionBloc>().state;
      String? token;
      if (sessionState is SessionProjectEstablished ||
          sessionState is SessionStorekeeperEstablished) {
        token = (sessionState.user as WxLoginVO?)?.tk;
      }
      if (token == null) {
        _emitError('用户未认证，无法上传');
        return;
      }

      _uploadService.setAuthToken(token);
      final result = await _uploadService.uploadFile(
        file,
        onProgress: (progress) {
          _progressController.add(progress);
        },
      );

      if (result.isSuccess && result.data != null) {
        final serverPath = result.data!.filePath;
        Logger.info('录音文件上传成功: $serverPath', tag: '【VoiceRecording】');

        // 通知结果
        _emitStatus(VoiceRecordingStatus.completed);
        if (_onResult != null) {
          _onResult!(serverPath);
        }

        // 可选：删除本地文件以节省空间
        await _cleanupLocalFile();
      } else {
        throw Exception('上传失败: ${result.msg}');
      }
    } catch (e) {
      Logger.error('上传录制文件失败: $e', tag: '【VoiceRecording】');
      _emitError('上传失败: $e');
      _handleError('上传失败: $e');
    }
  }

  /// 生成录制文件路径
  Future<String> _generateRecordingPath() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'voice_recording_$timestamp.aac';
    return '${tempDir.path}/$fileName';
  }

  /// 启动录制定时器
  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingStartTime != null) {
        final elapsed = DateTime.now().difference(_recordingStartTime!);
        // 这里可以发送录制时长更新，或者限制最大录制时间
        Logger.debug('录制中: ${elapsed.inSeconds}秒', tag: '【VoiceRecording】');
      }
    });
  }

  /// 停止录制定时器
  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// 清理本地文件
  Future<void> _cleanupLocalFile() async {
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
        Logger.info('已清理本地录制文件', tag: '【VoiceRecording】');
      }
    }
    _currentRecordingPath = null;
    _recordingStartTime = null;
  }

  /// 发送状态更新
  void _emitStatus(VoiceRecordingStatus status) {
    _statusController.add(status);
  }

  /// 发送错误信息
  void _emitError(String error) {
    _errorController.add(error);
  }

  /// 处理错误
  void _handleError(String error) {
    _emitStatus(VoiceRecordingStatus.error);
    if (_onError != null) {
      _onError!(error);
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _stopRecordingTimer();
    _statusController.close();
    _progressController.close();
    _errorController.close();
    Logger.info('语音录制服务已释放', tag: '【VoiceRecording】');
  }
}
