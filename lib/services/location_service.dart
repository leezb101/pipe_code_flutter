import 'dart:async';
import 'package:coordtransform_dart/coordtransform_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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
      location = Location(gcj02Location.first, gcj02Location.last);

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

  static Future<String> _getCurrentAddress() async {
    // 这里需要先调用 getCurrentLocation 方法，确保已经获取了经纬度
    final location = await getCurrentLocation();
    if (location == null) {
      return '暂无有效位置';
    }
    //TODO: 这里可以调用其他服务来根据经纬度获取地址信息

    return '未知地址';
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
