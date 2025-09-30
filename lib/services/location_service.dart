import 'dart:async';
import 'package:coordtransform_dart/coordtransform_dart.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/utils/rsa_encryption_util.dart';

// A simple data class for location.
class Location {
  final double latitude;
  final double longitude;

  Location(this.latitude, this.longitude);
}

/// A service to abstract the logic of fetching the device's location.
///
/// This implementation uses the `geolocator` plugin to fetch real-world
/// location data and handles permission requests gracefully.
class LocationService {
  static Location? _cachedLocation;
  static DateTime? _lastCacheTime;

  // Cache location for 10 seconds to avoid excessive calls.
  static const Duration _cacheDuration = Duration(seconds: 10);

  /// Fetches the current location, returning a cached value if available and not expired.
  ///
  /// This method handles permission checks and requests internally.
  /// Returns `null` if permissions are denied or if the location cannot be
  /// fetched within the given [timeout].
  static Future<Location?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Return cached value if it's still valid.
    if (_cachedLocation != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheDuration) {
      return _cachedLocation;
    }

    // Check and request permissions before fetching location.
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      print('Location permission not granted.');
      return null;
    }

    late LocationSettings locationSettings;

    // Set up location settings with a timeout.
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: timeout,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
      );
    }
    try {
      // Fetch the real position using geolocator.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      Location location = Location(position.latitude, position.longitude);
      final gcj02Location = CoordinateTransformUtil.wgs84ToGcj02(
        location.longitude,
        location.latitude,
      );
      location = Location(gcj02Location.last, gcj02Location.first);

      // Update cache.
      _cachedLocation = location;
      _lastCacheTime = DateTime.now();

      return location;
    } catch (e) {
      // Handle timeout or other errors by returning null.
      print('Could not get location: $e');
      return null;
    }
  }

  /// 获取当前位置的地址信息
  ///
  /// 使用QQ地图API将当前经纬度转换为可读的地址字符串
  /// 返回地址字符串，如果获取失败则返回错误信息
  static Future<String> getCurrentAddress() async {
    // 这里需要先调用 getCurrentLocation 方法，确保已经获取了经纬度
    final location = await getCurrentLocation();
    if (location == null) {
      return '暂无有效位置';
    }

    try {
      return await _fetchAddressFromQQLbs(location);
    } catch (e) {
      print('Failed to get address from QQ LBS: $e');
      return '地址解析失败';
    }
  }

  /// 通过QQ LBS API获取地址信息
  static Future<String> _fetchAddressFromQQLbs(Location location) async {
    try {
      print('开始调用QQ LBS API获取地址信息');

      final qqLbsService = ApiServiceFactory.createQQLbsService();

      // 获取key
      // final keyResult = await qqLbsService.getKey();
      // if (keyResult.code != 200 || keyResult.data == null) {
      // throw Exception('Failed to get API key: ${keyResult.msg}');
      // }

      // 解密服务端返回的加密key（当前暂时使用原始key）
      // final encryptedApiKey = keyResult.data!;
      // final apiKey = RSAEncryptionUtil.decryptRSA(encryptedApiKey);
      // final apiKey = 'HTXBZ-Z7YW7-X52XG-PBTSQ-V25PF-S7B22';

      print('Key处理完成，准备调用QQ LBS API');

      // 准备请求参数
      final requestPath = '/ws/geocoder/v1';
      final locationParam = '${location.latitude},${location.longitude}';

      final params = <String, String>{
        'location': locationParam,
        'get_poi': '1',
        'output': 'json',
        'path': requestPath,
      };

      // 获取签名
      final sigResult = await qqLbsService.getSig(params: params);

      if (sigResult.code != 200 || sigResult.data == null) {
        throw Exception('Failed to get signature: ${sigResult.msg}');
      }
      final signature = sigResult.data!;

      // 构建完整的请求URL
      final dio = Dio();
      final url = 'https://apis.map.qq.com$requestPath';

      // 构建查询参数，包含签名和其他必要参数
      Map<String, dynamic> queryParams = Map<String, dynamic>.from(params)
        ..remove('path')
        ..map((key, value) {
          return MapEntry(key, Uri.encodeComponent(value));
        });
      queryParams['sig'] = signature['data']['s'];
      queryParams['key'] = signature['data']['k'];

      // 发起请求
      final response = await dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // 检查API响应状态
        if (data['status'] == 0 && data['result'] != null) {
          final result = data['result'] as Map<String, dynamic>;

          // 优先返回推荐地址，否则返回标准地址
          if (result['formatted_addresses'] != null) {
            final formattedAddresses =
                result['formatted_addresses'] as Map<String, dynamic>;
            if (formattedAddresses['recommend'] != null) {
              print('QQ LBS API调用成功，获取到地址');
              return formattedAddresses['recommend'] as String;
            }
          }

          if (result['address'] != null) {
            print('QQ LBS API调用成功，获取到标准地址');
            return result['address'] as String;
          }
        } else {
          final message = data['message'] ?? '地址解析失败';
          throw Exception('QQ LBS API error: $message');
        }
      }

      return '地址解析失败';
    } catch (e) {
      print('QQ LBS API调用失败: $e');
      // 提供降级处理
      print('降级处理：返回坐标信息');
      return '位置: (${location.latitude}, ${location.longitude})';
    }
  }

  /// Checks and requests location permissions.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      // Optionally, you could prompt the user to enable them.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true). According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // You might want to show a dialog that guides the user to the settings.
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}
