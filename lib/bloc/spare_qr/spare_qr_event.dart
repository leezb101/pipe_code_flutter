/*
 * @Author: LeeZB
 * @Date: 2025-07-16 11:57:02
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 14:28:09
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';

abstract class SpareQrEvent extends Equatable {
  const SpareQrEvent();

  @override
  List<Object?> get props => [];
}

class SpareQrDownloadRequested extends SpareQrEvent {
  final int num;
  
  const SpareQrDownloadRequested({required this.num});

  @override
  List<Object?> get props => [num];
}

class SpareQrReset extends SpareQrEvent {}

class SpareQrResetWithFileCleanup extends SpareQrEvent {
  final String filePath;
  
  const SpareQrResetWithFileCleanup({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class SpareQrFileShared extends SpareQrEvent {
  final String filePath;
  
  const SpareQrFileShared({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
