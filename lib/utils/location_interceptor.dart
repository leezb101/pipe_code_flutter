import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/location_service.dart';
import 'logger.dart'; // Assuming you have a logger utility.

/// A Dio interceptor that injects location data (latitude and longitude)
/// into the request body for a specific whitelist of endpoint patterns.
class LocationInterceptor extends Interceptor {
  /// A list of endpoint path patterns (regular expressions) that should have
  /// location data injected.
  /// Example: {r'^/api/v1/tasks/\d+$', r'/api/v2/reports'}
  final List<String> endpointPatterns;

  /// The maximum time to wait for a location fix.
  final Duration timeout;

  LocationInterceptor({
    required this.endpointPatterns,
    this.timeout = const Duration(seconds: 3),
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if the request path matches any of the patterns in our whitelist.
    final shouldInject = endpointPatterns.any((pattern) {
      try {
        return RegExp(pattern).hasMatch(options.path);
      } catch (e) {
        Logger.error(
          'LocationInterceptor: Invalid regex pattern: "$pattern". Error: $e',
          tag: 'Network',
        );
        return false;
      }
    });

    if (!shouldInject) {
      return handler.next(options);
    }

    try {
      // Fetch the current location.
      final location = await LocationService.getCurrentLocation(
        timeout: timeout,
      );

      // If location is not available, proceed without injection and log a warning.
      if (location == null) {
        Logger.warning(
          'LocationInterceptor: Could not obtain location for ${options.path}. Proceeding without injection.',
          tag: 'Network',
        );
        return handler.next(options);
      }

      final lat = location.latitude;
      final lng = location.longitude;

      // Inject location data based on the request body type.
      _injectLocationData(options, lat, lng);

      Logger.info(
        'LocationInterceptor: Injected location ($lat, $lng) into ${options.path}.',
        tag: 'Network',
      );

      return handler.next(options);
    } catch (e, st) {
      Logger.error(
        'LocationInterceptor: Unexpected error: $e\n$st',
        tag: 'Network',
      );
      // In case of any error, do not block the request.
      return handler.next(options);
    }
  }

  void _injectLocationData(
    RequestOptions options,
    double latitude,
    double longitude,
  ) {
    final data = options.data;

    if (data is Map) {
      // For standard map payloads.
      options.data = {...data, 'lat': latitude, 'lng': longitude};
    } else if (data is FormData) {
      // For multipart/form-data payloads.
      data.fields.addAll([
        MapEntry('lat', latitude.toString()),
        MapEntry('lng', longitude.toString()),
      ]);
    } else if (data is String &&
        (options.contentType?.contains('application/json') ?? false)) {
      // For JSON string payloads.
      try {
        final jsonData = json.decode(data);
        if (jsonData is Map) {
          jsonData['lat'] = latitude;
          jsonData['lng'] = longitude;
          options.data = json.encode(jsonData);
        }
      } catch (e) {
        Logger.warning(
          'LocationInterceptor: Failed to decode and inject into JSON string body.',
          tag: 'Network',
        );
      }
    } else if (data == null) {
      // If there is no body, create one.
      options.data = {'lat': latitude, 'lng': longitude};
    }
  }
}
