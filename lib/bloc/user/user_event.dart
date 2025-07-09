/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:45:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// 加载用户数据请求
class UserLoadRequested extends UserEvent {
  const UserLoadRequested();
}

/// 设置用户数据
class UserSetData extends UserEvent {
  const UserSetData({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object?> get props => [wxLoginVO];
}

/// 更新用户基本信息
class UserUpdateProfile extends UserEvent {
  const UserUpdateProfile({
    this.name,
    this.nick,
    this.avatar,
    this.address,
    this.phone,
  });

  final String? name;
  final String? nick;
  final String? avatar;
  final String? address;
  final String? phone;

  @override
  List<Object?> get props => [name, nick, avatar, address, phone];
}

/// 清除用户数据
class UserClearData extends UserEvent {
  const UserClearData();
}