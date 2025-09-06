import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:tencent_map_plus/tencent_map_plus.dart';

class Qmap extends StatefulWidget {
  const Qmap({super.key});

  @override
  QmapState createState() => QmapState();
}

class QmapState extends State<Qmap> {
  // late TencentMapController _mapController;
  late TencentMapController _mapController;
  final _projectMarkers = <String, dynamic>{};
  final _storeMarkers = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    TencentMap.init(agreePrivacy: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图')),
      body: TencentMap(
        zoomGesturesEnabled: true,
        onMapCreated: (controller) => onMapCreated(controller, context),
        buildings3dEnabled: true,
        myLocationEnabled: true,
        onTapMarker: (markerId) => _onTapMarker(markerId),
        onCameraMoveEnd: (cameraPosition) => _onCameraMoveEnd(cameraPosition),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4.0,
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        onPressed: backToCurrentLocation,
        child: const Icon(Icons.my_location),
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

        // 添加项目标记
        _addProjectsMarkers([
          {'id': '1', 'lat': 34.984154, 'lng': 113.707490},
          {'id': '2', 'lat': 34.984500, 'lng': 113.710000},
        ]);
        // 添加门店标记
        _addStoreMarkers([
          {'id': '1', 'lat': 34.985000, 'lng': 113.708000},
          {'id': '2', 'lat': 34.983000, 'lng': 113.706000},
        ]);

        // 获取当前视野范围
        final bounds = await _mapController.getVisibleRegion();
        Logger.debug('当前视野范围: $bounds');
      } catch (e) {
        // 处理获取位置失败的情况
        Logger.error('获取位置失败: $e');
        if (context.mounted) context.showErrorToast('获取位置失败: $e');
      }
    }
  }

  void _onCameraMoveEnd(CameraPosition position) async {
    // 获取当前视野范围
    final bounds = await _mapController.getVisibleRegion();
    Logger.debug('当前视野范围: $bounds');
  }

  void _onTapMarker(String markerId) {
    if (markerId.startsWith('project_')) {
      String projectId = markerId.replaceFirst('project_', '');
      Logger.debug('Tapped on project marker: $projectId');
      context.showSuccessToast('Tapped on project marker: $projectId');
      // Handle project marker tap
    } else if (markerId.startsWith('store_')) {
      String storeId = markerId.replaceFirst('store_', '');
      Logger.debug('Tapped on store marker: $storeId');
      // Handle store marker tap
      context.showSuccessToast('Tapped on store marker: $storeId');
    } else {
      Logger.debug('Tapped on unknown marker: $markerId');
    }
  }

  void _addProjectsMarkers(List<Map<String, dynamic>> projectInfos) {
    for (var projectInfo in projectInfos) {
      var position = LatLng(projectInfo['lat'], projectInfo['lng']);
      _mapController.addMarker(
        Marker(
          id: 'project_marker_${projectInfo['id']}',
          bizId: 'project_${projectInfo['id']}',
          position: position,
          icon: Bitmap(asset: "images/proj.png"),
        ),
      );
    }
  }

  void _addStoreMarkers(List<Map<String, dynamic>> storeInfos) {
    for (var storeInfo in storeInfos) {
      var position = LatLng(storeInfo['lat'], storeInfo['lng']);
      _mapController.addMarker(
        Marker(
          id: 'store_marker_${storeInfo['id']}',
          bizId: 'store_${storeInfo['id']}',
          position: position,
          icon: Bitmap(asset: "images/store.png"),
        ),
      );
    }
  }

  void backToCurrentLocation() async {
    Location location = await _mapController.getUserLocation();
    // _mapController.moveCamera({'target': location.toMap(), 'zoom': 13});
    _mapController.moveCamera(
      CameraPosition(position: location.position, zoom: 13),
    );
  }
}
