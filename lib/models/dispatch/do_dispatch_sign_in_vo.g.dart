// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'do_dispatch_sign_in_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoDispatchSignInVo _$DoDispatchSignInVoFromJson(Map<String, dynamic> json) =>
    DoDispatchSignInVo(
      dispatchId: (json['dispatchId'] as num).toInt(),
      materialList: (json['materialList'] as List<dynamic>)
          .map((e) => MaterialVO.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageList: (json['imageList'] as List<dynamic>)
          .map((e) => AttachmentVO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DoDispatchSignInVoToJson(DoDispatchSignInVo instance) =>
    <String, dynamic>{
      'dispatchId': instance.dispatchId,
      'materialList': instance.materialList,
      'imageList': instance.imageList,
    };
