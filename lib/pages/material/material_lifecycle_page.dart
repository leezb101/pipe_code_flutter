import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/material_detail/material_detail_bloc.dart';
import 'package:pipe_code_flutter/models/material/material_lifecycle_node.dart';

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
              return _buildLifecycleTimeline(state.lifecycleNodes!);
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
    // TODO: 在这里实现时间轴样式
    throw UnimplementedError('尚未实现时间轴样式');
  }
}
