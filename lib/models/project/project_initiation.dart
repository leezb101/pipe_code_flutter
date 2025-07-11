/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'project_initiation.g.dart';

/// 项目立项模型
/// 对应API文档中的ProjectSaveVO
@JsonSerializable()
class ProjectInitiation extends Equatable {
  const ProjectInitiation({
    this.id,
    required this.projectName,
    required this.projectCode,
    required this.projectStart,
    required this.projectEnd,
    required this.supplyType,
    this.projectReportUrl,
    this.publishBidUrl,
    this.aimBidUrl,
    this.otherDocUrl,
    this.supplierList = const [],
    this.materialList = const [],
    this.constructionUserList = const [],
    this.supervisorUserList = const [],
    this.builderUserList = const [],
  });

  /// 项目ID（编辑时使用）
  final int? id;

  /// 项目名称
  final String projectName;

  /// 项目编号
  final String projectCode;

  /// 项目开始时间
  final String projectStart;

  /// 项目结束时间
  final String projectEnd;

  /// 供材类型 (0甲供材1乙供材2混合供材)
  final int supplyType;

  /// 立项报告上传URL
  final String? projectReportUrl;

  /// 招标文件上传URL
  final String? publishBidUrl;

  /// 中标文件上传URL
  final String? aimBidUrl;

  /// 其他文件上传URL
  final String? otherDocUrl;

  /// 供应商列表
  final List<ProjectSupplier> supplierList;

  /// 项目需求物料列表
  final List<ProjectMaterial> materialList;

  /// 建设方负责人列表
  final List<ProjectUser> constructionUserList;

  /// 监理方负责人列表
  final List<ProjectUser> supervisorUserList;

  /// 施工方负责人列表
  final List<ProjectUser> builderUserList;

  factory ProjectInitiation.fromJson(Map<String, dynamic> json) =>
      _$ProjectInitiationFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectInitiationToJson(this);

  ProjectInitiation copyWith({
    int? id,
    String? projectName,
    String? projectCode,
    String? projectStart,
    String? projectEnd,
    int? supplyType,
    String? projectReportUrl,
    String? publishBidUrl,
    String? aimBidUrl,
    String? otherDocUrl,
    List<ProjectSupplier>? supplierList,
    List<ProjectMaterial>? materialList,
    List<ProjectUser>? constructionUserList,
    List<ProjectUser>? supervisorUserList,
    List<ProjectUser>? builderUserList,
  }) {
    return ProjectInitiation(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      projectStart: projectStart ?? this.projectStart,
      projectEnd: projectEnd ?? this.projectEnd,
      supplyType: supplyType ?? this.supplyType,
      projectReportUrl: projectReportUrl ?? this.projectReportUrl,
      publishBidUrl: publishBidUrl ?? this.publishBidUrl,
      aimBidUrl: aimBidUrl ?? this.aimBidUrl,
      otherDocUrl: otherDocUrl ?? this.otherDocUrl,
      supplierList: supplierList ?? this.supplierList,
      materialList: materialList ?? this.materialList,
      constructionUserList: constructionUserList ?? this.constructionUserList,
      supervisorUserList: supervisorUserList ?? this.supervisorUserList,
      builderUserList: builderUserList ?? this.builderUserList,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectName,
        projectCode,
        projectStart,
        projectEnd,
        supplyType,
        projectReportUrl,
        publishBidUrl,
        aimBidUrl,
        otherDocUrl,
        supplierList,
        materialList,
        constructionUserList,
        supervisorUserList,
        builderUserList,
      ];
}

/// 供应商信息
@JsonSerializable()
class ProjectSupplier extends Equatable {
  const ProjectSupplier({
    required this.orgCode,
    required this.orgName,
  });

  /// 供应商编码
  final String orgCode;

  /// 供应商名称
  final String orgName;

  factory ProjectSupplier.fromJson(Map<String, dynamic> json) =>
      _$ProjectSupplierFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSupplierToJson(this);

  @override
  List<Object?> get props => [orgCode, orgName];
}

/// 项目物料
@JsonSerializable()
class ProjectMaterial extends Equatable {
  const ProjectMaterial({
    required this.name,
    required this.type,
    required this.typeName,
    required this.needNum,
  });

  /// 物料名称
  final String name;

  /// 物料类型
  final int type;

  /// 物料类型名称
  final String typeName;

  /// 需求数量
  final int needNum;

  factory ProjectMaterial.fromJson(Map<String, dynamic> json) =>
      _$ProjectMaterialFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMaterialToJson(this);

  @override
  List<Object?> get props => [name, type, typeName, needNum];
}

/// 项目用户
@JsonSerializable()
class ProjectUser extends Equatable {
  const ProjectUser({
    required this.userId,
    required this.name,
    required this.code,
    required this.orgName,
    required this.phone,
  });

  /// 用户ID
  final int userId;

  /// 用户姓名
  final String name;

  /// 用户所在组织机构代码
  final String code;

  /// 用户所在公司名称
  final String orgName;

  /// 用户手机号
  final String phone;

  factory ProjectUser.fromJson(Map<String, dynamic> json) =>
      _$ProjectUserFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectUserToJson(this);

  @override
  List<Object?> get props => [userId, name, code, orgName, phone];
}

/// 项目列表项
@JsonSerializable()
class ProjectListItem extends Equatable {
  const ProjectListItem({
    required this.id,
    required this.projectName,
    required this.projectCode,
    required this.projectStart,
    required this.projectEnd,
    required this.createdName,
    required this.createdId,
    required this.status,
  });

  /// 项目ID
  final int id;

  /// 项目名称
  final String projectName;

  /// 项目编号
  final String projectCode;

  /// 项目开始时间
  final String projectStart;

  /// 项目结束时间
  final String projectEnd;

  /// 创建者姓名
  final String createdName;

  /// 创建者ID
  final int createdId;

  /// 状态
  final int status;

  factory ProjectListItem.fromJson(Map<String, dynamic> json) =>
      _$ProjectListItemFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectListItemToJson(this);

  @override
  List<Object?> get props => [
        id,
        projectName,
        projectCode,
        projectStart,
        projectEnd,
        createdName,
        createdId,
        status,
      ];
}

/// 项目详情
@JsonSerializable()
class ProjectDetail extends Equatable {
  const ProjectDetail({
    required this.id,
    required this.projectName,
    required this.projectCode,
    required this.projectStart,
    required this.projectEnd,
    this.projectReportUrl,
    this.publishBidUrl,
    this.aimBidUrl,
    this.otherDocUrl,
    required this.status,
    required this.supplyType,
    required this.type,
    required this.createdName,
    required this.createdId,
    this.auditOpinion,
    this.auditTime,
    this.auditName,
    this.auditId,
    this.materialList = const [],
    this.constructionUserList = const [],
    this.supervisorUserList = const [],
    this.builderUserList = const [],
  });

  /// 项目ID
  final int id;

  /// 项目名称
  final String projectName;

  /// 项目编号
  final String projectCode;

  /// 项目开始时间
  final String projectStart;

  /// 项目结束时间
  final String projectEnd;

  /// 立项报告上传URL
  final String? projectReportUrl;

  /// 招标文件上传URL
  final String? publishBidUrl;

  /// 中标文件上传URL
  final String? aimBidUrl;

  /// 其他文件上传URL
  final String? otherDocUrl;

  /// 状态
  final int status;

  /// 供材类型
  final int supplyType;

  /// 类型
  final int type;

  /// 创建者姓名
  final String createdName;

  /// 创建者ID
  final String createdId;

  /// 审核意见
  final String? auditOpinion;

  /// 审核时间
  final String? auditTime;

  /// 审核人姓名
  final String? auditName;

  /// 审核人ID
  final String? auditId;

  /// 物料列表
  final List<ProjectMaterial> materialList;

  /// 建设方负责人列表
  final List<ProjectUser> constructionUserList;

  /// 监理方负责人列表
  final List<ProjectUser> supervisorUserList;

  /// 施工方负责人列表
  final List<ProjectUser> builderUserList;

  factory ProjectDetail.fromJson(Map<String, dynamic> json) =>
      _$ProjectDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDetailToJson(this);

  @override
  List<Object?> get props => [
        id,
        projectName,
        projectCode,
        projectStart,
        projectEnd,
        projectReportUrl,
        publishBidUrl,
        aimBidUrl,
        otherDocUrl,
        status,
        supplyType,
        type,
        createdName,
        createdId,
        auditOpinion,
        auditTime,
        auditName,
        auditId,
        materialList,
        constructionUserList,
        supervisorUserList,
        builderUserList,
      ];
}

/// 供材类型枚举
enum SupplyType {
  /// 甲供材
  client(0, '甲供材'),
  /// 乙供材
  contractor(1, '乙供材'),
  /// 混合供材
  mixed(2, '混合供材');

  const SupplyType(this.value, this.label);
  final int value;
  final String label;

  static SupplyType fromValue(int value) {
    return SupplyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SupplyType.client,
    );
  }
}

/// 物料类型枚举
enum MaterialType {
  /// 管材
  pipe(1, '管材'),
  /// 管件
  fitting(2, '管件'),
  /// 设备
  equipment(3, '设备');

  const MaterialType(this.value, this.label);
  final int value;
  final String label;

  static MaterialType fromValue(int value) {
    return MaterialType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MaterialType.pipe,
    );
  }
}