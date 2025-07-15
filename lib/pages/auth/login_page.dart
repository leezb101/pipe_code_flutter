import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/auth/login_account_vo.dart';
import '../../utils/toast_utils.dart';
import '../../utils/rsa_encryption_util.dart';
import '../../widgets/captcha_widget.dart';
import '../../widgets/custom_text_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Form keys
  final _passwordFormKey = GlobalKey<FormState>();
  final _smsFormKey = GlobalKey<FormState>();

  // Password login controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  // SMS login controllers
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  // UI state
  bool _isPasswordVisible = false;
  bool _isPasswordMode = true; // true for password login, false for SMS login

  // Animation controller for flip animation
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  // SMS countdown state
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _canRequestSms = false;

  // Error state management
  final Map<String, String?> _fieldErrors = {};
  String? _formErrorMessage;

  @override
  void initState() {
    super.initState();
    _flipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 监听验证码输入变化
    _captchaController.addListener(() {
      if (_fieldErrors.containsKey('captcha') &&
          _captchaController.text.isNotEmpty) {
        _setFieldError('captcha', null);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _flipAnimationController.dispose();

    // 确保Timer被正确取消和清理
    _countdownTimer?.cancel();
    _countdownTimer = null;

    // 重置倒计时相关状态
    _countdown = 0;
    _canRequestSms = false;

    // 清除toast重复消息缓存，避免页面切换时重复显示
    ToastUtils.clearDuplicateCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPasswordMode
                ? [
                    const Color(0xFF1976D2), // 深蓝色 - 水务主题
                    const Color(0xFF42A5F5), // 浅蓝色
                    const Color(0xFF81C784), // 淡绿色 - 环保主题
                  ]
                : [
                    const Color(0xFF1565C0), // 稍深的蓝色 - SMS模式
                    const Color(0xFF2196F3), // 蓝色
                    const Color(0xFF66BB6A), // 稍深的绿色 - SMS模式
                  ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoginSuccess) {
                context.showSuccessToast('登录成功');
                context.go('/');
              } else if (state is AuthSmsCodeSent) {
                context.showSuccessToast('验证码已发送到 ${state.phone}');
                _startCountdown();
              } else if (state is AuthCaptchaFailure) {
                // 图形验证码获取失败，只提示，不自动刷新验证码
                context.showErrorToast(state.error);
              } else if (state is AuthFailure || state is AuthLoginFailure) {
                context.showErrorToast(
                  state is AuthFailure
                      ? state.error
                      : (state as AuthLoginFailure).error,
                );
                // 登录失败时刷新验证码
                if (_isPasswordMode) {
                  context.read<AuthBloc>().add(const AuthCaptchaRequested());
                  _captchaController.clear();
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // 应用Logo和标题
                    _buildHeader(),
                    const SizedBox(height: 50),
                    // 登录表单卡片（带翻转动画）
                    _buildFlipLoginCard(state),
                    const SizedBox(height: 30),
                    // 其他选项
                    _buildFooter(),
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
        // Logo占位符 - 可以替换为实际Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop,
            size: 40,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '智慧水务管理系统',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '一管一码 · 智能管理',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipLoginCard(AuthState state) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isShowingFront = _flipAnimation.value < 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi * _flipAnimation.value),
          child: isShowingFront
              ? _buildPasswordLoginCard(state)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildSmsLoginCard(state),
                ),
        );
      },
    );
  }

  Widget _buildPasswordLoginCard(AuthState state) {
    return Container(
      height: 400, // 固定高度
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '账号登录',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 错误信息显示区域
            if (_formErrorMessage != null || _fieldErrors.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formErrorMessage ?? _fieldErrors.values.first ?? '',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // 用户名输入框
            CustomTextFormField(
              controller: _usernameController,
              hintText: '请输入用户名',
              labelText: '用户名',
              prefixIcon: const Icon(Icons.person_outline),
              hasError: _fieldErrors.containsKey('username'),
              onChanged: (value) {
                if (_fieldErrors.containsKey('username')) {
                  _setFieldError('username', null);
                }
              },
            ),
            const SizedBox(height: 12),
            // 密码输入框
            CustomTextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              hintText: '请输入密码',
              labelText: '密码',
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
            const SizedBox(height: 12),
            // 图形验证码组件
            Container(
              decoration: _fieldErrors.containsKey('captcha')
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 2),
                    )
                  : null,
              child: CaptchaWidget(
                codeController: _captchaController,
                margin: EdgeInsets.zero,
                validator: (value) {
                  // 禁用默认验证，使用自定义验证
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            // 登录按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state is AuthLoading ? null : _passwordLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(0),
                  elevation: 3,
                ),
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsLoginCard(AuthState state) {
    return Container(
      height: 400, // 与密码登录卡片相同高度
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _smsFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '验证码登录',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '输入手机号码，我们将发送验证码到您的手机',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 错误信息显示区域
            if (_formErrorMessage != null || _fieldErrors.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formErrorMessage ?? _fieldErrors.values.first ?? '',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // 手机号输入框
            CustomTextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              hintText: '请输入手机号码',
              labelText: '手机号码',
              prefixIcon: const Icon(Icons.phone_outlined),
              hasError: _fieldErrors.containsKey('phone'),
              onChanged: (value) {
                // 清除错误状态
                if (_fieldErrors.containsKey('phone')) {
                  _setFieldError('phone', null);
                }

                _updateSmsButtonState();
              },
            ),
            const SizedBox(height: 16),
            // 验证码输入框和发送按钮
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
            const SizedBox(height: 20),
            // 登录按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state is AuthLoading ? null : _smsLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(0),
                  elevation: 3,
                ),
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // 其他登录方式提示
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 20),
        // 登录方式切换按钮
        TextButton(
          onPressed: _switchLoginMode,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isPasswordMode ? Icons.sms_outlined : Icons.person_outline,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isPasswordMode ? '短信验证码登录' : '账号密码登录',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 版权信息
        Text(
          '© 2025 郑州水务科技有限公司',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  void _switchLoginMode() {
    setState(() {
      _isPasswordMode = !_isPasswordMode;
      // 清除错误信息
      _clearErrors();
    });

    if (_isPasswordMode) {
      _flipAnimationController.reverse();
    } else {
      _flipAnimationController.forward();
      // 切换到SMS模式时，确保按钮状态正确
      _updateSmsButtonState();
    }
  }

  void _clearErrors() {
    _fieldErrors.clear();
    _formErrorMessage = null;
  }

  void _setFieldError(String field, String? error) {
    setState(() {
      if (error != null) {
        _fieldErrors[field] = error;
      } else {
        _fieldErrors.remove(field);
      }
    });
  }

  void _updateSmsButtonState() {
    setState(() {
      final phone = _phoneController.text.trim();
      // 只有在倒计时结束且手机号有效时才能发送短信
      if (phone.length == 11 &&
          RegExp(r'^1[3-9]\d{9}$').hasMatch(phone) &&
          _countdown == 0) {
        _canRequestSms = true;
      } else {
        _canRequestSms = false;
      }
    });
  }

  bool _validatePasswordForm() {
    _clearErrors();
    bool isValid = true;

    // 验证用户名
    if (_usernameController.text.trim().isEmpty) {
      _setFieldError('username', '请输入用户名');
      isValid = false;
    }

    // 验证密码
    final password = _passwordController.text;
    if (password.isEmpty) {
      _setFieldError('password', '请输入密码');
      isValid = false;
    } else if (password.length < 6) {
      _setFieldError('password', '密码长度不能少于6位');
      isValid = false;
    }

    // 验证验证码
    if (_captchaController.text.trim().isEmpty) {
      _setFieldError('captcha', '请输入图形验证码');
      isValid = false;
    }

    return isValid;
  }

  bool _validateSmsForm() {
    _clearErrors();
    bool isValid = true;

    // 验证手机号
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _setFieldError('phone', '请输入手机号码');
      isValid = false;
    } else if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      _setFieldError('phone', '请输入正确的手机号码');
      isValid = false;
    }

    // 验证短信验证码
    final code = _smsCodeController.text.trim();
    if (code.isEmpty) {
      _setFieldError('smsCode', '请输入验证码');
      isValid = false;
    } else if (code.length < 4) {
      _setFieldError('smsCode', '验证码长度不正确');
      isValid = false;
    }

    return isValid;
  }

  void _passwordLogin() {
    if (!_validatePasswordForm()) {
      return;
    }

    final captchaCode = _captchaController.text.trim();

    // 获取当前的验证码状态以提取imgCode
    final authState = context.read<AuthBloc>().state;
    String? imgCode;

    if (authState is AuthCaptchaLoaded) {
      imgCode = authState.imgCode;
      if (imgCode.isEmpty) {
        context.showErrorToast('验证码状态异常，请重新获取');
        context.read<AuthBloc>().add(const AuthCaptchaRequested());
        return;
      }
    } else {
      context.showErrorToast('请先获取图形验证码');
      context.read<AuthBloc>().add(const AuthCaptchaRequested());
      return;
    }

    // RSA加密密码
    final rawPassword = _passwordController.text;
    String encryptedPassword;

    try {
      encryptedPassword = RSAEncryptionUtil.encryptPassword(rawPassword);
    } catch (e) {
      context.showErrorToast('密码加密失败，请重试');
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginWithPasswordRequested(
        loginRequest: LoginAccountVO(
          account: _usernameController.text.trim(),
          password: encryptedPassword,
          code: captchaCode,
        ),
        imgCode: imgCode,
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

    context.read<AuthBloc>().add(AuthSmsCodeRequested(phone: phone));
  }

  void _smsLogin() {
    if (!_validateSmsForm()) {
      return;
    }

    final phone = _phoneController.text.trim();
    final code = _smsCodeController.text.trim();

    // 获取当前的SMS验证码状态以提取smsCode
    final authState = context.read<AuthBloc>().state;
    String? smsCode;

    if (authState is AuthSmsCodeSent) {
      smsCode = authState.smsCode;
      if (smsCode.isEmpty) {
        context.showErrorToast('验证码状态异常，请重新获取');
        return;
      }
    }
    // else {
    //   context.showErrorToast('请先获取短信验证码');
    //   return;
    // }

    context.read<AuthBloc>().add(
      AuthLoginWithSmsRequested(phone: phone, code: code, smsCode: smsCode),
    );
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canRequestSms = false;
    });

    _countdownTimer?.cancel(); // 确保之前的timer被取消
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // 确保widget还在树中
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
            _countdownTimer = null;
            // 倒计时结束时，重新检查按钮状态
            _updateSmsButtonState();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
}
