/*
 * @Author: LeeZB
 * @Date: 2025-08-27 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-27 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class ProjectDetailPage extends StatelessWidget {
  final int projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目详情'),
        elevation: 0,
        backgroundColor: AppTheme.getBusinessColor('project'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UnifiedCard(
              title: '项目概览',
              icon: Icons.engineering,
              businessType: 'project',
              child: Column(
                children: [
                  InfoRow(
                    label: '项目ID',
                    value: projectId.toString(),
                    icon: Icons.tag,
                    iconColor: AppTheme.getBusinessColor('project'),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  InfoRow(
                    label: '项目状态',
                    value: '开发中...',
                    icon: Icons.construction,
                    iconColor: AppTheme.getBusinessColor('project'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.construction, size: 48, color: Colors.orange[600]),
                  const SizedBox(height: 12),
                  Text(
                    '项目详情页面开发中',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '项目ID: $projectId',
                    style: TextStyle(color: Colors.orange[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
