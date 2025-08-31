/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import '../../bloc/return/return_bloc.dart';
import '../../widgets/common/attachment_display_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class ReturnDetailPage extends StatefulWidget {
  const ReturnDetailPage({super.key, required this.id});

  final int id;

  @override
  State<ReturnDetailPage> createState() => _ReturnDetailPageState();
}

class _ReturnDetailPageState extends State<ReturnDetailPage> {
  @override
  void initState() {
    super.initState();
    // 加载退库详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnBloc>().add(LoadReturnDetail(id: widget.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReturnBloc, ReturnState>(
      listener: (context, state) {
        if (state.status == ReturnStatus.failure) {
          context.showErrorToast(state.errorMessage ?? '加载退库详情失败');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('退库详情'),
          backgroundColor: AppTheme.getBusinessColor('return'),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: AppTheme.grey50,
        body: BlocBuilder<ReturnBloc, ReturnState>(
          builder: (context, state) {
            if (state.status == ReturnStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ReturnStatus.failure ||
                state.returnDetail == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载退库详情失败',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReturnBloc>().add(
                          LoadReturnDetail(id: widget.id),
                        );
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            final returnDetail = state.returnDetail!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                children: [
                  _buildMaterialsList(returnDetail.materialList ?? []),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildReturnTypeSection(returnDetail.returnType),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildReturnRemarkSection(returnDetail.returnRemark),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildAttachmentSection(returnDetail.imageList ?? []),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterialsList(List<dynamic> materials) {
    return UnifiedCard(
      title: '退库物料',
      icon: Icons.inventory,
      businessType: 'return',
      child: materials.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Text(
                  '暂无物料信息',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            )
          : Column(
              children: materials
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key < materials.length - 1
                            ? AppTheme.spacingMedium
                            : 0,
                      ),
                      child: _buildMaterialItem(entry.value),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildMaterialItem(dynamic material) {
    return MaterialListItem(
      materialName: material.materialName ?? '无',
      materialId: (material.materialId ?? '无').toString(),
      quantity: material.num ?? 1,
      businessType: 'return',
    );
  }

  Widget _buildReturnTypeSection(int returnType) {
    return UnifiedCard(
      title: '退库类型',
      icon: Icons.category,
      businessType: 'return',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: returnType == 0 ? Colors.red[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: returnType == 0 ? Colors.red[200]! : Colors.blue[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              returnType == 0 ? Icons.gpp_bad : Icons.inventory_2,
              color: returnType == 0 ? Colors.red : Colors.blue,
              size: 24,
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    returnType == 0 ? '质量不合格退库' : '多余件退库',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: returnType == 0 ? Colors.red : Colors.blue,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    returnType == 0 ? '物料存在质量缺陷，不符合验收标准' : '物料数量超过实际需求',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnRemarkSection(String returnRemark) {
    return UnifiedCard(
      title: '退库原因',
      icon: Icons.note_alt,
      businessType: 'return',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        decoration: BoxDecoration(
          color: AppTheme.getBusinessColor('return').withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.getBusinessColor('return').withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          returnRemark.isEmpty ? '无退库原因说明' : returnRemark,
          style: TextStyle(
            fontSize: 14,
            color: returnRemark.isEmpty ? Colors.grey[500] : Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(List<AttachmentVO> attachments) {
    return UnifiedCard(
      title: '相关图片 (${attachments.length})',
      icon: Icons.attach_file,
      businessType: 'return',
      child: attachments.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Text(
                  '暂无相关图片',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ),
            )
          : AttachmentDisplayWidget(attachments: attachments),
    );
  }
}
