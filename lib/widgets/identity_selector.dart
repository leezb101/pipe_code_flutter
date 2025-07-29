/*
 * @Author: LeeZB
 * @Date: 2025-07-29 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 16:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';

/// 身份选择组件 - 仓管员用户选择登录身份
class IdentitySelector extends StatelessWidget {
  const IdentitySelector({
    super.key,
    required this.wxLoginVO,
    required this.onProjectParticipantSelected,
    required this.onStorekeeperSelected,
  });

  final dynamic wxLoginVO;
  final VoidCallback onProjectParticipantSelected;
  final VoidCallback onStorekeeperSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择登录身份'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顶部用户信息
            _buildUserInfoCard(context),
            const SizedBox(height: 40),

            // 身份选择提示
            _buildSelectionTitle(),
            const SizedBox(height: 30),

            // 身份选择卡片
            Expanded(
              child: Column(
                children: [
                  _buildProjectModeCard(context),
                  const SizedBox(height: 20),
                  _buildStorekeeperModeCard(context),
                ],
              ),
            ),

            // 底部说明
            _buildSelectionNote(),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(
              wxLoginVO.name.isNotEmpty ? wxLoginVO.name[0] : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wxLoginVO.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '仓管员账户',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择标题
  Widget _buildSelectionTitle() {
    return const Column(
      children: [
        Text(
          '请选择登录身份',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '根据您的工作需要选择合适的身份模式',
          style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
        ),
      ],
    );
  }

  /// 构建项目参与方卡片
  Widget _buildProjectModeCard(BuildContext context) {
    return _buildModeCard(
      context: context,
      title: '项目参与方',
      subtitle: '参与具体项目的工作',
      description: '• 查看和管理项目信息\n• 执行角色相关的业务操作\n• 与团队协作完成项目任务',
      icon: Icons.business,
      color: const Color(0xFF3498DB),
      onTap: onProjectParticipantSelected,
    );
  }

  /// 构建仓管员卡片
  Widget _buildStorekeeperModeCard(BuildContext context) {
    return _buildModeCard(
      context: context,
      title: '独立仓管员',
      subtitle: '专注库存管理工作',
      description: '• 管理库存物料和设备\n• 处理入库、出库、调拨\n• 进行库存盘点和统计',
      icon: Icons.inventory_2,
      color: const Color(0xFF27AE60),
      onTap: onStorekeeperSelected,
    );
  }

  /// 构建模式卡片
  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D6D7E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建选择说明
  Widget _buildSelectionNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6C757D), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '每次登录都需要重新选择身份，确保符合当前工作需要',
              style: TextStyle(fontSize: 13, color: Color(0xFF6C757D)),
            ),
          ),
        ],
      ),
    );
  }
}