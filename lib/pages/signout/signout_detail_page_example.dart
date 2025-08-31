/*
 * 示例：如何在其他页面中使用 SignoutDetailPage
 * 这是一个示例文件，展示如何从出库记录列表跳转到详情页
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class SignoutRecordListExample extends StatelessWidget {
  // 示例出库记录数据
  final List<Map<String, dynamic>> signoutRecords = [
    {
      'id': 1,
      'warehouseName': '主仓库',
      'materialCount': 5,
      'installUser': '张三',
      'createTime': '2025-08-27 10:30:00',
    },
    {
      'id': 2,
      'warehouseName': '分仓库A',
      'materialCount': 3,
      'installUser': '李四',
      'createTime': '2025-08-27 09:15:00',
    },
    {
      'id': 3,
      'warehouseName': '临时仓库',
      'materialCount': 8,
      'installUser': '王五',
      'createTime': '2025-08-26 16:45:00',
    },
  ];

  SignoutRecordListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('出库记录列表'),
        backgroundColor: AppTheme.getBusinessColor('signout'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        itemCount: signoutRecords.length,
        itemBuilder: (context, index) {
          final record = signoutRecords[index];
          return _buildRecordItem(context, record);
        },
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, Map<String, dynamic> record) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: GestureDetector(
        onTap: () => _navigateToDetail(context, record['id']),
        child: UnifiedCard(
          businessType: 'signout',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.output,
                    color: AppTheme.getBusinessColor('signout'),
                    size: 24,
                  ),
                  SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: Text(
                      '出库记录 #${record['id']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacingMedium),
              InfoRow(
                label: '仓库',
                value: record['warehouseName'],
                icon: Icons.warehouse,
                iconColor: AppTheme.getBusinessColor('signout'),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              InfoRow(
                label: '材料数量',
                value: '${record['materialCount']}个',
                icon: Icons.inventory,
                iconColor: AppTheme.getBusinessColor('signout'),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              InfoRow(
                label: '安装人员',
                value: record['installUser'],
                icon: Icons.person,
                iconColor: AppTheme.getBusinessColor('signout'),
              ),
              SizedBox(height: AppTheme.spacingSmall),
              InfoRow(
                label: '创建时间',
                value: record['createTime'],
                icon: Icons.access_time,
                iconColor: AppTheme.getBusinessColor('signout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int signoutId) {
    // 导航到出库详情页面
    // 这里应该使用 go_router 的路由
    context.push('/signout-detail/$signoutId');
  }
}
