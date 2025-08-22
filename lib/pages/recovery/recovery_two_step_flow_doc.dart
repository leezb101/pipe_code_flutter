/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// Recovery模块两步提交流程说明
///
/// ## 流程概述
/// 1. 用户填写表单并点击"确定"
/// 2. 触发Step3提交，获取确认信息
/// 3. 显示确认弹窗，展示材料信息
/// 4. 用户点击"确认并扫码"
/// 5. 自动跳转到QR扫描页面
/// 6. 完成扫描后提交Step4
/// 7. 显示最终成功信息
///
/// ## 状态流转
/// ```
/// RecoveryFormReady
///   ↓ (用户点击确定)
/// RecoverySubmitting
///   ↓ (Step3 API调用成功)
/// RecoveryStep3Success
///   ↓ (用户确认)
/// RecoveryStep4InProgress
///   ↓ (QR扫描完成)
/// RecoveryStep4InProgress (isSubmittingStep4=true)
///   ↓ (Step4 API调用成功)
/// RecoveryTwoStepSubmissionComplete
/// ```
///
/// ## 扫描功能分离
/// - **表单扫描**: `_handleScanQRCode()` - 用于填写表单字段
/// - **Step4扫描**: `_handleStep4QrScan()` - 用于两步提交流程
///
/// ## 用户取消处理
/// - 在确认弹窗中点击"取消" → 回到RecoveryFormReady状态
/// - 在QR扫描页面返回 → 回到RecoveryStep3Success状态
///
/// ## 错误处理
/// - Step3提交失败 → 显示错误并保持RecoverySubmitting状态
/// - Step4提交失败 → 显示错误并允许重新扫描
/// - QR扫描异常 → 显示错误并回到上一状态
///
/// ## UI组件
/// - `RecoveryConfirmationDialog`: 确认弹窗组件
/// - `showRecoveryConfirmationDialog()`: 便捷显示方法
///
/// ## 集成要点
/// - 保持现有表单扫描功能不变
/// - 新增两步提交专用扫描流程
/// - 完整的状态管理和错误处理
/// - 用户友好的交互体验
library;
