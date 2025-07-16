/*
 * @Author: LeeZB
 * @Date: 2025-07-16 11:57:02
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 13:26:40
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';

abstract class SpareQrState extends Equatable {
  const SpareQrState();

  @override
  List<Object?> get props => [];
}

class SpareQrInitial extends SpareQrState {}

class SpareQrInProgress extends SpareQrState {
  final double progress;

  const SpareQrInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class SpareQrSuccess extends SpareQrState {
  final String filePath; // 下载成功后文件路径
  const SpareQrSuccess(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SpareQrFailure extends SpareQrState {
  final String error;
  const SpareQrFailure(this.error);

  @override
  List<Object?> get props => [error];
}
