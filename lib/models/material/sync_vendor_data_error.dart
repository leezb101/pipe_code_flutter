/*
 * @Author: LeeZB
 * @Date: 2025-07-23 11:30:23
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 11:33:33
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'sync_vendor_data_error.g.dart';

@JsonSerializable()
class SyncVendorDataError extends Equatable {
  /// 材料二维码（厂家产品唯一编号）
  final String? qrCode;

  /// 厂家编码
  final String? code;

  /// 厂家名称
  final String? name;

  /// 失败原因
  final String? msg;

  const SyncVendorDataError({this.qrCode, this.code, this.name, this.msg});

  factory SyncVendorDataError.fromJson(Map<String, dynamic> json) =>
      _$SyncVendorDataErrorFromJson(json);

  Map<String, dynamic> toJson() => _$SyncVendorDataErrorToJson(this);

  @override
  List<Object?> get props => [qrCode, code, name, msg];
}
