/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// 地图上的项目信息数据模型
class MapProjectInfo {
  final int id;
  final String projectName;
  final String projectCode;
  final String projectStart;
  final String projectEnd;
  final String createdName;
  final int createdId;
  final int status;
  final String lng;
  final String lat;

  const MapProjectInfo({
    required this.id,
    required this.projectName,
    required this.projectCode,
    required this.projectStart,
    required this.projectEnd,
    required this.createdName,
    required this.createdId,
    required this.status,
    required this.lng,
    required this.lat,
  });

  /// 从 Map 创建实例
  factory MapProjectInfo.fromMap(Map<String, dynamic> map) {
    return MapProjectInfo(
      id: map['id'] ?? 0,
      projectName: map['projectName']?.toString() ?? '',
      projectCode: map['projectCode']?.toString() ?? '',
      projectStart: map['projectStart']?.toString() ?? '',
      projectEnd: map['projectEnd']?.toString() ?? '',
      createdName: map['createdName']?.toString() ?? '',
      createdId: map['createdId'] ?? 0,
      status: map['status'] ?? 0,
      lng: map['lng']?.toString() ?? '',
      lat: map['lat']?.toString() ?? '',
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'projectCode': projectCode,
      'projectStart': projectStart,
      'projectEnd': projectEnd,
      'createdName': createdName,
      'createdId': createdId,
      'status': status,
      'lng': lng,
      'lat': lat,
    };
  }
}
