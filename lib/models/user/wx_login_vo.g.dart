// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wx_login_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WxLoginVO _$WxLoginVOFromJson(Map<String, dynamic> json) => WxLoginVO(
  id: json['id'] as String,
  tk: json['tk'] as String,
  unionid: json['unionid'] as String?,
  account: json['account'] as String?,
  phone: json['phone'] as String,
  name: json['name'] as String,
  nick: json['nick'] as String?,
  birthday: json['birthday'] as String?,
  avatar: json['avatar'] as String?,
  address: json['address'] as String?,
  sex: json['sex'] as String?,
  lastLoginTime: json['lastLoginTime'] as String?,
  complete: json['complete'] as bool?,
  orgCode: json['orgCode'] as String?,
  orgName: json['orgName'] as String?,
  own: json['own'] as bool,
  boss: json['boss'] as bool,
  admin: json['admin'] as bool,
  storekeeper: json['storekeeper'] as bool? ?? false,
  projectInfos: (json['projectInfos'] as List<dynamic>)
      .map((e) => ProjectInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentProject: json['currentProject'] == null
      ? null
      : ProjectInfo.fromJson(json['currentProject'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WxLoginVOToJson(WxLoginVO instance) => <String, dynamic>{
  'id': instance.id,
  'tk': instance.tk,
  'unionid': instance.unionid,
  'account': instance.account,
  'phone': instance.phone,
  'name': instance.name,
  'nick': instance.nick,
  'birthday': instance.birthday,
  'avatar': instance.avatar,
  'address': instance.address,
  'sex': instance.sex,
  'lastLoginTime': instance.lastLoginTime,
  'complete': instance.complete,
  'orgCode': instance.orgCode,
  'orgName': instance.orgName,
  'own': instance.own,
  'boss': instance.boss,
  'admin': instance.admin,
  'storekeeper': instance.storekeeper,
  'projectInfos': instance.projectInfos,
  'currentProject': instance.currentProject,
};
