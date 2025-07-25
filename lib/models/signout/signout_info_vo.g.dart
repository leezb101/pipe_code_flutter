// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signout_info_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignoutInfoVo _$SignoutInfoVoFromJson(Map<String, dynamic> json) =>
    SignoutInfoVo(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      messageTo:
          (json['messageTo'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      warehouseId: (json['warehouseId'] as num?)?.toInt(),
      warehouseName: json['warehouseName'] as String?,
      warehouseUsers: (json['warehouseUsers'] as List<dynamic>)
          .map((e) => CommonUserVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      installUserId: (json['installUserId'] as num?)?.toInt(),
      installUserName: json['installUserName'] as String?,
      installInfo: json['installInfo'] == null
          ? null
          : DoInstallVo.fromJson(json['installInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SignoutInfoVoToJson(SignoutInfoVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'messageTo': instance.messageTo,
      'warehouseId': instance.warehouseId,
      'warehouseName': instance.warehouseName,
      'warehouseUsers': instance.warehouseUsers,
      'installUserId': instance.installUserId,
      'installUserName': instance.installUserName,
      'installInfo': instance.installInfo,
    };
