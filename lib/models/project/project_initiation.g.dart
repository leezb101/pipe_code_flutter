// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_initiation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectInitiation _$ProjectInitiationFromJson(Map<String, dynamic> json) =>
    ProjectInitiation(
      id: (json['id'] as num?)?.toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String,
      projectStart: json['projectStart'] as String,
      projectEnd: json['projectEnd'] as String,
      supplyType: (json['supplyType'] as num).toInt(),
      projectReportUrl: json['projectReportUrl'] as String?,
      publishBidUrl: json['publishBidUrl'] as String?,
      aimBidUrl: json['aimBidUrl'] as String?,
      otherDocUrl: json['otherDocUrl'] as String?,
      supplierList:
          (json['supplierList'] as List<dynamic>?)
              ?.map((e) => ProjectSupplier.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      materialList:
          (json['materialList'] as List<dynamic>?)
              ?.map((e) => ProjectMaterial.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      constructionUserList:
          (json['constructionUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      supervisorUserList:
          (json['supervisorUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      builderUserList:
          (json['builderUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProjectInitiationToJson(ProjectInitiation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'projectStart': instance.projectStart,
      'projectEnd': instance.projectEnd,
      'supplyType': instance.supplyType,
      'projectReportUrl': instance.projectReportUrl,
      'publishBidUrl': instance.publishBidUrl,
      'aimBidUrl': instance.aimBidUrl,
      'otherDocUrl': instance.otherDocUrl,
      'supplierList': instance.supplierList,
      'materialList': instance.materialList,
      'constructionUserList': instance.constructionUserList,
      'supervisorUserList': instance.supervisorUserList,
      'builderUserList': instance.builderUserList,
    };

ProjectSupplier _$ProjectSupplierFromJson(Map<String, dynamic> json) =>
    ProjectSupplier(
      orgCode: json['orgCode'] as String,
      orgName: json['orgName'] as String,
    );

Map<String, dynamic> _$ProjectSupplierToJson(ProjectSupplier instance) =>
    <String, dynamic>{'orgCode': instance.orgCode, 'orgName': instance.orgName};

ProjectMaterial _$ProjectMaterialFromJson(Map<String, dynamic> json) =>
    ProjectMaterial(
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
      typeName: json['typeName'] as String,
      needNum: (json['needNum'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectMaterialToJson(ProjectMaterial instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'typeName': instance.typeName,
      'needNum': instance.needNum,
    };

ProjectUser _$ProjectUserFromJson(Map<String, dynamic> json) => ProjectUser(
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  orgName: json['orgName'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$ProjectUserToJson(ProjectUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'code': instance.code,
      'orgName': instance.orgName,
      'phone': instance.phone,
    };

ProjectListItem _$ProjectListItemFromJson(Map<String, dynamic> json) =>
    ProjectListItem(
      id: (json['id'] as num).toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String,
      projectStart: json['projectStart'] as String,
      projectEnd: json['projectEnd'] as String,
      createdName: json['createdName'] as String,
      createdId: (json['createdId'] as num).toInt(),
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectListItemToJson(ProjectListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'projectStart': instance.projectStart,
      'projectEnd': instance.projectEnd,
      'createdName': instance.createdName,
      'createdId': instance.createdId,
      'status': instance.status,
    };

ProjectDetail _$ProjectDetailFromJson(Map<String, dynamic> json) =>
    ProjectDetail(
      id: (json['id'] as num).toInt(),
      projectName: json['projectName'] as String,
      projectCode: json['projectCode'] as String,
      projectStart: json['projectStart'] as String,
      projectEnd: json['projectEnd'] as String,
      projectReportUrl: json['projectReportUrl'] as String?,
      publishBidUrl: json['publishBidUrl'] as String?,
      aimBidUrl: json['aimBidUrl'] as String?,
      otherDocUrl: json['otherDocUrl'] as String?,
      status: (json['status'] as num).toInt(),
      supplyType: (json['supplyType'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      createdName: json['createdName'] as String,
      createdId: json['createdId'] as String,
      auditOpinion: json['auditOpinion'] as String?,
      auditTime: json['auditTime'] as String?,
      auditName: json['auditName'] as String?,
      auditId: json['auditId'] as String?,
      materialList:
          (json['materialList'] as List<dynamic>?)
              ?.map((e) => ProjectMaterial.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      constructionUserList:
          (json['constructionUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      supervisorUserList:
          (json['supervisorUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      builderUserList:
          (json['builderUserList'] as List<dynamic>?)
              ?.map((e) => ProjectUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProjectDetailToJson(ProjectDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectName': instance.projectName,
      'projectCode': instance.projectCode,
      'projectStart': instance.projectStart,
      'projectEnd': instance.projectEnd,
      'projectReportUrl': instance.projectReportUrl,
      'publishBidUrl': instance.publishBidUrl,
      'aimBidUrl': instance.aimBidUrl,
      'otherDocUrl': instance.otherDocUrl,
      'status': instance.status,
      'supplyType': instance.supplyType,
      'type': instance.type,
      'createdName': instance.createdName,
      'createdId': instance.createdId,
      'auditOpinion': instance.auditOpinion,
      'auditTime': instance.auditTime,
      'auditName': instance.auditName,
      'auditId': instance.auditId,
      'materialList': instance.materialList,
      'constructionUserList': instance.constructionUserList,
      'supervisorUserList': instance.supervisorUserList,
      'builderUserList': instance.builderUserList,
    };
