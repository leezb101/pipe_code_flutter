/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectUsersPage extends StatelessWidget {
  final int projectId;
  final String code;
  final String orgName;
  final List<MapProjectUser> users;

  const ProjectUsersPage({
    super.key,
    required this.projectId,
    required this.code,
    required this.orgName,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$orgName - 人员列表'),
        elevation: 0,
        backgroundColor: AppTheme.getBusinessColor('project'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        children: [
          // 头部信息卡片
          UnifiedCard(
            title: '组织信息',
            icon: Icons.business,
            businessType: 'project',
            child: Column(
              children: [
                InfoRow(
                  label: '组织名称',
                  value: orgName,
                  icon: Icons.account_balance,
                  iconColor: AppTheme.getBusinessColor('project'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                InfoRow(
                  label: '组织代码',
                  value: code,
                  icon: Icons.tag,
                  iconColor: AppTheme.getBusinessColor('project'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                InfoRow(
                  label: '人员数量',
                  value: '${users.length}人',
                  icon: Icons.people,
                  iconColor: AppTheme.getBusinessColor('project'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // 用户列表
          UnifiedCard(
            title: '人员列表',
            icon: Icons.people,
            businessType: 'project',
            child: Column(
              children: users
                  .map((user) => _buildUserItem(context, user))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, MapProjectUser user) {
    return UserInfoWidget(
      name: user.name ?? '未知用户',
      phone: user.phone,
      title: user.realHandler == true ? '实际操作人' : null,
      showPushOption: false,
      trailing: // 需要一个可以拨打电话的按钮
      IconButton(
        icon: const Icon(Icons.phone, color: Colors.green),
        onPressed: () {
          // 可以添加拨打电话功能
          if (user.phone != null && user.phone!.isNotEmpty) {
            // 使用url_launcher或其他方式拨打电话
            launchUrl(Uri.parse('tel:${user.phone}'));
          } else {
            // 显示没有电话号码的提示
            context.showErrorToast('该用户没有电话号码');
          }
        },
      ),
      onTap: () {
        // 可以添加用户详情查看功能
      },
    );
  }
}
