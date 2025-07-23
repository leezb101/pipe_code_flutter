/*
 * @Author: LeeZB
 * @Date: 2025-07-23 11:27:54
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 11:33:51
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'material_info_base.dart';
import 'sync_vendor_data_error.dart';

part 'material_info_for_business.g.dart';

@JsonSerializable()
class MaterialInfoForBusiness extends Equatable {
  final List<MaterialInfoBase> normal;

  final List<SyncVendorDataError> error;

  const MaterialInfoForBusiness({required this.normal, required this.error});

  factory MaterialInfoForBusiness.fromJson(Map<String, dynamic> json) =>
      _$MaterialInfoForBusinessFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialInfoForBusinessToJson(this);

  @override
  List<Object?> get props => [normal, error];
}
