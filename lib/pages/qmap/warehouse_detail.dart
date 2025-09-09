/*
 * @Author: LeeZB
 * @Date: 2025-08-27 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-27 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class WarehouseDetailPage extends StatefulWidget {
  final int warehouseId;

  const WarehouseDetailPage({super.key, required this.warehouseId});

  @override
  State<WarehouseDetailPage> createState() => _WarehouseDetailPageState();
}

class _WarehouseDetailPageState extends State<WarehouseDetailPage> {
  late MapApiService _apiService;
  Map<String, dynamic>? _warehouseDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = ApiServiceFactory.createMapApiService();
    _loadWarehouseDetail();
  }

  Future<void> _loadWarehouseDetail() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.fetchMapWarehouseDetail(
        widget.warehouseId,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _warehouseDetail = result.data;
          _isLoading = false;
        });
        Logger.debug('Warehouse detail loaded successfully: ${result.data}');
      } else {
        setState(() {
          _errorMessage = result.msg.isNotEmpty ? result.msg : '获取仓库详情失败';
          _isLoading = false;
        });
        Logger.error('Failed to load warehouse detail: ${result.msg}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = '网络错误: $e';
        _isLoading = false;
      });
      Logger.error('Error loading warehouse detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('仓库详情'),
        elevation: 0,
        backgroundColor: AppTheme.getBusinessColor('warehouse'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return common.LoadingWidget(message: '加载仓库详情中...');
    }

    if (_errorMessage != null) {
      return common.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadWarehouseDetail,
      );
    }

    if (_warehouseDetail == null) {
      return const Center(
        child: Text(
          '暂无仓库数据',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWarehouseDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildBasicInfoCard(),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildLocationInfoCard(),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildWarehouseUsersCard(),
            const SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return UnifiedCard(
      title: '仓库概览',
      icon: Icons.warehouse,
      businessType: 'warehouse',
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSummaryInfo(),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo() {
    final name = _warehouseDetail?['name']?.toString() ?? '未知仓库';
    final warehouseUsers = _warehouseDetail?['warehouseUsers'] as List? ?? [];
    final isRealWarehouse = _warehouseDetail?['isRealWarehouse'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.business, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMedium,
                        vertical: AppTheme.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: isRealWarehouse
                            ? Colors.blue[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                      ),
                      child: Text(
                        isRealWarehouse ? '实体仓库' : '虚拟仓库',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isRealWarehouse
                              ? Colors.blue[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '管理员: ${warehouseUsers.length} 人',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    final id = _warehouseDetail?['id']?.toString() ?? '';
    final name = _warehouseDetail?['name']?.toString() ?? '未知仓库';
    final address = _warehouseDetail?['address']?.toString() ?? '地址未知';
    final isRealWarehouse = _warehouseDetail?['isRealWarehouse'] ?? false;

    return UnifiedCard(
      title: '基本信息',
      icon: Icons.info_outline,
      businessType: 'warehouse',
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '仓库名称',
            value: name,
            icon: Icons.business,
            iconColor: AppTheme.getBusinessColor('warehouse'),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '仓库地址',
            value: address,
            icon: Icons.location_on,
            iconColor: AppTheme.getBusinessColor('warehouse'),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '仓库类型',
            value: isRealWarehouse ? '实体仓库' : '虚拟仓库',
            icon: isRealWarehouse ? Icons.store : Icons.cloud,
            iconColor: AppTheme.getBusinessColor('warehouse'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoCard() {
    final lat = _warehouseDetail?['lat']?.toString() ?? '';
    final lng = _warehouseDetail?['lng']?.toString() ?? '';

    if (lat.isEmpty || lng.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '位置信息',
      icon: Icons.map,
      businessType: 'warehouse',
      child: Column(
        children: [
          InfoRow(
            label: '纬度',
            value: lat,
            icon: Icons.place,
            iconColor: AppTheme.getBusinessColor('warehouse'),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '经度',
            value: lng,
            icon: Icons.place,
            iconColor: AppTheme.getBusinessColor('warehouse'),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildLocationActions(lat, lng),
        ],
      ),
    );
  }

  Widget _buildLocationActions(String lat, String lng) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('warehouse'),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            onPressed: () => _openInMap(lat, lng),
            icon: const Icon(Icons.navigation, size: 18),
            label: const Text('地图导航'),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseUsersCard() {
    final warehouseUsers = _warehouseDetail?['warehouseUsers'] as List? ?? [];

    if (warehouseUsers.isEmpty) {
      return UnifiedCard(
        title: '仓库管理员',
        icon: Icons.people,
        businessType: 'warehouse',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                '暂无管理员信息',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return UnifiedCard(
      title: '仓库管理员 (${warehouseUsers.length})',
      icon: Icons.people,
      businessType: 'warehouse',
      child: Column(
        children: warehouseUsers
            .map((user) => _buildUserItem(user as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? '未知用户';
    final phone = user['phone']?.toString() ?? '';
    final id = user['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.getBusinessColorLight('warehouse'),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.getBusinessColorMedium('warehouse')),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.getBusinessColorMedium('warehouse'),
            child: Text(
              name.isNotEmpty ? name[0] : 'U',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.getBusinessColor('warehouse'),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          if (phone.isNotEmpty)
            IconButton(
              onPressed: () => _callPhone(phone),
              icon: Icon(
                Icons.phone,
                color: AppTheme.getBusinessColor('warehouse'),
              ),
              tooltip: '拨打电话',
            ),
        ],
      ),
    );
  }

  void _openInMap(String lat, String lng) {
    // TODO: 实现地图导航功能
    context.showInfoToast('导航功能开发中...');
    Logger.debug('Open navigation to: $lat, $lng');
  }

  void _callPhone(String phone) async {
    final telUrl = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(telUrl))) {
      await launchUrl(Uri.parse(telUrl));
    } else {
      if (mounted) context.showErrorToast('暂时无法拨打电话: $phone');
    }
  }
}
