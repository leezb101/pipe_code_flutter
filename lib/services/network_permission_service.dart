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

  /// Open system settings for the current app to let user enable network permissions or data usage.
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  /// A lightweight connectivity probe via DNS lookup.
  Future<bool> _hasInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream that emits when connectivity changes.
  Stream<ConnectivityResult> onConnectivityChanged() =>
      _connectivity.onConnectivityChanged;
}
