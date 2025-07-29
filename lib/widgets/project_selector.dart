/*
 * @Author: LeeZB
 * @Date: 2025-07-29 16:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 16:15:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import '../models/project/project_info.dart';

/// 项目选择组件 - 用户选择要参与的项目
class ProjectSelector extends StatelessWidget {
  const ProjectSelector({
    super.key,
    required this.wxLoginVO,
    required this.availableProjects,
    required this.onProjectSelected,
    required this.onLogout,
  });

  final dynamic wxLoginVO;
  final List<ProjectInfo> availableProjects;
  final Function(int projectId) onProjectSelected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择项目'),
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
            const SizedBox(height: 24),

            // 项目选择提示
            _buildSelectionTitle(),
            const SizedBox(height: 24),

            // 项目列表
            Expanded(
              child: availableProjects.isEmpty
                  ? _buildNoProjectsView(context)
                  : _buildProjectsList(),
            ),
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
                Text(
                  '手机: ${wxLoginVO.phone}',
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
    );
  }

  /// 构建选择标题
  Widget _buildSelectionTitle() {
    return const Column(
      children: [
        Text(
          '选择参与的项目',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '请从以下项目中选择您要参与的项目',
          style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
        ),
      ],
    );
  }

  /// 构建项目列表
  Widget _buildProjectsList() {
    return ListView.builder(
      itemCount: availableProjects.length,
      itemBuilder: (context, index) {
        final project = availableProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  /// 构建项目卡片
  Widget _buildProjectCard(ProjectInfo project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => onProjectSelected(project.projectId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3498DB).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  size: 28,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.projectName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '项目编号: ${project.projectCode}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    if (project.orgName != null && project.orgName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '机构: ${project.orgName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '角色: ${project.projectRoleType.displayName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF27AE60),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF7F8C8D),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建无项目视图
  Widget _buildNoProjectsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF95A5A6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              size: 60,
              color: Color(0xFF95A5A6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '暂无可参与的项目',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '您当前没有被分配到任何项目',
            style: TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
          ),
          const SizedBox(height: 8),
          const Text(
            '请联系项目管理员为您分配项目权限',
            style: TextStyle(fontSize: 16, color: Color(0xFF95A5A6)),
          ),
          const SizedBox(height: 40),

          // 联系管理员按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton.icon(
              onPressed: () => _showContactInfo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.contact_support),
              label: const Text(
                '联系管理员',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 退出登录按钮
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7F8C8D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF7F8C8D)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text(
                '退出登录',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示联系信息
  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('联系管理员'),
        content: const Text('请联系您的项目管理员或系统管理员，申请项目参与权限。\n\n如需技术支持，请联系系统客服。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}