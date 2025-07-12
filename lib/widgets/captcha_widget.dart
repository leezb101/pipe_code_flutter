/*
 * @Author: LeeZB
 * @Date: 2025-07-12 18:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-12 18:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

/// 图形验证码组件
/// 支持点击刷新验证码，与AuthBloc集成
class CaptchaWidget extends StatefulWidget {
  final TextEditingController codeController;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry margin;

  const CaptchaWidget({
    super.key,
    required this.codeController,
    this.validator,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  @override
  void initState() {
    super.initState();
    // 组件初始化时自动请求验证码
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCaptchaRequested());
    });
  }

  void _refreshCaptcha() {
    context.read<AuthBloc>().add(const AuthCaptchaRequested());
    // 刷新验证码时清空用户输入
    widget.codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          // 验证码输入框
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: widget.codeController,
              decoration: const InputDecoration(
                hintText: '请输入验证码',
                labelText: '图形验证码',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                prefixIcon: Icon(Icons.security),
              ),
              validator: widget.validator ??
                  (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入验证码';
                    }
                    if (value.length < 4) {
                      return '验证码长度不正确';
                    }
                    return null;
                  },
              maxLength: 6,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null, // 隐藏字符计数器
            ),
          ),
          const SizedBox(width: 12),
          // 验证码图片
          Expanded(
            flex: 2,
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) =>
                  current is AuthCaptchaLoading ||
                  current is AuthCaptchaLoaded ||
                  current is AuthFailure,
              builder: (context, state) {
                return Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: _refreshCaptcha,
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCaptchaContent(state),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaContent(AuthState state) {
    if (state is AuthCaptchaLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (state is AuthCaptchaLoaded) {
      try {
        final imageBytes = base64Decode(state.captchaBase64);
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // 刷新提示图标
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      } catch (e) {
        return _buildErrorWidget('验证码格式错误');
      }
    } else if (state is AuthFailure) {
      return _buildErrorWidget('获取失败');
    } else {
      return _buildErrorWidget('点击获取验证码');
    }
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 2),
            Text(
              message,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 扩展方法：为AuthBloc添加刷新验证码功能
extension CaptchaExtension on AuthBloc {
  void refreshCaptcha() {
    add(const AuthCaptchaRequested());
  }
}