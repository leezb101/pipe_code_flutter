import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../models/auth/login_account_vo.dart';
import '../../utils/toast_utils.dart';
import '../../utils/rsa_encryption_util.dart';
import '../../widgets/captcha_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    // 清除toast重复消息缓存，避免页面切换时重复显示
    ToastUtils.clearDuplicateCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2), // 深蓝色 - 水务主题
              Color(0xFF42A5F5), // 浅蓝色
              Color(0xFF81C784), // 淡绿色 - 环保主题
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoginSuccess) {
                context.showSuccessToast('登录成功');
                context.go('/main');
              } else if (state is AuthFailure) {
                context.showErrorToast(state.error);
                // 登录失败时刷新验证码
                context.read<AuthBloc>().add(const AuthCaptchaRequested());
                _captchaController.clear();
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
                    // 登录表单卡片
                    _buildLoginCard(state),
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

  Widget _buildLoginCard(AuthState state) {
    return Container(
      padding: const EdgeInsets.all(32),
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
        key: _formKey,
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
            const SizedBox(height: 30),
            // 用户名输入框
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: '请输入用户名',
                labelText: '用户名',
                prefixIcon: const Icon(Icons.person_outline),
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
                  return '请输入用户名';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // 密码输入框
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
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
                  return '请输入密码';
                }
                if (value.length < 6) {
                  return '密码长度不能少于6位';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // 图形验证码组件
            CaptchaWidget(
              codeController: _captchaController,
              margin: EdgeInsets.zero,
            ),
            const SizedBox(height: 30),
            // 登录按钮
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state is AuthLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
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
        // 短信登录按钮
        TextButton(
          onPressed: () {
            context.push('/sms-login');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sms_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('短信验证码登录', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 版权信息
        Text(
          '© 2025 高新供水有限公司',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final captchaCode = _captchaController.text.trim();
      if (captchaCode.isEmpty) {
        context.showErrorToast('请输入图形验证码');
        return;
      }

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
  }
}
