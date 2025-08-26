import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/widgets/timeline_view.dart';
import 'package:pipe_code_flutter/bloc/material_detail/material_detail_bloc.dart';
import 'package:pipe_code_flutter/models/material/material_lifecycle_node.dart';

// TODO: 这个页面没有增加滚动视图，会导致如果timeline的节点超过6个无法查看下方内容

class MaterialLifecyclePage extends StatefulWidget {
  final int materialId;
  const MaterialLifecyclePage({super.key, required this.materialId});

  @override
  State<StatefulWidget> createState() => _MaterialLifecyclePageState();
}

class _MaterialLifecyclePageState extends State<MaterialLifecyclePage> {
  @override
  void initState() {
    super.initState();
    // 页面初始化时，检查是否需要加载生命周期数据
    final state = context.read<MaterialDetailBloc>().state;
    // 只在 MaterialDetailLoaded 状态下且生命周期数据为空时才触发加载
    if (state is MaterialDetailLoaded && state.lifecycleNodes == null) {
      context.read<MaterialDetailBloc>().add(
        LoadMaterialLifeCycle(materialId: widget.materialId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('材料操作历史')),
      body: BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
        builder: (context, state) {
          // 主UI必须是MaterialDetailLoaded才会加载此内容
          if (state is MaterialDetailLoaded) {
            // 正在加载生命周期数据
            if (state.isLoadingLifecycle) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.lifecycleError != null) {
              return _buildErrorWidget(context, state.lifecycleError!);
            }
            if (state.lifecycleNodes != null) {
              if (state.lifecycleNodes!.isEmpty) {
                return const Center(child: Text('没有找到材料操作历史'));
              }
              return Column(
                children: [
                  Expanded(
                    child: _buildLifecycleTimeline(state.lifecycleNodes!),
                  ),
                ],
              );
            }
            return const Center(child: Text('未知状态，请返回重试'));
          }
          return const Center(child: Text('等待加载材料详情...'));
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MaterialDetailBloc>().add(
                  LoadMaterialLifeCycle(materialId: widget.materialId),
                );
              },
              label: const Text('重试'),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleTimeline(List<MaterialLifecycleNode> nodes) {
    // 按时间排序，最早的在前面
    final sortedNodes = [...nodes];
    sortedNodes.sort((a, b) {
      final timeA = a.businessTime ?? 0;
      final timeB = b.businessTime ?? 0;
      return timeA.compareTo(timeB); // 升序排列，最早的在前
    });

    return GenericTimelineView(
      data: sortedNodes,
      lineColor: Colors.grey.shade300,
      markerBuilder: (context, index, isFirst, isLast) {
        Color iconColor = Colors.white;
        IconData iconData;
        Color backgroundColor;

        if (isFirst) {
          backgroundColor = Theme.of(context).primaryColor;
          iconData = Icons.start;
        } else if (isLast) {
          backgroundColor = Colors.green.shade600;
          iconData = Icons.fiber_new;
        } else {
          backgroundColor = Colors.grey.shade500;
          iconData = Icons.radio_button_checked;
        }

        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 16),
        );
      },
      contentBuilder: (context, index, item) {
        Color cardBackgroundColor = Colors.white;
        Color accentColor = Theme.of(context).primaryColor;
        final businessName = item.businessName?.toLowerCase() ?? '';
        if (businessName.contains('安装')) {
          accentColor = const Color(0xFF4CAF50);
          cardBackgroundColor = const Color(0xFFF1F8E9);
        } else if (businessName.contains('出库')) {
          accentColor = const Color(0xFFFF9800);
          cardBackgroundColor = const Color(0xFFFFF3E0);
        } else if (businessName.contains('入库')) {
          accentColor = const Color(0xFF2196F3);
          cardBackgroundColor = const Color(0xFFE3F2FD);
        } else if (businessName.contains('验收')) {
          accentColor = const Color(0xFF9C27B0);
          cardBackgroundColor = const Color(0xFFF3E5F5);
        }

        return Card(
          elevation: 3,
          color: cardBackgroundColor,
          shadowColor: accentColor.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.businessName ?? '未知操作',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: accentColor.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        // Assuming you have a date formatting function
                        _formatDateTime(item.businessTime ?? 0),
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item.businessPeople != null || item.businessAddress != null)
                  const SizedBox(height: 12),
                if (item.businessPeople != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(item.businessPeople!)),
                    ],
                  ),
                if (item.businessAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(item.businessAddress!)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
