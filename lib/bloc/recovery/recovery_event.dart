/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';

/// Recovery模块的事件基类
abstract class RecoveryEvent extends Equatable {
  const RecoveryEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化事件 - 页面首次加载时触发
class RecoveryInitialized extends RecoveryEvent {
  const RecoveryInitialized();
}

/// 刷新数据事件 - 用户手动刷新或需要重新加载数据时触发
class RecoveryDataRefreshed extends RecoveryEvent {
  /// 是否强制刷新（清除缓存）
  final bool forceRefresh;

  const RecoveryDataRefreshed({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// 选择供应商事件 - 用户在供应商下拉框中选择时触发
class RecoveryVendorSelected extends RecoveryEvent {
  /// 选择的供应商代码
  final String vendorCode;

  const RecoveryVendorSelected({required this.vendorCode});

  @override
  List<Object?> get props => [vendorCode];
}

/// 选择材料分类事件 - 用户在材料大类下拉框中选择时触发
class RecoveryCategorySelected extends RecoveryEvent {
  /// 选择的分类组别
  final int categoryGroup;

  const RecoveryCategorySelected({required this.categoryGroup});

  @override
  List<Object?> get props => [categoryGroup];
}

/// 选择材料类型事件 - 用户在材料类型下拉框中选择时触发
class RecoveryMaterialTypeSelected extends RecoveryEvent {
  /// 选择的材料类型编号
  final int materialType;

  const RecoveryMaterialTypeSelected({required this.materialType});

  @override
  List<Object?> get props => [materialType];
}

/// 表单字段值变更事件 - 用户在动态表单中输入或修改内容时触发
class RecoveryFormFieldChanged extends RecoveryEvent {
  /// 字段键
  final String fieldKey;

  /// 字段值
  final String? value;

  const RecoveryFormFieldChanged({required this.fieldKey, this.value});

  @override
  List<Object?> get props => [fieldKey, value];
}

/// 表单验证事件 - 用户点击提交前进行表单验证时触发
class RecoveryFormValidated extends RecoveryEvent {
  const RecoveryFormValidated();
}

/// 表单提交事件 - 用户点击确定按钮提交表单时触发
class RecoveryFormSubmitted extends RecoveryEvent {
  const RecoveryFormSubmitted();
}

/// 重置表单事件 - 用户点击取消或重置时触发
class RecoveryFormReset extends RecoveryEvent {
  const RecoveryFormReset();
}

/// 清除验证错误事件 - 用户修正输入后清除验证错误状态时触发
class RecoveryValidationErrorsCleared extends RecoveryEvent {
  const RecoveryValidationErrorsCleared();
}

/// 清除错误信息事件 - 用户消费错误信息后清除错误状态时触发
class RecoveryErrorMessageCleared extends RecoveryEvent {
  const RecoveryErrorMessageCleared();
}

// === 两步提交相关事件 ===

/// Step3提交事件 - 用户点击确定按钮提交表单进入第一步提交时触发
class RecoveryStep3Submitted extends RecoveryEvent {
  const RecoveryStep3Submitted();
}

/// Step4确认事件 - 用户在确认弹窗中点击确认按钮准备QR扫描时触发
class RecoveryStep4Confirmed extends RecoveryEvent {
  const RecoveryStep4Confirmed();
}

/// Step4 QR扫描完成事件 - 用户完成QR扫描后提交最终数据时触发
class RecoveryStep4QrScanned extends RecoveryEvent {
  /// 扫描到的QR码内容
  final String qrCode;

  const RecoveryStep4QrScanned({required this.qrCode});

  @override
  List<Object?> get props => [qrCode];
}

/// 取消Step4事件 - 用户在确认弹窗中点击取消或返回时触发
class RecoveryStep4Cancelled extends RecoveryEvent {
  const RecoveryStep4Cancelled();
}
