/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:25:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'rf.g.dart';

/// 刷新Token请求对象
/// 完全匹配API文档中的RF结构
@JsonSerializable()
class RF extends Equatable {
  const RF({
    required this.uid,
  });

  /// 经过公钥加密的unionid信息
  /// 原文为json格式，包含两个属性：
  /// 1. timestamp(当前时间毫秒数)
  /// 2. unionid
  final String uid;

  factory RF.fromJson(Map<String, dynamic> json) => _$RFFromJson(json);

  Map<String, dynamic> toJson() => _$RFToJson(this);

  RF copyWith({
    String? uid,
  }) {
    return RF(
      uid: uid ?? this.uid,
    );
  }

  @override
  List<Object?> get props => [uid];
}