import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum CameraStatus { initial, initializing, ready, capturing, error }

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final String? error;
  final String? capturedImagePath;

  const CameraState({
    this.status = CameraStatus.initial,
    this.controller,
    this.error,
    this.capturedImagePath,
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    String? error,
    String? capturedImagePath,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      error: error ?? this.error,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
    );
  }
}

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(const CameraState());

  CameraController? _controller;

  /// 初始化相机
  Future<void> initializeCamera() async {
    try {
      emit(state.copyWith(status: CameraStatus.initializing));

      // 获取可用相机列表
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(state.copyWith(status: CameraStatus.error, error: '没有可用的相机设备'));
        return;
      }

      // 选择后置相机，如果没有则使用第一个相机
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // 创建相机控制器
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // 初始化相机控制器
      await _controller!.initialize();

      emit(state.copyWith(status: CameraStatus.ready, controller: _controller));
    } catch (e) {
      emit(state.copyWith(status: CameraStatus.error, error: '相机初始化失败: $e'));
    }
  }

  /// 拍照并返回图片路径
  Future<String?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      emit(state.copyWith(error: '相机未初始化'));
      return null;
    }

    try {
      emit(state.copyWith(status: CameraStatus.capturing));

      // 拍照
      final XFile imageFile = await _controller!.takePicture();

      // 生成唯一的文件名
      final directory = await getTemporaryDirectory();
      final fileName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);

      // 复制文件到临时目录
      await File(imageFile.path).copy(filePath);

      emit(
        state.copyWith(status: CameraStatus.ready, capturedImagePath: filePath),
      );

      return filePath;
    } catch (e) {
      emit(state.copyWith(status: CameraStatus.error, error: '拍照失败: $e'));
      return null;
    }
  }

  /// 释放相机资源
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      // 忽略释放时的错误
    }
    super.close();
  }
}
