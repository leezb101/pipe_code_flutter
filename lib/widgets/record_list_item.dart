import 'package:flutter/material.dart';
import '../models/records/record_item.dart';

class RecordListItem extends StatelessWidget {
  final RecordItem record;
  final VoidCallback? onTap;

  const RecordListItem({super.key, required this.record, this.onTap});

  String _formatDoTime(DateTime? dt) {
    if (dt == null) return '-';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    // Example: 2025-08-31 09:05 (trim seconds/millis to avoid overflow)
  }

  @override
  Widget build(BuildContext context) {
    final showStatusName =
        record is BusinessRecordItem &&
        (record as BusinessRecordItem).statusName != null &&
        (record as BusinessRecordItem).statusName!.isNotEmpty;

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
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: record is TodoRecordItem ? 14 : 0,
                right: record is TodoRecordItem ? 80 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBusinessType(context),
                      if (showStatusName) ...[
                        const Spacer(),
                        _buildStatusName(
                          context,
                          (record as BusinessRecordItem).statusName!,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTime(context),
                ],
              ),
            ),
            if (record is TodoRecordItem)
              _buildTodoNameTag(context, record as TodoRecordItem),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (record is TodoRecordItem) {
      final todoRecord = record as TodoRecordItem;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '任务名称：${todoRecord.todo.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // 业务记录项
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 所在项目
        _buildProjectInfo('所在项目', record.projectName, record.projectCode),

        // 目的项目（仅dispatch类型显示）
        if (record is BusinessRecordItem &&
            (record as BusinessRecordItem).toProjectName != null &&
            (record as BusinessRecordItem).toProjectName!.isNotEmpty) ...[
          const SizedBox(height: 6),
          _buildProjectInfo(
            '目的项目',
            (record as BusinessRecordItem).toProjectName,
            null,
          ),
        ],
      ],
    );
  }

  Widget _buildProjectInfo(
    String label,
    String? projectName,
    String? projectCode,
  ) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label：',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text: projectName ?? '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (projectCode != null && projectCode.isNotEmpty)
            TextSpan(
              text: '  ($projectCode)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessType(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        record.businessTypeDescription,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTime(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          '发起时间：${_formatDoTime(record.doTime)}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        if (record.userName.isNotEmpty) ...[
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
        ],
      ],
    );
  }

  Widget _buildStatusName(BuildContext context, String statusName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300, width: 1),
      ),
      child: Text(
        statusName,
        style: TextStyle(
          fontSize: 13,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTodoNameTag(BuildContext context, TodoRecordItem todoRecord) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          todoRecord.todo.todoName,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
