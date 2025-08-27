// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'install_detail_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallDetailVo _$InstallDetailVoFromJson(Map<String, dynamic> json) =>
    InstallDetailVo(
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      installQualityUrl: json['installQualityUrl'] as String?,
      onlyInstall: json['onlyInstall'] as bool?,
      signOutId: (json['signOutId'] as num).toInt(),
    );

Map<String, dynamic> _$InstallDetailVoToJson(InstallDetailVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'installQualityUrl': instance.installQualityUrl,
      'onlyInstall': instance.onlyInstall,
      'signOutId': instance.signOutId,
    };
