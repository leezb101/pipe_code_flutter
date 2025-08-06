/*
 * @Author: LeeZB
 * @Date: 2025-08-06 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 20:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/material_detail/material_detail_cubit.dart';
import '../../bloc/material_detail/material_detail_state.dart';
import '../../widgets/pipe_cutting_tree_view.dart';

class PipeCuttingRecordPage extends StatefulWidget {
  const PipeCuttingRecordPage({super.key, required this.materialId});

  final String materialId;

  @override
  State<PipeCuttingRecordPage> createState() => _PipeCuttingRecordPageState();
}

class _PipeCuttingRecordPageState extends State<PipeCuttingRecordPage> {
  @override
  void initState() {
    super.initState();
    context.read<MaterialDetailCubit>().loadCuttingRecord(widget.materialId);
  }

  @override
  Widget build(BuildContext context) {
    return PipeCuttingRecordView(materialId: widget.materialId);
  }
}

class PipeCuttingRecordView extends StatelessWidget {
  const PipeCuttingRecordView({super.key, required this.materialId});

  final String materialId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('截管记录'),
        actions: [
          IconButton(
            onPressed: () => context
                .read<MaterialDetailCubit>()
                .loadCuttingRecord(materialId),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: BlocBuilder<MaterialDetailCubit, MaterialDetailState>(
        builder: (context, state) {
          if (state is MaterialDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MaterialDetailError) {
            return _buildErrorState(state, context);
          } else if (state is MaterialDetailLoaded) {
            if (state.cuttingRecord == null) {
              return _buildNoDataState(context);
            }
            return PipeCuttingTreeView(
              cuttingRecord: state.cuttingRecord!,
              currentMaterialId: materialId,
            );
          } else {
            return _buildInitialState(context);
          }
        },
      ),
    );
  }

  Widget _buildErrorState(MaterialDetailError state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context
                .read<MaterialDetailCubit>()
                .loadCuttingRecord(materialId),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('暂无截管记录', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '材料ID $materialId 没有相关的截管记录',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context
                .read<MaterialDetailCubit>()
                .loadCuttingRecord(materialId),
            child: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pending, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('正在初始化...', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
