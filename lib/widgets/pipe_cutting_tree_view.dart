/*
 * @Author: LeeZB
 * @Date: 2025-08-06 20:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 20:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import '../../models/cut/pipe_cutting_tree_node.dart';
import '../../models/cut/pipe_cutting_record.dart';

/// 截管记录树状视图组件
class PipeCuttingTreeView extends StatefulWidget {
  const PipeCuttingTreeView({
    super.key,
    required this.cuttingRecord,
    required this.currentMaterialId,
  });

  final PipeCuttingRecord cuttingRecord;
  final String currentMaterialId;

  @override
  State<PipeCuttingTreeView> createState() => _PipeCuttingTreeViewState();
}

class _PipeCuttingTreeViewState extends State<PipeCuttingTreeView> {
  late TreeController<PipeCuttingTreeNode> treeController;

  @override
  void initState() {
    super.initState();
    _initializeTree();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PipeCuttingTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cuttingRecord != widget.cuttingRecord ||
        oldWidget.currentMaterialId != widget.currentMaterialId) {
      _initializeTree();
    }
  }

  void _initializeTree() {
    // 创建根节点
    final rootNode = PipeCuttingTreeNode.fromCuttingHistoryNode(
      widget.cuttingRecord.cutHisTree,
      isRoot: true,
      currentMaterialId: widget.currentMaterialId,
    );

    treeController = TreeController<PipeCuttingTreeNode>(
      roots: [rootNode],
      childrenProvider: (node) => node.children,
    );

    // 自动展开所有节点
    _expandAllNodes();
  }

  void _expandAllNodes() {
    final allNodes = <PipeCuttingTreeNode>[];
    
    void collectNodes(PipeCuttingTreeNode node) {
      allNodes.add(node);
      for (final child in node.children) {
        collectNodes(child);
      }
    }
    
    for (final root in treeController.roots) {
      collectNodes(root);
    }
    
    for (final node in allNodes) {
      if (node.children.isNotEmpty) {
        treeController.expand(node);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: AnimatedTreeView<PipeCuttingTreeNode>(
            treeController: treeController,
            nodeBuilder: (context, entry) {
              return _buildTreeNode(context, entry);
            },
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '截管记录树状图',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '材料编码: ${widget.cuttingRecord.materialCode}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.cuttingRecord.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '材料名称: ${widget.cuttingRecord.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (widget.cuttingRecord.spec != null) ...[
              const SizedBox(height: 4),
              Text(
                '规格: ${widget.cuttingRecord.spec}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreeNode(BuildContext context, TreeEntry<PipeCuttingTreeNode> entry) {
    final node = entry.node;
    final isExpanded = entry.isExpanded;
    final hasChildren = node.children.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          if (hasChildren) {
            treeController.toggleExpansion(node);
          }
          _showNodeDetails(context, node);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getNodeColor(node),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getNodeBorderColor(node),
              width: node.isCurrent ? 2 : 1,
            ),
            boxShadow: node.isCurrent ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (hasChildren) ...[
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      node.displayText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: node.isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: node.isCurrent ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                  ),
                  if (node.isCurrent) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '当前',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (node.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  node.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getNodeColor(PipeCuttingTreeNode node) {
    if (node.isCurrent) {
      return Theme.of(context).primaryColor.withValues(alpha: 0.1);
    }
    if (node.isRoot) {
      return Colors.blue.withValues(alpha: 0.1);
    }
    return Colors.grey.withValues(alpha: 0.05);
  }

  Color _getNodeBorderColor(PipeCuttingTreeNode node) {
    if (node.isCurrent) {
      return Theme.of(context).primaryColor;
    }
    if (node.isRoot) {
      return Colors.blue;
    }
    return Colors.grey[300]!;
  }

  void _showNodeDetails(BuildContext context, PipeCuttingTreeNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(node.displayText),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('材料ID', node.materialId.toString()),
              _buildDetailRow('根节点ID', node.rootId.toString()),
              if (node.parentId != null)
                _buildDetailRow('父节点ID', node.parentId!),
              if (node.len != null && node.len!.isNotEmpty)
                _buildDetailRow('长度', node.len!),
              if (node.cutTime != null && node.cutTime!.isNotEmpty)
                _buildDetailRow('切割时间', node.cutTime!),
              if (node.cutUserName != null && node.cutUserName!.isNotEmpty)
                _buildDetailRow('操作人', node.cutUserName!),
              _buildDetailRow('操作人ID', node.cutUserId.toString()),
              if (node.cutUserPhone != null && node.cutUserPhone!.isNotEmpty)
                _buildDetailRow('联系电话', node.cutUserPhone!),
              if (node.currentId != null && node.currentId!.isNotEmpty)
                _buildDetailRow('当前ID', node.currentId!),
              _buildDetailRow('层级', node.level.toString()),
              _buildDetailRow('子节点数量', node.children.length.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}