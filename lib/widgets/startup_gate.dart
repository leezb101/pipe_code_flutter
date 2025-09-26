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
  NetworkPermissionStatus? _permissionStatus;
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
      // 网络连接有问题，检查网络权限状态
      final permissionStatus = await _network.checkNetworkPermission();
      if (!mounted) return;

      setState(() {
        _status = status;
        _permissionStatus = permissionStatus;
        _loading = false;
      });
    }
  }

  /// 请求网络权限
  Future<void> _requestNetworkPermission() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final newPermissionStatus = await _network.requestNetworkPermission();
      if (!mounted) return;

      setState(() {
        _permissionStatus = newPermissionStatus;
        _loading = false;
      });

      // 如果权限状态有改善，重新检查网络状态
      if (newPermissionStatus == NetworkPermissionStatus.granted) {
        _ensureReady();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '请求网络权限失败：$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;

    final isNoNet = _status == NetworkAccessStatus.noConnection;
    final isBlocked = _status == NetworkAccessStatus.blocked;
    final isPermissionDenied =
        _permissionStatus == NetworkPermissionStatus.denied ||
        _permissionStatus == NetworkPermissionStatus.restricted;
    final isPermissionPermanentlyDenied =
        _permissionStatus == NetworkPermissionStatus.permanentlyDenied;

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
                        _getStatusTitle(
                          isNoNet,
                          isBlocked,
                          isPermissionDenied,
                          isPermissionPermanentlyDenied,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStatusMessage(
                          isNoNet,
                          isBlocked,
                          isPermissionDenied,
                          isPermissionPermanentlyDenied,
                        ),
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
                        children: _buildActionButtons(
                          isNoNet,
                          isBlocked,
                          isPermissionDenied,
                          isPermissionPermanentlyDenied,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _getStatusTitle(
    bool isNoNet,
    bool isBlocked,
    bool isPermissionDenied,
    bool isPermissionPermanentlyDenied,
  ) {
    if (isPermissionPermanentlyDenied) {
      return '网络权限被永久拒绝';
    } else if (isPermissionDenied) {
      return '网络权限受限';
    } else if (isNoNet) {
      return '未检测到网络连接';
    } else {
      return '网络受限，无法访问互联网';
    }
  }

  String _getStatusMessage(
    bool isNoNet,
    bool isBlocked,
    bool isPermissionDenied,
    bool isPermissionPermanentlyDenied,
  ) {
    if (isPermissionPermanentlyDenied) {
      return '应用的网络权限已被永久拒绝，请到系统设置中手动开启网络权限';
    } else if (isPermissionDenied) {
      return '应用可能被系统限制了网络访问，请检查网络权限设置';
    } else if (isNoNet) {
      return '请开启 Wi‑Fi 或蜂窝数据后重试';
    } else {
      return '可能被系统限制了"无线数据"或代理受限，请前往设置开启后返回';
    }
  }

  List<Widget> _buildActionButtons(
    bool isNoNet,
    bool isBlocked,
    bool isPermissionDenied,
    bool isPermissionPermanentlyDenied,
  ) {
    List<Widget> buttons = [
      ElevatedButton(onPressed: _ensureReady, child: const Text('重试')),
    ];

    if (isPermissionPermanentlyDenied || isPermissionDenied) {
      buttons.addAll([
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _requestNetworkPermission,
          child: const Text('请求权限'),
        ),
      ]);
    }

    if (isBlocked || isPermissionDenied || isPermissionPermanentlyDenied) {
      buttons.addAll([
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _network.openSystemSettings,
          child: const Text('去设置'),
        ),
      ]);
    }

    return buttons;
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
