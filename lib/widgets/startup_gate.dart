import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/config/service_locator.dart'
    show initializeAppData;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import 'package:pipe_code_flutter/services/network_permission_service.dart';

class StartupGate extends StatefulWidget {
  final Widget child;
  const StartupGate({super.key, required this.child});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> with WidgetsBindingObserver {
  final _network = NetworkPermissionService();
  StreamSubscription? _connSub;
  bool _ready = false;
  bool _loading = true;
  NetworkAccessStatus? _status;
  String? _error;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connSub = _network.onConnectivityChanged().listen((_) {
      _ensureReady();
    });
    _ensureReady();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensureReady();
    }
  }

  Future<void> _ensureReady() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final status = await _network.checkStatus();
    if (!mounted) return;

    if (status == NetworkAccessStatus.granted) {
      try {
        await initializeAppData();
        if (!mounted) return;
        // 在网络就绪并完成初始化后，触发一次登录状态检查以支持自动登录
        if (!_authChecked) {
          context.read<AuthBloc>().add(AuthCheckRequested());
          _authChecked = true;
        }
        setState(() {
          _ready = true;
          _loading = false;
          _status = status;
        });
      } catch (e) {
        setState(() {
          _error = '初始化失败：$e';
          _loading = false;
          _status = status;
        });
      }
    } else {
      setState(() {
        _status = status;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;

    final isNoNet = _status == NetworkAccessStatus.noConnection;
    final isBlocked = _status == NetworkAccessStatus.blocked;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _loading
              ? const _Loading()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 72, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        isNoNet ? '未检测到网络连接' : '网络受限，无法访问互联网',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isNoNet
                            ? '请开启 Wi‑Fi 或蜂窝数据后重试'
                            : '可能被系统限制了“无线数据”或代理受限，请前往设置开启后返回',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _ensureReady,
                            child: const Text('重试'),
                          ),
                          const SizedBox(width: 12),
                          if (isBlocked)
                            OutlinedButton(
                              onPressed: _network.openSystemSettings,
                              child: const Text('去设置'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text('正在检查网络并初始化…'),
      ],
    );
  }
}
