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
  const SpareQrDownloadRequested();

  @override
  List<Object?> get props => [];
}

class SpareQrReset extends SpareQrEvent {}
