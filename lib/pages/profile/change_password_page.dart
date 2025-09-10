/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/services/api/interfaces/chanage_password_api_service.dart';
import 'package:pipe_code_flutter/utils/rsa_encryption_util.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/custom_text_form_field.dart';

/// 修改密码页面
///
/// 主要功能：
/// 1. 获取短信验证码（发送到绑定手机号）
/// 2. 新密码输入和强度校验
/// 3. 提交修改密码请求
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  // 输入控制器
  final _smsCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  // API服务
  late final ChangePasswordApiService _changePasswordApiService;

  // 状态变量
  bool _isLoading = false;
  bool _isSendingSms = false;
  bool _isPasswordVisible = false;
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _canRequestSms = true;
  String? _storedSmsCode; // 存储从响应头获取的sms_code

  // 错误状态管理
  final Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _changePasswordApiService = getIt<ChangePasswordApiService>();
  }

  @override
  void dispose() {
    _smsCodeController.dispose();
    _passwordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改密码'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF0F8FF), Color(0xFFE6F3FF), Color(0xFFDCEEFF)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建页面头部说明卡片
  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.security, size: 32, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '修改密码',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '通过手机短信验证安全修改',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建表单卡片
  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 手机号提示信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '短信验证码将发送到本账号绑定的手机号上',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12), // 短信验证码输入框和获取按钮
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    hintText: '请输入验证码',
                    labelText: '短信验证码',
                    prefixIcon: const Icon(Icons.message_outlined),
                    hasError: _fieldErrors.containsKey('smsCode'),
                    onChanged: (value) {
                      if (_fieldErrors.containsKey('smsCode')) {
                        _setFieldError('smsCode', null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        (_canRequestSms && !_isSendingSms && _countdown == 0)
                        ? _requestSmsCode
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSendingSms
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _countdown > 0 ? '${_countdown}s' : '获取验证码',
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12), // 新密码输入框
            CustomTextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              hintText: '请输入新密码',
              labelText: '新密码',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              hasError: _fieldErrors.containsKey('password'),
              onChanged: (value) {
                if (_fieldErrors.containsKey('password')) {
                  _setFieldError('password', null);
                }
              },
            ),

            const SizedBox(height: 6), // 密码强度提示
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '密码要求',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 密码长度不少于8位  • 必须包含数字\n• 必须包含小写字母  • 必须包含大写字母',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '提交修改',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  /// 设置字段错误状态
  void _setFieldError(String field, String? error) {
    setState(() {
      if (error != null) {
        _fieldErrors[field] = error;
      } else {
        _fieldErrors.remove(field);
      }
    });
  }

  /// 更新短信按钮状态
  void _updateSmsButtonState() {
    setState(() {
      _canRequestSms = _countdown == 0;
    });
  }

  /// 请求短信验证码
  Future<void> _requestSmsCode() async {
    setState(() {
      _isSendingSms = true;
    });

    try {
      final result = await _changePasswordApiService.getChangePasswordSmsCode();

      if (result.code == 0 && result.data != null) {
        // 保存从响应头获取的sms_code
        _storedSmsCode = result.data!['smsCode'] as String?;

        if (_storedSmsCode != null) {
          if (mounted) {
            context.showSuccessToast('验证码已发送，请查收短信');
          }
          _startCountdown();
        } else {
          if (mounted) {
            context.showErrorToast('获取验证码失败，请重试');
          }
        }
      } else {
        if (mounted) {
          context.showErrorToast(
            result.msg.isNotEmpty ? result.msg : '获取验证码失败',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('网络错误，请检查网络连接');
      }
    } finally {
      setState(() {
        _isSendingSms = false;
      });
    }
  }

  /// 开始倒计时
  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canRequestSms = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
          _updateSmsButtonState();
        }
      });
    });
  }

  /// 提交修改密码请求
  Future<void> _submitChangePassword() async {
    if (!_validateForm()) {
      return;
    }

    if (_storedSmsCode == null) {
      context.showErrorToast('请先获取短信验证码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // RSA加密密码
    final rawPassword = _passwordController.text;
    String encryptedPassword;

    try {
      encryptedPassword = RSAEncryptionUtil.encryptPassword(rawPassword);
    } catch (e) {
      context.showErrorToast('密码加密失败，请重试');
      return;
    }

    try {
      final result = await _changePasswordApiService.submitChangePassword(
        encryptedPassword,
        _smsCodeController.text.trim(),
        _storedSmsCode!,
      );

      if (result.code == 0) {
        if (mounted) {
          context.showSuccessToast('密码修改成功');
        }
        // 延迟返回上一页
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        if (mounted) {
          context.showErrorToast(result.msg.isNotEmpty ? result.msg : '密码修改失败');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('网络错误，请检查网络连接');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 验证新密码强度
  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _setFieldError('password', '请输入新密码');
      context.showErrorToast('请输入新密码');
      return false;
    }

    if (password.length < 8) {
      _setFieldError('password', '密码长度不能少于8位');
      context.showErrorToast('密码长度不能少于8位');
      return false;
    }

    // 检查是否包含数字
    if (!RegExp(r'\d').hasMatch(password)) {
      _setFieldError('password', '密码必须包含数字');
      context.showErrorToast('密码必须包含数字');
      return false;
    }

    // 检查是否包含小写字母
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      _setFieldError('password', '密码必须包含小写字母');
      context.showErrorToast('密码必须包含小写字母');
      return false;
    }

    // 检查是否包含大写字母
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _setFieldError('password', '密码必须包含大写字母');
      context.showErrorToast('密码必须包含大写字母');
      return false;
    }

    return true;
  }

  /// 验证短信验证码
  bool _validateSmsCode(String code) {
    if (code.isEmpty) {
      _setFieldError('smsCode', '请输入短信验证码');
      context.showErrorToast('请输入短信验证码');
      return false;
    }

    if (code.length != 6) {
      _setFieldError('smsCode', '验证码应为6位数字');
      context.showErrorToast('验证码应为6位数字');
      return false;
    }

    return true;
  }

  /// 验证整个表单
  bool _validateForm() {
    _fieldErrors.clear();

    final password = _passwordController.text;
    final smsCode = _smsCodeController.text.trim();

    bool isValid = true;

    if (!_validatePassword(password)) {
      isValid = false;
    }

    if (!_validateSmsCode(smsCode)) {
      isValid = false;
    }

    return isValid;
  }
}
