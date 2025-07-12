/*
 * @Author: LeeZB
 * @Date: 2025-07-12 19:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 19:45:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/toast_utils.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _canRequestSms = false; // 初始状态为false，需要输入有效手机号后才能发送

  @override
  void dispose() {
    _phoneController.dispose();
    _smsCodeController.dispose();
    _countdownTimer?.cancel();
    // 清除toast重复消息缓存，避免页面切换时重复显示
    ToastUtils.clearDuplicateCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1976D2)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '短信验证码登录',
          style: TextStyle(
            color: Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF5F7FA),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoginSuccess) {
                context.showSuccessToast('登录成功');
                context.go('/main');
              } else if (state is AuthSmsCodeSent) {
                context.showSuccessToast('验证码已发送到 ${state.phone}');
                _startCountdown();
              } else if (state is AuthFailure) {
                context.showErrorToast(state.error);
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // 页面标题和说明
                    _buildHeader(),
                    const SizedBox(height: 50),
                    // 登录表单
                    _buildLoginForm(state),
                    const SizedBox(height: 40),
                    // 登录按钮
                    _buildLoginButton(state),
                    const SizedBox(height: 30),
                    // 返回账号登录
                    _buildBackToPasswordLogin(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 图标
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.sms_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '验证码登录',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '输入手机号码，我们将发送验证码到您的手机',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState state) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 手机号输入框
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: '请输入手机号码',
                labelText: '手机号码',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1976D2),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入手机号码';
                }
                if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                  return '请输入正确的手机号码';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  // 当手机号变化时，更新发送短信按钮状态
                  if (value.length == 11 && RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                    _canRequestSms = _countdown == 0;
                  } else {
                    _canRequestSms = false;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            // 验证码输入框和发送按钮
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _smsCodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      hintText: '请输入验证码',
                      labelText: '短信验证码',
                      prefixIcon: const Icon(Icons.message_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1976D2),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      // 只有在尝试登录时才验证验证码
                      // 获取验证码时不需要验证这个字段
                      if (value == null || value.isEmpty) {
                        return '请输入验证码';
                      }
                      if (value.length < 4) {
                        return '验证码长度不正确';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_canRequestSms && state is! AuthSmsCodeSending) 
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
                    child: state is AuthSmsCodeSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state is AuthLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
        ),
        child: state is AuthLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '立即登录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToPasswordLogin() {
    return TextButton(
      onPressed: () => context.pop(),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, size: 16),
          SizedBox(width: 8),
          Text(
            '返回账号密码登录',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _requestSmsCode() {
    final phone = _phoneController.text.trim();
    
    // 只验证手机号，不依赖表单的完整验证
    if (phone.isEmpty) {
      context.showErrorToast('请输入手机号码');
      return;
    }
    
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      context.showErrorToast('请输入正确的手机号码');
      return;
    }

    context.read<AuthBloc>().add(
      AuthSmsCodeRequested(phone: phone),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      final code = _smsCodeController.text.trim();

      if (phone.isEmpty || code.isEmpty) {
        context.showErrorToast('请填写完整信息');
        return;
      }

      // 获取当前的SMS验证码状态以提取smsCode
      final authState = context.read<AuthBloc>().state;
      String? smsCode;
      
      if (authState is AuthSmsCodeSent) {
        smsCode = authState.smsCode;
        if (smsCode.isEmpty) {
          context.showErrorToast('验证码状态异常，请重新获取');
          return;
        }
      } else {
        context.showErrorToast('请先获取短信验证码');
        return;
      }

      context.read<AuthBloc>().add(
        AuthLoginWithSmsRequested(
          phone: phone,
          code: code,
          smsCode: smsCode,
        ),
      );
    }
  }

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
          _canRequestSms = true;
          timer.cancel();
        }
      });
    });
  }
}