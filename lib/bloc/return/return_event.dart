/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

part of 'return_bloc.dart';

abstract class ReturnEvent extends Equatable {
  const ReturnEvent();

  @override
  List<Object?> get props => [];
}

// 加载扫码二维码事件
class LoadReturnMaterialCodes extends ReturnEvent {
  const LoadReturnMaterialCodes({required this.codes});

  final List<String> codes;

  @override
  List<Object?> get props => [codes];
}

// 更新退库类型事件
class UpdateReturnType extends ReturnEvent {
  const UpdateReturnType({required this.returnType});

  final int returnType;

  @override
  List<Object?> get props => [returnType];
}

// 更新退库备注事件
class UpdateReturnRemark extends ReturnEvent {
  const UpdateReturnRemark({required this.returnRemark});

  final String returnRemark;

  @override
  List<Object?> get props => [returnRemark];
}

class UpdateReturnRemarkVoice extends ReturnEvent {
  const UpdateReturnRemarkVoice({required this.returnRemarkVoice});

  final List<String> returnRemarkVoice;

  @override
  List<Object?> get props => [returnRemarkVoice];
}

// 更新图片附件事件
class UpdateImageList extends ReturnEvent {
  const UpdateImageList({required this.imageList});

  final List<AttachmentVO> imageList;

  @override
  List<Object?> get props => [imageList];
}

// 提交退库申请事件
class SubmitReturn extends ReturnEvent {
  const SubmitReturn();
}

// 重置状态事件
class ResetState extends ReturnEvent {
  const ResetState();
}

// 加载退库详情事件
class LoadReturnDetail extends ReturnEvent {
  const LoadReturnDetail({required this.id});

  final int id;

  @override
  List<Object?> get props => [id];
}

// 更新退库物料列表（追加或移除）
class UpdateReturnMaterials extends ReturnEvent {
  const UpdateReturnMaterials({required this.materials});
  final List<MaterialVO> materials;
  @override
  List<Object?> get props => [materials];
}
