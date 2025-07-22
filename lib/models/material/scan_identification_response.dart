/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 17:16:21
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';
import 'material_info_base.dart';

part 'scan_identification_response.g.dart';

/// 扫码识别响应数据
@JsonSerializable()
class ScanIdentificationData extends Equatable {
  const ScanIdentificationData({
    required this.info,
    this.projectName,
    required this.projectId,
    this.projectAddress,
    required this.materialCode,
    required this.cut,
    required this.type,
    required this.group,
    this.lat,
    this.lng,
    this.img,
    this.accepts,
    this.history,
    this.installs,
  });

  /// 材料详细信息
  final MaterialInfo info;

  /// 项目名称
  final String? projectName;

  /// 项目ID
  final int projectId;

  /// 项目地址
  final String? projectAddress;

  /// 材料编码
  final String materialCode;

  /// 是否切割
  final bool cut;

  /// 材料类型（对应MaterialTypeEnum的值）
  @JsonKey(name: 'type')
  final int type;

  /// 材料分组（对应MaterialGroupEnum的值）
  @JsonKey(name: 'group')
  final int group;

  /// 纬度
  final double? lat;

  /// 经度
  final double? lng;

  /// 图片
  final String? img;

  /// 验收信息
  final dynamic accepts;

  /// 历史信息
  final dynamic history;

  /// 安装信息
  final dynamic installs;

  /// 获取材料类型枚举
  MaterialType get materialType =>
      MaterialType.fromInt(type) ?? MaterialType(type, '未知类型');

  /// 获取材料分组枚举
  MaterialGroup get materialGroup =>
      MaterialGroup.fromInt(group) ?? MaterialGroup(group, '未知类型');

  factory ScanIdentificationData.fromJson(Map<String, dynamic> json) =>
      _$ScanIdentificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$ScanIdentificationDataToJson(this);

  @override
  List<Object?> get props => [
    info,
    projectName,
    projectId,
    projectAddress,
    materialCode,
    cut,
    type,
    group,
    lat,
    lng,
    img,
    accepts,
    history,
    installs,
  ];
}

/// 扫码识别API响应
@JsonSerializable()
class ScanIdentificationResponse extends Equatable {
  const ScanIdentificationResponse({
    required this.code,
    required this.msg,
    this.tc,
    required this.data,
    required this.success,
  });

  /// 响应码
  final int code;

  /// 响应消息
  final String msg;

  /// 时间戳
  final dynamic tc;

  /// 响应数据
  final ScanIdentificationData data;

  /// 是否成功
  final bool success;

  /// 是否成功响应
  bool get isSuccess => code == 0 && success;

  factory ScanIdentificationResponse.fromJson(Map<String, dynamic> json) =>
      _$ScanIdentificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ScanIdentificationResponseToJson(this);

  @override
  List<Object?> get props => [code, msg, tc, data, success];
}
