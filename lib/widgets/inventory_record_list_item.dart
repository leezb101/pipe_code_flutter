import 'package:flutter/material.dart';
import '../models/records/record_item.dart';

/// 专用于盘点任务的列表项组件
class InventoryRecordListItem extends StatelessWidget {
  final InventoryRecordItem record;
  final VoidCallback? onTap;

  const InventoryRecordListItem({super.key, required this.record, this.onTap});

  String _formatDoTime(DateTime? dt) {
    if (dt == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildMaterialInfo(context),
            const SizedBox(height: 8),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            record.businessTypeDescription,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade300, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.purple.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                '盘点任务',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category_outlined,
            size: 18,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            '耗材数量：',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${record.materialNum}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text('种', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '创建时间：${_formatDoTime(record.doTime)}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        if (record.userName.isNotEmpty && record.userName != '未分配') ...[
          Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            record.userName,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '未分配',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
