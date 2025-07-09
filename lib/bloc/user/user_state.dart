/*
 * @Author: LeeZB
 * @Date: 2025-07-09 23:50:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 23:50:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import '../../models/user/wx_login_vo.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// 用户初始状态
class UserInitial extends UserState {
  const UserInitial();
}

/// 用户加载中
class UserLoading extends UserState {
  const UserLoading();
}

/// 用户已加载
class UserLoaded extends UserState {
  const UserLoaded({required this.wxLoginVO});

  final WxLoginVO wxLoginVO;

  @override
  List<Object> get props => [wxLoginVO];
}

/// 用户数据为空
class UserEmpty extends UserState {
  const UserEmpty();
}

/// 用户错误状态
class UserError extends UserState {
  const UserError({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}