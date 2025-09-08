import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// removed unused imports
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:tencent_map_plus/tencent_map_plus.dart';
import 'package:haversine_distance/haversine_distance.dart' as haversine;
import 'package:pipe_code_flutter/bloc/qmap/qmap_bloc.dart';
import 'package:pipe_code_flutter/bloc/qmap/qmap_event.dart';
import 'package:pipe_code_flutter/bloc/qmap/qmap_state.dart';
import 'package:pipe_code_flutter/widgets/overlayed_dialog.dart';
import 'dart:async';

class Qmap extends StatefulWidget {
  const Qmap({super.key});

  @override
  QmapState createState() => QmapState();
}

class QmapState extends State<Qmap> {
  // late TencentMapController _mapController;
  late TencentMapController _mapController;
  // marker caches are not used currently, keeping behavior unchanged
  late MapApiService _apiservice;
  BuildContext? _blocCtx; // descendant context under BlocProvider
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    TencentMap.init(agreePrivacy: true);
    _apiservice = ApiServiceFactory.createMapApiService();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QmapBloc(apiService: _apiservice),
      child: Builder(
        builder: (ctx) {
          _blocCtx = ctx; // capture descendant context under provider
          return BlocListener<QmapBloc, QmapBlocState>(
            // Only react to effect changes for map marker updates and toasts
            listenWhen: (prev, curr) => prev.effect != curr.effect,
            listener: (context, state) {
              // Handle toast effects
              final effect = state.effect;
              if (effect?.toastMessage != null) {
                if (effect!.error) {
                  if (context.mounted) {
                    context.showErrorToast(effect.toastMessage!);
                  }
                } else {
                  if (context.mounted) {
                    context.showSuccessToast(effect.toastMessage!);
                  }
                }
              }
              // Incremental marker updates from effect
              if (effect?.storeIdsToRemove != null &&
                  effect!.storeIdsToRemove!.isNotEmpty) {
                _removeStoreMarkersByIds(effect.storeIdsToRemove!);
              }
              if (effect?.storesToAdd != null &&
                  effect!.storesToAdd!.isNotEmpty) {
                _addStoreMarkers(effect.storesToAdd!);
              }
            },
            child: Scaffold(
              appBar: AppBar(title: const Text('地图')),
              body: TencentMap(
                zoomGesturesEnabled: true,
                onMapCreated: (controller) => onMapCreated(controller, context),
                buildings3dEnabled: true,
                myLocationEnabled: true,
                onTapMarker: (markerId) => _onTapMarker(markerId),
                onCameraMoveEnd: (cameraPosition) =>
                    _onCameraMoveEndDebounced(cameraPosition),
              ),
              floatingActionButton: FloatingActionButton(
                elevation: 4.0,
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                onPressed: backToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> onMapCreated(
    TencentMapController controller,
    BuildContext context,
  ) async {
    {
      _mapController = controller;

      // 定位到用户当前位置
      try {
        Future<Location> getValidLocation({int retries = 5}) async {
          Location location = await _mapController.getUserLocation();
          if (location.position.latitude == 0 &&
              location.position.longitude == 0) {
            if (retries > 0) {
              await Future.delayed(const Duration(seconds: 1));
              return await getValidLocation(retries: retries - 1);
            } else {
              throw Exception('无法获取有效的位置信息');
            }
          }
          return location;
        }

        final location = await getValidLocation();
        _mapController.moveCamera(
          CameraPosition(position: location.position, zoom: 13),
        );

        // 获取当前视野范围
        final bounds = await _mapController.getVisibleRegion();
        Logger.debug('当前视野范围: $bounds');
      } catch (e) {
        // 处理获取位置失败的情况
        Logger.error('获取位置失败: $e');
        if (!context.mounted) {
          return;
        }
        context.showErrorToast('获取位置失败: $e');
      }
    }
  }

  void _onCameraMoveEnd(CameraPosition position) async {
    // 获取当前视野范围
    final bounds = await _mapController.getVisibleRegion();
    Logger.debug('当前视野范围: $bounds');
    final center = haversine.Location(
      bounds['center']['lat'],
      bounds['center']['lng'],
    );
    final sw = haversine.Location(bounds['sw']['lat'], bounds['sw']['lng']);
    final hDistance = haversine.HaversineDistance();
    final distance = hDistance.haversine(center, sw, haversine.Unit.METER);
    Logger.debug('当前视野半径: ${distance.toStringAsFixed(2)} 米');
    // 分发事件给 BLoC，由 BLoC 请求并规范化数据
    if (mounted && _blocCtx != null) {
      _blocCtx!.read<QmapBloc>().add(
        CameraViewChanged(
          center: LatLng(bounds['center']['lat'], bounds['center']['lng']),
          radiusMeters: distance,
        ),
      );
    }
  }

  void _onCameraMoveEndDebounced(CameraPosition position) {
    // 300ms 防抖，避免频繁请求
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _onCameraMoveEnd(position);
    });
  }

  Future<List?> fetchWarehouses(LatLng center, double r) async {
    final lat = center.latitude;
    final lng = center.longitude;
    final radius = r;

    try {
      final result = await _apiservice.fetchMapWarehouses(lat, lng, radius);
      if (result.isSuccess) {
        Logger.debug('Fetched warehouses: ${result.data}');
        return result.data;
      } else {
        Logger.error('Failed to fetch warehouses: ${result.msg}');
        if (!mounted) {
          return null;
        }
        context.showErrorToast('Failed to fetch warehouses: ${result.msg}');
      }
    } catch (e) {
      Logger.error('Error fetching warehouses: $e');
      if (!mounted) {
        return null;
      }
      context.showErrorToast('Error fetching warehouses: $e');
    }
    return null;
  }

  void _onTapMarker(String markerId) {
    // 将点击事件交给 BLoC 触发同样的提示效果
    if (!mounted || _blocCtx == null) return;
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => OverlayedDialog(
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Marker Tapped',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('You tapped on marker with ID: $markerId'),
            ],
          ),
        ),
        onClose: () {
          overlayEntry.remove();
        },
      ),
    );
    overlay.insert(overlayEntry);
    _blocCtx!.read<QmapBloc>().add(MarkerTapped(markerId));
  }

  // 保留项目点位方法可按需恢复

  void _addStoreMarkers(List<Map<String, dynamic>> storeInfos) {
    for (var storeInfo in storeInfos) {
      var position = LatLng(storeInfo['lat'], storeInfo['lng']);
      _mapController.addMarker(
        Marker(
          id: 'store_marker_${storeInfo['id']}',
          bizId: 'store_${storeInfo['id']}',
          title: storeInfo['title'],
          position: position,
          icon: Bitmap(asset: "images/store.png"),
        ),
      );
    }
  }

  void _removeStoreMarkersByIds(List<String> storeIds) {
    for (final id in storeIds) {
      // Remove by the marker id we assigned in addMarker
      _mapController.removeMarker('store_marker_$id');
      // If SDK requires removal by bizId instead, uncomment next line and adjust
      // _mapController.removeMarkerByBizId('store_$id');
    }
  }

  void backToCurrentLocation() async {
    Location location = await _mapController.getUserLocation();
    // _mapController.moveCamera({'target': location.toMap(), 'zoom': 13});
    _mapController.moveCamera(
      CameraPosition(position: location.position, zoom: 13),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
