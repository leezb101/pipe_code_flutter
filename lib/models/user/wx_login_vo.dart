/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 18:10:56
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../project/project_info.dart';

part 'wx_login_vo.g.dart';

/// 微信登录返回对象
/// 完全匹配API文档中的WxLoginVO结构
@JsonSerializable()
class WxLoginVO extends Equatable {
  const WxLoginVO({
    required this.id,
    required this.tk,
    required this.unionid,
    required this.account,
    required this.phone,
    required this.name,
    required this.nick,
    required this.birthday,
    required this.avatar,
    required this.address,
    required this.sex,
    required this.lastLoginTime,
    required this.complete,
    required this.orgCode,
    required this.orgName,
    required this.own,
    required this.boss,
    required this.admin,
    required this.projectInfos,
    this.currentProject,
  });

  /// 用户ID
  final String id;

  /// 用户token
  final String tk;

  /// 联合ID
  final String? unionid;

  /// 账号
  final String? account;

  /// 手机号
  final String phone;

  /// 姓名
  final String name;

  /// 昵称
  final String? nick;

  /// 生日
  final String? birthday;

  /// 头像
  final String? avatar;

  /// 地址
  final String? address;

  /// 性别（男 or 女）
  final String? sex;

  /// 最后登录时间
  final String? lastLoginTime;

  /// 是否完善用户信息
  final bool? complete;

  /// 归属组织代码
  final String? orgCode;

  /// 归属组织名称
  final String? orgName;

  /// 是否自有人员（非自有人员则为游客）
  final bool own;

  /// 是否管理层
  final bool boss;

  /// 是否管理员
  final bool admin;

  /// 参与的项目信息
  final List<ProjectInfo> projectInfos;

  /// 当前选中项目
  final ProjectInfo? currentProject;

  factory WxLoginVO.fromJson(Map<String, dynamic> json) =>
      _$WxLoginVOFromJson(json);

  Map<String, dynamic> toJson() => _$WxLoginVOToJson(this);

  WxLoginVO copyWith({
    String? id,
    String? tk,
    String? unionid,
    String? account,
    String? phone,
    String? name,
    String? nick,
    String? birthday,
    String? avatar,
    String? address,
    String? sex,
    String? lastLoginTime,
    bool? complete,
    String? orgCode,
    String? orgName,
    bool? own,
    bool? boss,
    bool? admin,
    List<ProjectInfo>? projectInfos,
    ProjectInfo? currentProject,
  }) {
    return WxLoginVO(
      id: id ?? this.id,
      tk: tk ?? this.tk,
      unionid: unionid ?? this.unionid,
      account: account ?? this.account,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      nick: nick ?? this.nick,
      birthday: birthday ?? this.birthday,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
      sex: sex ?? this.sex,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      complete: complete ?? this.complete,
      orgCode: orgCode ?? this.orgCode,
      orgName: orgName ?? this.orgName,
      own: own ?? this.own,
      boss: boss ?? this.boss,
      admin: admin ?? this.admin,
      projectInfos: projectInfos ?? this.projectInfos,
      currentProject: currentProject ?? this.currentProject,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tk,
    unionid,
    account,
    phone,
    name,
    nick,
    birthday,
    avatar,
    address,
    sex,
    lastLoginTime,
    complete,
    orgCode,
    orgName,
    own,
    boss,
    admin,
    projectInfos,
    currentProject,
  ];
}
