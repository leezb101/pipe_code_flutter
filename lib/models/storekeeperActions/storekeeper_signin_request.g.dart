// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storekeeper_signin_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorekeeperSigninRequest _$StorekeeperSigninRequestFromJson(
  Map<String, dynamic> json,
) => StorekeeperSigninRequest(
  materialIds: (json['materialIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warehouseId: (json['warehouseId'] as num).toInt(),
  img: json['img'] as String,
  describe: json['describe'] as String?,
);

Map<String, dynamic> _$StorekeeperSigninRequestToJson(
  StorekeeperSigninRequest instance,
) => <String, dynamic>{
  'materialIds': instance.materialIds,
  'warehouseId': instance.warehouseId,
  'img': instance.img,
  'describe': instance.describe,
};
