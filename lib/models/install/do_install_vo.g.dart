// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_install_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoInstallVo _$DoInstallVoFromJson(Map<String, dynamic> json) => DoInstallVo(
  materialList: (json['materialList'] as List<dynamic>)
      .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  imageList: (json['imageList'] as List<dynamic>)
      .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
      .toList(),
  installQualityUrl: json['installQualityUrl'] as String?,
  onlyInstall: json['onlyInstall'] as bool? ?? false,
  signOutId: (json['signOutId'] as num).toInt(),
);

Map<String, dynamic> _$DoInstallVoToJson(DoInstallVo instance) =>
    <String, dynamic>{
      'materialList': instance.materialList,
      'imageList': instance.imageList,
      'installQualityUrl': instance.installQualityUrl,
      'onlyInstall': instance.onlyInstall,
      'signOutId': instance.signOutId,
    };
