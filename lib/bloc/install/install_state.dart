/*
 * @Author: LeeZB
 * @Date: 2025-07-25 19:28:16
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 20:00:42
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

class InstallState extends Equatable {
  const InstallState();

  @override
  List<Object?> get props => [];
}

class InstallInitial extends InstallState {
  const InstallInitial();
}

class InstallLoading extends InstallState {
  const InstallLoading();
}

class InstallReady extends InstallState {
  const InstallReady({
    this.detail,
    this.materialInfos,
    this.materialScanMessage,
    this.clearScanMessage = true,
  });

  /// 安装详情
  final InstallDetailVo? detail;

  /// 安装扫描到的材料信息
  final MaterialInfoForBusiness? materialInfos;

  final String? materialScanMessage;

  final bool clearScanMessage;

  @override
  List<Object?> get props => [
    detail,
    materialInfos,
    materialScanMessage,
    clearScanMessage,
  ];

  InstallReady copyWith({
    InstallDetailVo? detail,
    MaterialInfoForBusiness? materialInfos,
    String? materialScanMessage,
    bool? clearScanMessage,
  }) {
    return InstallReady(
      detail: detail ?? this.detail,
      materialInfos: materialInfos ?? this.materialInfos,
      materialScanMessage: materialScanMessage ?? this.materialScanMessage,
      clearScanMessage: clearScanMessage ?? this.clearScanMessage,
    );
  }
}

class InstallSubmitting extends InstallState {
  const InstallSubmitting();
}

class InstallSuccess extends InstallState {
  const InstallSuccess();

  @override
  List<Object?> get props => [];
}

class InstallFailure extends InstallState {
  final String error;

  const InstallFailure(this.error);

  @override
  List<Object?> get props => [error];
}
