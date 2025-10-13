// android_speech_service.dart

import 'dart:async';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:xf_asr_plugin/xf_asr_plugin.dart';
import 'base_speech_service.dart';

/// Android端语音识别服务实现
/// 使用讯飞语音识别插件
class AndroidSpeechService implements BaseSpeechService {
  final _xfAsrPlugin = XfAsrPlugin.instance;
  final _statusStreamController = StreamController<String>.broadcast();

  StreamSubscription<XfAsrResult>? _resultSubscription;
  StreamSubscription<XfAsrError>? _errorSubscription;
  StreamSubscription<String>? _statusSubscription;

  Function(String)? _currentOnResult;
  bool _isInitialized = false;

  @override
  Stream<String> get statusStream => _statusStreamController.stream;

  @override
  bool get isSupported => true;

  @override
  Future<void> ensureInitialized() async {
    if (_isInitialized) {
      Logger.debug('讯飞语音识别SDK已经初始化', tag: '【speech】');
      return;
    }

    try {
      final config = XfAsrConfig(
        appId: 'f0e6c8d9',
        apiKey: 'd9c19d358fadd22dbc5e8b7aa01e0e5f',
        apiSecret: 'MTJiMmUxNmUxOWIzMGQxNzgzODgwZjNh',
        language: 'zh_cn',
        domain: 'iat',
        accent: 'mandarin',
      );

      Logger.info('开始初始化讯飞语音识别SDK...', tag: '【speech】');

      final success = await _xfAsrPlugin.initialize(config);

      if (success) {
        Logger.info('讯飞语音识别SDK初始化成功', tag: '【speech】');
        _isInitialized = true;
        _setupEventListeners();
      } else {
        Logger.error('讯飞语音识别SDK初始化失败', tag: '【speech】');
        throw Exception('讯飞语音识别SDK初始化失败');
      }
    } catch (e) {
      Logger.error('初始化讯飞语音识别SDK异常: $e', tag: '【speech】');
      rethrow;
    }
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    // 监听识别结果
    _resultSubscription?.cancel();
    _resultSubscription = _xfAsrPlugin.onResult.listen((result) {
      Logger.debug(
        '收到识别结果: ${result.text}, isLast: ${result.isLast}',
        tag: '【speech】',
      );
      _currentOnResult?.call(result.text);

      // 如果是最终结果，更新状态为非监听状态
      if (result.isLast) {
        _statusStreamController.add('done');
      }
    });

    // 监听识别错误
    _errorSubscription?.cancel();
    _errorSubscription = _xfAsrPlugin.onError.listen((error) {
      Logger.error('语音识别错误: ${error.message} (${error.code})', tag: '【speech】');
      _statusStreamController.add('error');
    });

    // 监听状态变化
    _statusSubscription?.cancel();
    _statusSubscription = _xfAsrPlugin.onStatusChanged.listen((status) {
      Logger.debug('语音识别状态变化: $status', tag: '【speech】');
      _statusStreamController.add(status);
    });

    Logger.debug('讯飞语音识别事件监听器设置完成', tag: '【speech】');
  }

  @override
  void startListening({required Function(String) onResult}) {
    if (!_isInitialized) {
      Logger.warning('SDK未初始化，无法开始语音识别', tag: '【speech】');
      return;
    }

    Logger.info('开始语音识别...', tag: '【speech】');
    _currentOnResult = onResult;

    _xfAsrPlugin
        .startListening()
        .then((success) {
          if (success) {
            Logger.info('语音识别启动成功', tag: '【speech】');
          } else {
            Logger.error('语音识别启动失败', tag: '【speech】');
            _statusStreamController.add('error');
          }
        })
        .catchError((error) {
          Logger.error('启动语音识别异常: $error', tag: '【speech】');
          _statusStreamController.add('error');
        });
  }

  @override
  void stopListening() {
    if (!_isInitialized) {
      Logger.warning('SDK未初始化，无法停止语音识别', tag: '【speech】');
      return;
    }

    Logger.info('停止语音识别...', tag: '【speech】');

    _xfAsrPlugin
        .stopListening()
        .then((success) {
          if (success) {
            Logger.info('语音识别已停止', tag: '【speech】');
          } else {
            Logger.warning('停止语音识别失败', tag: '【speech】');
          }
        })
        .catchError((error) {
          Logger.error('停止语音识别异常: $error', tag: '【speech】');
        });
  }

  @override
  void dispose() {
    Logger.info('释放语音识别服务资源...', tag: '【speech】');

    _resultSubscription?.cancel();
    _errorSubscription?.cancel();
    _statusSubscription?.cancel();
    _statusStreamController.close();

    _xfAsrPlugin.dispose();
    _isInitialized = false;
    _currentOnResult = null;

    Logger.info('语音识别服务资源已释放', tag: '【speech】');
  }
}
