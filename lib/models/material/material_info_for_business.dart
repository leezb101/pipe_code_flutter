/*
 * @Author: LeeZB
 * @Date: 2025-07-23 11:27:54
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 17:52:41
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'material_info_base.dart';
import 'sync_vendor_data_error.dart';

part 'material_info_for_business.g.dart';

@JsonSerializable()
class MaterialInfoForBusiness extends Equatable {
  final List<MaterialInfoBase> normals;

  final List<SyncVendorDataError> errors;

  const MaterialInfoForBusiness({required this.normals, required this.errors});

  factory MaterialInfoForBusiness.fromJson(Map<String, dynamic> json) =>
      _$MaterialInfoForBusinessFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialInfoForBusinessToJson(this);

  @override
  List<Object?> get props => [normals, errors];
}
