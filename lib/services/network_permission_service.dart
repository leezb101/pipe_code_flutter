import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Indicates network accessibility status for app startup gating.
enum NetworkAccessStatus {
  granted, // Network connected and internet reachable
  noConnection, // No network connection
  blocked, // Connected but internet not reachable or system restricted
}

/// Indicates network permission status.
enum NetworkPermissionStatus {
  granted, // Network permission granted
  denied, // Network permission denied
  permanentlyDenied, // Network permission permanently denied
  restricted, // Network permission restricted (iOS)
}

class NetworkPermissionService {
  final Connectivity _connectivity;

  NetworkPermissionService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// Check current network accessibility.
  Future<NetworkAccessStatus> checkStatus() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return NetworkAccessStatus.noConnection;
    }

    final reachable = await _hasInternetConnectivity();
    if (reachable) return NetworkAccessStatus.granted;
    return NetworkAccessStatus.blocked;
  }

  /// Check if network permission is granted.
  Future<NetworkPermissionStatus> checkNetworkPermission() async {
    try {
      // 对于网络访问，我们主要检查系统级别的网络限制
      // 在 Android 上，大多数网络权限是在manifest中声明的，运行时不需要请求
      // 这里我们主要检查设备是否有网络连接能力和是否被系统限制

      final result = await _connectivity.checkConnectivity();

      // 如果完全没有网络连接
      if (result == ConnectivityResult.none) {
        return NetworkPermissionStatus.denied;
      }

      // 如果有连接但无法访问互联网，可能是系统限制或代理问题
      final hasInternet = await _hasInternetConnectivity();
      if (!hasInternet) {
        // 这种情况下，可能是权限被限制或网络配置问题
        return NetworkPermissionStatus.restricted;
      }

      return NetworkPermissionStatus.granted;
    } catch (e) {
      return NetworkPermissionStatus.denied;
    }
  }

  /// Request network permission from user.
  /// 注意: 在移动端，网络权限通常不能通过代码直接请求
  /// 这个方法主要用于引导用户到系统设置
  Future<NetworkPermissionStatus> requestNetworkPermission() async {
    try {
      // 对于网络访问限制，我们不能直接请求权限
      // 但可以检查当前状态，并引导用户到设置页面
      final currentStatus = await checkNetworkPermission();

      if (currentStatus == NetworkPermissionStatus.restricted ||
          currentStatus == NetworkPermissionStatus.denied) {
        // 引导用户到系统设置
        await openSystemSettings();

        // 等待用户返回后重新检查状态
        await Future.delayed(const Duration(seconds: 1));
        return await checkNetworkPermission();
      }

      return currentStatus;
    } catch (e) {
      return NetworkPermissionStatus.denied;
    }
  }

  /// Check if app has network permission.
  Future<bool> hasNetworkPermission() async {
    final status = await checkNetworkPermission();
    return status == NetworkPermissionStatus.granted;
  }

  /// Open system settings for the current app to let user enable network permissions or data usage.
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  /// A lightweight connectivity probe via DNS lookup.
  Future<bool> _hasInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream that emits when connectivity changes.
  Stream<ConnectivityResult> onConnectivityChanged() =>
      _connectivity.onConnectivityChanged;
}
