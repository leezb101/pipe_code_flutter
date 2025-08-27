/*
 * 示例：如何在其他页面中使用 SignoutDetailPage
 * 这是一个示例文件，展示如何从出库记录列表跳转到详情页
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: signoutRecords.length,
        itemBuilder: (context, index) {
          final record = signoutRecords[index];
          return _buildRecordItem(context, record);
        },
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.output, color: Colors.orange[700], size: 24),
        ),
        title: Text(
          '出库记录 #${record['id']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.warehouse, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  record['warehouseName'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${record['materialCount']}种物料',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '安装: ${record['installUser']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  record['createTime'].substring(5, 16), // 显示月日和时间
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.blue[600],
          ),
        ),
        onTap: () => _navigateToDetail(context, record['id']),
      ),
    );
  }

  // 导航到出库详情页面的方法
  void _navigateToDetail(BuildContext context, int signoutId) {
    // 方法1: 使用 push (推荐，会在导航栈中添加新页面)
    context.push('/signout-detail?id=$signoutId');

    // 方法2: 使用 go (会替换当前页面)
    // context.go('/signout-detail?id=$signoutId');

    // 方法3: 使用 pushNamed (如果路由有名称的话)
    // context.pushNamed('signout-detail', queryParameters: {'id': signoutId.toString()});
  }
}

// 另一个示例：在搜索结果中使用
class SignoutSearchResultExample extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  const SignoutSearchResultExample({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange[100],
            child: Text(
              '#${result['id']}',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Text(
            '${result['warehouseName']} - ${result['materialCount']}种物料',
          ),
          subtitle: Text('安装: ${result['installUser']}'),
          trailing: const Icon(Icons.visibility),
          onTap: () {
            // 点击搜索结果跳转到详情页
            context.push('/signout-detail?id=${result['id']}');
          },
        );
      },
    );
  }
}

// 示例：在FloatingActionButton中快速访问最近的出库记录
class QuickAccessExample extends StatelessWidget {
  const QuickAccessExample({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showRecentSignouts(context),
      icon: const Icon(Icons.output),
      label: const Text('最近出库'),
      backgroundColor: Colors.orange,
    );
  }

  void _showRecentSignouts(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近出库记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  final id = index + 1;
                  return ListTile(
                    title: Text('出库记录 #$id'),
                    subtitle: Text('查看详细信息'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pop(context); // 关闭底部弹窗
                      context.push('/signout-detail?id=$id'); // 跳转到详情页
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
