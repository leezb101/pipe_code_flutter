/*
 * @Author: LeeZB
 * @Date: 2025-09-26 17:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-26 17:20:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/privacy_policy_constants.dart';
import '../../services/privacy_policy_service.dart';
import '../../config/service_locator.dart';
import '../../config/routes.dart' show navigatorKey;

/// 隐私合规弹窗
/// 符合360加固平台要求，用户首次打开App时显示
class PrivacyComplianceDialog extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback? onDisagree;

  const PrivacyComplianceDialog({
    super.key,
    required this.onAgree,
    this.onDisagree,
  });

  /// 显示隐私合规弹窗
  static Future<bool> show(BuildContext context) async {
    bool agreed = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (BuildContext context) {
        return PrivacyComplianceDialog(
          onAgree: () {
            agreed = true;
            Navigator.of(context).pop();
          },
          onDisagree: () {
            agreed = false;
            // Navigator.of(context).pop();
            // 此处需要直接退出应用
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          },
        );
      },
    );

    return agreed;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁用返回键关闭弹窗
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '隐私政策与用户协议',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 内容区域
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PrivacyPolicyConstants.briefPrivacyPolicy,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 查看完整隐私政策链接
                      GestureDetector(
                        onTap: () => _showFullPrivacyPolicy(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '查看完整隐私政策',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 按钮区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // 重要提示
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '请仔细阅读隐私政策，同意后方可继续使用',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 按钮组
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleDisagree,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('不同意'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _handleAgree,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              '同意并继续',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 处理用户同意
  void _handleAgree() {
    final privacyService = getIt<PrivacyPolicyService>();
    privacyService.recordUserConsent();
    onAgree();
  }

  /// 处理用户不同意
  void _handleDisagree() {
    final privacyService = getIt<PrivacyPolicyService>();
    privacyService.recordUserDenial();

    // 显示退出确认
    if (onDisagree != null) {
      onDisagree!();
    } else {
      _showExitConfirmation();
    }
  }

  /// 显示退出确认对话框
  void _showExitConfirmation() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text(
            '如不同意隐私政策，将无法使用本应用。确定要退出吗？',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('重新考虑'),
            ),
            TextButton(
              onPressed: () {
                // 退出应用
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('退出应用'),
            ),
          ],
        );
      },
    );
  }

  /// 显示完整隐私政策
  void _showFullPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '隐私政策完整版',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      PrivacyPolicyConstants.fullPrivacyPolicy,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('我已阅读'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 删除底部的重复定义，使用routes.dart中的navigatorKey
