/*
 * 测试网络日志功能的临时脚本
 * 用于验证验证码接口是否正确返回img_code header字段
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/services/tracing/improved_tracing_manager.dart';
import 'lib/config/service_locator.dart';
import 'lib/config/app_config.dart';
import 'lib/bloc/auth/auth_bloc.dart';
import 'lib/bloc/auth/auth_event.dart';
import 'lib/bloc/auth/auth_state.dart';
import 'lib/repositories/interfaces/auth_repository.dart';
import 'lib/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置为开发环境，使用真实API
  await setupDevelopmentEnvironment();
  await AppConfig.initialize();

  Logger.info('开始网络日志测试', tag: 'TEST');

  runApp(const NetworkLogTestApp());
}

class NetworkLogTestApp extends StatelessWidget {
  const NetworkLogTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '网络日志测试',
      home: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: getIt<AuthRepository>(),
          tracingManager: getIt<ImprovedTracingManager>(),
        ),
        child: const TestPage(),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络日志测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCaptchaLoaded) {
            Logger.info(
              '验证码加载成功，数据长度: ${state.captchaBase64.length}',
              tag: 'TEST',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('验证码加载成功！数据长度: ${state.captchaBase64.length}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthFailure) {
            Logger.error('验证码加载失败: ${state.error}', tag: 'TEST');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('验证码加载失败: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '网络日志测试',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '点击下面的按钮测试验证码接口，并查看控制台日志输出。',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: state is AuthCaptchaLoading
                      ? null
                      : () {
                          Logger.info('用户点击测试验证码按钮', tag: 'TEST');
                          context.read<AuthBloc>().add(
                            const AuthCaptchaRequested(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: state is AuthCaptchaLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('请求中...'),
                          ],
                        )
                      : const Text(
                          '🔍 测试验证码接口',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 20),
                if (state is AuthCaptchaLoaded) ...[
                  const Text(
                    '验证码数据已获取（查看控制台详细日志）',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text('数据长度: ${state.captchaBase64.length} 字符'),
                        const SizedBox(height: 8),
                        Text(
                          '数据预览: ${state.captchaBase64.substring(0, 50)}...',
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                const Text(
                  '检查要点：',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('1. 请求日志是否显示完整的URL和headers'),
                const Text('2. 响应日志是否包含img_code header字段'),
                const Text('3. 响应体是否包含base64图片数据'),
                const Text('4. 网络请求耗时统计'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Text(
                    '请查看Android Studio或VS Code的Debug Console输出，'
                    '应该能看到详细的网络请求和响应日志。',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
