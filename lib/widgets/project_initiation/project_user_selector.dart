/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import '../../models/project/project_initiation.dart';

/// 项目用户选择器组件
class ProjectUserSelector extends StatelessWidget {
  final String title;
  final List<ProjectUser> users;
  final VoidCallback onAddUser;
  final Function(int index) onRemoveUser;

  const ProjectUserSelector({
    super.key,
    required this.title,
    required this.users,
    required this.onAddUser,
    required this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            OutlinedButton(
              onPressed: onAddUser,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('添加${_getRoleLabel(title)}'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          return _buildUserCard(context, user, index);
        }).toList(),
        if (users.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无${_getRoleLabel(title)}信息',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, ProjectUser user, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: user.orgName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [user.orgName, 'XXXXX监理公司', 'XXXXX工程有限公司'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                // 处理公司选择变化
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: user.name,
                    decoration: const InputDecoration(
                      labelText: '姓名',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      // 处理姓名变化
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: user.phone,
                    decoration: const InputDecoration(
                      labelText: '电话',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      // 处理电话变化
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onRemoveUser(index),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('删除'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String title) {
    if (title.contains('监理')) return '监理方';
    if (title.contains('施工')) return '施工方';
    if (title.contains('建设')) return '建设方';
    return '用户';
  }
}