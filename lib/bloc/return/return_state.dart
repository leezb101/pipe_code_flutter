/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'return_bloc.dart';

enum ReturnStatus {
  initial, // 初始状态
  loading, // 加载中
  success, // 成功
  failure, // 失败
  returnSuccess, // 退库提交成功
}

class ReturnState extends Equatable {
  const ReturnState({
    this.status = ReturnStatus.initial,
    this.codes = const [],
    this.materialInfo,
    this.returnDetail,
    this.returnType = 1, // 默认为多余件退库
    this.returnRemark = '',
    this.returnRemarkVoice = const [],
    this.imageList = const [],
    this.errorMessage,
  });

  // 当前状态
  final ReturnStatus status;
  // 扫码获取的物料二维码字符串
  final List<String> codes;
  // 扫码获取的物料信息
  final MaterialInfoForBusiness? materialInfo;
  // 退库详情
  final ReturnDetailVo? returnDetail;
  // 退库类型 (0: 质量不合格退库, 1: 多余件退库)
  final int returnType;
  // 退库备注
  final String returnRemark;
  // 退库备注的语音文件路径列表
  final List<String>? returnRemarkVoice;
  // 图片附件列表
  final List<AttachmentVO> imageList;
  // 错误信息
  final String? errorMessage;

  ReturnState copyWith({
    ReturnStatus? status,
    List<String>? codes,
    MaterialInfoForBusiness? materialInfo,
    ReturnDetailVo? returnDetail,
    int? returnType,
    String? returnRemark,
    List<String>? reasonVoice,
    List<AttachmentVO>? imageList,
    String? errorMessage,
  }) {
    return ReturnState(
      status: status ?? this.status,
      codes: codes ?? this.codes,
      materialInfo: materialInfo ?? this.materialInfo,
      returnDetail: returnDetail ?? this.returnDetail,
      returnType: returnType ?? this.returnType,
      returnRemark: returnRemark ?? this.returnRemark,
      returnRemarkVoice: reasonVoice ?? this.returnRemarkVoice,
      imageList: imageList ?? this.imageList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    codes,
    materialInfo,
    returnDetail,
    returnType,
    returnRemark,
    returnRemarkVoice,
    imageList,
    errorMessage,
  ];
}
