/*
 * @Author: LeeZB
 * @Date: 2025-08-28 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-28 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/cubits/signin_detail_cubit.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';

class SigninDetailPage extends StatefulWidget {
  final int signinId;

  const SigninDetailPage({super.key, required this.signinId});

  @override
  State<SigninDetailPage> createState() => _SigninDetailPageState();
}

class _SigninDetailPageState extends State<SigninDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadSigninDetail();
  }

  void _loadSigninDetail() {
    context.read<SigninDetailCubit>().loadSigninDetail(widget.signinId);
  }

  void _refreshSigninDetail() {
    context.read<SigninDetailCubit>().refreshSigninDetail(widget.signinId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('入库详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSigninDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SigninDetailCubit, SigninDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const common.LoadingWidget();
        }

        if (state.error != null) {
          return common.ErrorWidget(
            message: state.error!,
            onRetry: _loadSigninDetail,
          );
        }

        if (state.signinInfo == null) {
          return const common.EmptyWidget(
            message: '暂无入库详情数据',
            icon: Icons.inbox_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refreshSigninDetail(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectInfo(state.signinInfo!),
                const SizedBox(height: 16),
                _buildWarehouseInfo(state.signinInfo!),
                const SizedBox(height: 16),
                _buildSigninOperatorInfo(state.signinInfo!),
                const SizedBox(height: 16),
                _buildMaterialsList(state.signinInfo!),
                const SizedBox(height: 16),
                _buildSigninPhotos(state.signinInfo!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectInfo(SignInInfoVO signinInfo) {
    // 如果项目信息不完整则不显示这个section
    if (signinInfo.projectId == null && signinInfo.projectName == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '项目信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (signinInfo.projectName != null)
              _buildInfoRow('项目名称', signinInfo.projectName!),
            if (signinInfo.projectId != null)
              _buildInfoRow('项目ID', signinInfo.projectId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseInfo(SignInInfoVO signinInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warehouse, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '仓库信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (signinInfo.warehouseName != null)
              _buildInfoRow('仓库名称', signinInfo.warehouseName!),
            _buildInfoRow('仓库ID', signinInfo.warehouseId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSigninOperatorInfo(SignInInfoVO signinInfo) {
    // 如果没有操作人信息则不显示这个section
    if (signinInfo.signInUserName == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '操作人信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('入库操作人', signinInfo.signInUserName!),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList(SignInInfoVO signinInfo) {
    if (signinInfo.materialList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '物料清单',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Text(
                    '暂无物料数据',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '物料清单',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '共${signinInfo.materialList.length}项',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...signinInfo.materialList.asMap().entries.map(
              (entry) => _buildMaterialItem(entry.value, entry.key + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  material.materialName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${material.num}个',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
          if (material.installPileNo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '安装桩号: ${material.installPileNo}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
          // 物料相关的图片预览（如果有的话）
          if (material.installImageUrl1 != null ||
              material.installImageUrl2 != null) ...[
            const SizedBox(height: 8),
            const Text(
              '安装图片:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (material.installImageUrl1 != null)
                  _buildImagePreview(material.installImageUrl1!, 0, [
                    material.installImageUrl1!,
                    if (material.installImageUrl2 != null)
                      material.installImageUrl2!,
                  ]),
                if (material.installImageUrl2 != null) ...[
                  const SizedBox(width: 8),
                  _buildImagePreview(
                    material.installImageUrl2!,
                    material.installImageUrl1 != null ? 1 : 0,
                    [
                      if (material.installImageUrl1 != null)
                        material.installImageUrl1!,
                      material.installImageUrl2!,
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSigninPhotos(SignInInfoVO signinInfo) {
    if (signinInfo.imageList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '入库照片',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '共${signinInfo.imageList.length}张',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: signinInfo.imageList.asMap().entries.map((entry) {
                final index = entry.key;
                final attachment = entry.value;
                final imageUrls = signinInfo.imageList
                    .map((e) => e.url)
                    .toList();
                return _buildImagePreview(attachment.url, index, imageUrls);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(
    String imageUrl,
    int index,
    List<String> allImageUrls,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewWidget(
              imageUrls: allImageUrls,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 32,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
