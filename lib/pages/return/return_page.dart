/*
 * @Author: LeeZB
 * @Date: 2025-07-30 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../bloc/return/return_bloc.dart';
import '../../utils/go_router_popuntil.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key, required this.materials});

  final MaterialInfoForBusiness materials;

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  // 退库表单数据
  int _returnType = 0; // 默认质量不合格退库
  String _returnRemark = '';

  @override
  void initState() {
    super.initState();
    // 加载物料信息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnBloc>().add(
        LoadReturnMaterial(materialInfo: widget.materials),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReturnBloc, ReturnState>(
      listener: (context, state) {
        if (state.status == ReturnStatus.failure) {
          context.showErrorToast(state.errorMessage ?? '退库操作失败');
        } else if (state.status == ReturnStatus.returnSuccess) {
          context.showSuccessToast('退库申请提交成功，即将返回', isGlobal: true);
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              GoRouter.of(context).popUntil(
                predicate: (route) {
                  return route.name == '/';
                },
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('退库申请'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '退库记录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMaterialsList(),
                    const SizedBox(height: 16),
                    _buildReturnTypeSection(),
                    const SizedBox(height: 16),
                    _buildReturnRemarkSection(),
                    const SizedBox(height: 16),
                    _buildAttachmentSection(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  '退库物料',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.materials.normals.map(
              (material) => _buildMaterialItem(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(dynamic material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.water_drop, size: 20, color: Colors.orange[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.prodNm ?? '无',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material.materialCode ?? '无',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '1个',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '退库类型',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReturnTypeOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnTypeOptions() {
    return Column(
      children: [
        _buildReturnTypeOption(
          0,
          '质量不合格退库',
          '物料存在质量缺陷，不符合验收标准',
          Icons.gpp_bad,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildReturnTypeOption(
          1,
          '多余件退库',
          '物料数量超过实际需求',
          Icons.inventory_2,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildReturnTypeOption(
    int value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _returnType == value ? color : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: _returnType == value ? color.withValues(alpha: 0.1) : Colors.white,
      ),
      child: RadioListTile<int>(
        value: value,
        groupValue: _returnType,
        onChanged: (value) {
          setState(() {
            _returnType = value!;
            context.read<ReturnBloc>().add(
              UpdateReturnType(returnType: value),
            );
          });
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _returnType == value ? color : Colors.black87,
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        activeColor: color,
      ),
    );
  }

  Widget _buildReturnRemarkSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_alt, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '退库原因',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请详细说明退库原因...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green[600]!),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _returnRemark = value;
                  context.read<ReturnBloc>().add(
                    UpdateReturnRemark(returnRemark: value),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, size: 24, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '相关图片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ImageUploadWidget(
              title: '退库图片',
              onImagesChanged: (images) {
                // 转换为AttachmentVO列表
                final attachmentList = images.map((file) {
                  return AttachmentVO(
                    url: file.path,
                    name: file.path.split('/').last,
                    attachFormat: 'image',
                  );
                }).toList();
                context.read<ReturnBloc>().add(
                  UpdateImageList(imageList: attachmentList),
                );
              },
              maxImages: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmitReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '提交退库',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '返回',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleViewRecords() {
    // Navigate to records page with return tab selected
    context.go('/records?tab=return');
  }

  void _handleSubmitReturn() {
    // 验证表单
    if (_returnRemark.trim().isEmpty) {
      context.showErrorToast('请填写退库原因');
      return;
    }

    // 通过BLoC提交退库申请
    context.read<ReturnBloc>().add(const SubmitReturn());
  }

  void _handleReturn() {
    context.pop();
  }
}