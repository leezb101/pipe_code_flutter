import 'package:flutter/material.dart';
import '../models/records/record_item.dart';

class RecordListItem extends StatelessWidget {
  final RecordItem record;
  final VoidCallback? onTap;

  const RecordListItem({super.key, required this.record, this.onTap});

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
                  _buildBusinessType(context),
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
    String mainTitle;
    if (record is TodoRecordItem) {
      final todoRecord = record as TodoRecordItem;
      mainTitle = '任务名称：${todoRecord.todo.name}';
    } else {
      mainTitle = '工程名称：${record.projectName}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (record is! TodoRecordItem) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '工程编号：${record.projectCode}',
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
          '发起时间：${record.doTime}',
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
