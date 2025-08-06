// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cutting_history_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CuttingHistoryNode _$CuttingHistoryNodeFromJson(Map<String, dynamic> json) =>
    CuttingHistoryNode(
      materialId: (json['materialId'] as num).toInt(),
      parentId: json['parentId'] as String?,
      rootId: (json['rootId'] as num).toInt(),
      len: json['len'] as String?,
      cutTime: json['cutTime'] as String?,
      img: json['img'] as String?,
      cutUserName: json['cutUserName'] as String?,
      cutUserId: (json['cutUserId'] as num).toInt(),
      cutUserPhone: json['cutUserPhone'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => CuttingHistoryNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentId: json['currentId'] as String?,
    );

Map<String, dynamic> _$CuttingHistoryNodeToJson(CuttingHistoryNode instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'parentId': instance.parentId,
      'rootId': instance.rootId,
      'len': instance.len,
      'cutTime': instance.cutTime,
      'img': instance.img,
      'cutUserName': instance.cutUserName,
      'cutUserId': instance.cutUserId,
      'cutUserPhone': instance.cutUserPhone,
      'children': instance.children,
      'currentId': instance.currentId,
    };
