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
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

/// 单次扫码结果，包含正常材料和异常材料
class ScanResult extends Equatable {
  const ScanResult({
    this.normalMaterial,
    this.errorMaterial,
    required this.scanTime,
  });

  /// 正常材料（如果扫描成功）
  final MaterialInfo? normalMaterial;

  /// 异常材料信息（如果扫描失败）
  final dynamic errorMaterial;

  /// 扫描时间戳，用于排序和唯一标识
  final DateTime scanTime;

  @override
  List<Object?> get props => [normalMaterial, errorMaterial, scanTime];

  ScanResult copyWith({
    MaterialInfo? normalMaterial,
    dynamic errorMaterial,
    DateTime? scanTime,
  }) {
    return ScanResult(
      normalMaterial: normalMaterial ?? this.normalMaterial,
      errorMaterial: errorMaterial ?? this.errorMaterial,
      scanTime: scanTime ?? this.scanTime,
    );
  }
}

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
    this.scanResults = const [],
    this.materialScanMessage,
    this.clearScanMessage = true,
  });

  /// 安装详情
  final InstallDetailVo? detail;

  /// 安装扫描到的材料信息（保留用于向后兼容）
  final MaterialInfoForBusiness? materialInfos;

  /// 所有扫码结果列表（包含正常和异常材料），按扫描顺序排列
  final List<ScanResult> scanResults;

  final String? materialScanMessage;

  final bool clearScanMessage;

  @override
  List<Object?> get props => [
    detail,
    materialInfos,
    scanResults,
    materialScanMessage,
    clearScanMessage,
  ];

  InstallReady copyWith({
    InstallDetailVo? detail,
    MaterialInfoForBusiness? materialInfos,
    List<ScanResult>? scanResults,
    String? materialScanMessage,
    bool? clearScanMessage,
  }) {
    return InstallReady(
      detail: detail ?? this.detail,
      materialInfos: materialInfos ?? this.materialInfos,
      scanResults: scanResults ?? this.scanResults,
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
