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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '材料编码: ${widget.cuttingRecord.materialCode}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.cuttingRecord.name.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '材料名称: ${widget.cuttingRecord.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            if (widget.cuttingRecord.spec != null) ...[
              const SizedBox(height: 4),
              Text(
                '规格: ${widget.cuttingRecord.spec}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreeNode(
    BuildContext context,
    TreeEntry<PipeCuttingTreeNode> entry,
  ) {
    return TreeIndentation(
      entry: entry,
      guide: IndentGuide.connectingLines(
        color: Theme.of(context).colorScheme.outline,
        thickness: 1.5,
        origin: 0.5,
        roundCorners: true,
      ),
      child: _buildNodeContent(context, entry),
    );
  }

  Widget _buildNodeContent(
    BuildContext context,
    TreeEntry<PipeCuttingTreeNode> entry,
  ) {
    final node = entry.node;
    final hasChildren = node.children.isNotEmpty;

    return InkWell(
      onTap: () => _showNodeDetails(context, node),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getNodeColor(node),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getNodeBorderColor(node),
            width: node.isCurrent ? 2 : 1,
          ),
          boxShadow: node.isCurrent
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: .3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: hasChildren
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => treeController.toggleExpansion(node),
                        borderRadius: BorderRadius.circular(22),
                        child: Icon(
                          entry.isExpanded
                              ? Icons.expand_more
                              : Icons.chevron_right,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNodeTitle(context, node),
                  if (node.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      node.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeTitle(BuildContext context, PipeCuttingTreeNode node) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            node.displayText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: node.isCurrent ? FontWeight.bold : FontWeight.normal,
              color: node.isCurrent ? Theme.of(context).primaryColor : null,
            ),
          ),
        ),
        if (node.isCurrent) ...[
          const SizedBox(width: 8),
          Icon(Icons.star, size: 16, color: Theme.of(context).primaryColor),
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
    );
  }

  Color _getNodeColor(PipeCuttingTreeNode node) {
    final colorScheme = Theme.of(context).colorScheme;
    if (node.isCurrent) {
      return colorScheme.primary.withOpacity(0.1);
    }
    if (node.isRoot) {
      return colorScheme.secondary.withOpacity(0.1);
    }
    return colorScheme.surface.withOpacity(0.5);
  }

  Color _getNodeBorderColor(PipeCuttingTreeNode node) {
    final colorScheme = Theme.of(context).colorScheme;
    if (node.isCurrent) {
      return colorScheme.primary;
    }
    if (node.isRoot) {
      return colorScheme.secondary;
    }
    return colorScheme.outline;
  }

  void _showNodeDetails(BuildContext context, PipeCuttingTreeNode node) {
    final details = [
      ('显示文本', node.displayText),
      ('材料ID', node.materialId.toString()),
      ('根节点ID', node.rootId.toString()),
      if (node.parentId != null) ('父节点ID', node.parentId!),
      if (node.len != null && node.len!.isNotEmpty) ('长度', node.len!),
      if (node.cutTime != null && node.cutTime!.isNotEmpty)
        ('切割时间', node.cutTime!),
      if (node.cutUserName != null && node.cutUserName!.isNotEmpty)
        ('操作人', node.cutUserName!),
      ('操作人ID', node.cutUserId.toString()),
      if (node.cutUserPhone != null && node.cutUserPhone!.isNotEmpty)
        ('联系电话', node.cutUserPhone!),
      if (node.currentId != null && node.currentId!.isNotEmpty)
        ('当前ID', node.currentId!),
      ('层级', node.level.toString()),
      ('子节点数量', node.children.length.toString()),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Padding(
          padding: const EdgeInsets.only(left: 24, top: 24, right: 24),
          child: Text('节点详情', style: Theme.of(context).textTheme.titleLarge),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (node.img != null && node.img!.isNotEmpty)
                _buildImagePreview(context, node.img!),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    return _buildDetailRow(detail.$1, detail.$2);
                  },
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 24, endIndent: 24),
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, imageUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text('图片加载失败'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
