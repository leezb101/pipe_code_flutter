/*
 * @Author: LeeZB
 * @Date: 2025-08-06 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 20:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pipe_cutting_record/pipe_cutting_record_bloc.dart';
import '../../config/service_locator.dart';
import '../../widgets/pipe_cutting_tree_view.dart';

class PipeCuttingRecordPage extends StatelessWidget {
  const PipeCuttingRecordPage({super.key, required this.materialId});

  final String materialId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PipeCuttingRecordBloc>()
            ..add(LoadPipeCuttingRecord(materialId: materialId)),
      child: PipeCuttingRecordView(materialId: materialId),
    );
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
            onPressed: () => context.read<PipeCuttingRecordBloc>().add(
              RefreshPipeCuttingRecord(materialId: materialId),
            ),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: BlocBuilder<PipeCuttingRecordBloc, PipeCuttingRecordState>(
        builder: (context, state) {
          if (state is PipeCuttingRecordLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PipeCuttingRecordError) {
            return _buildErrorState(state.message, context);
          } else if (state is PipeCuttingRecordLoaded) {
            return PipeCuttingTreeView(
              cuttingRecord: state.cuttingRecord,
              currentMaterialId: materialId,
            );
          } else {
            return _buildInitialState(context);
          }
        },
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
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
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<PipeCuttingRecordBloc>().add(
              RefreshPipeCuttingRecord(materialId: materialId),
            ),
            child: const Text('重试'),
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
