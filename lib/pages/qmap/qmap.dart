import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:tencent_map_flutter/tencent_map_flutter.dart';

class Qmap extends StatefulWidget {
  const Qmap({super.key});

  @override
  QmapState createState() => QmapState();
}

class QmapState extends State<Qmap> {
  late TencentMapController _mapController;

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
        buildings3dEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (controller) async {
          _mapController = controller;
          try {
            Location location = await _mapController.getUserLocation();
            _mapController.moveCamera(
              CameraPosition(
                position: location.position,
                heading: location.heading,
              ),
            );
          } catch (e) {
            // 处理获取位置失败的情况
            Logger.error('获取位置失败: $e');
            if (context.mounted) context.showErrorToast('获取位置失败: $e');
          }
        },
      ),
    );
  }
}
