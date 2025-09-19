/*
 * @Author: LeeZB
 * @Date: 2025-08-27 10:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-27 10:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/bloc/install/install_bloc.dart';
import 'package:pipe_code_flutter/bloc/install/install_event.dart';
import 'package:pipe_code_flutter/bloc/install/install_state.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/pdf_previewer/pdf_previewer.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class InstallDetailPage extends StatefulWidget {
  final int installId;

  const InstallDetailPage({super.key, required this.installId});

  @override
  State<InstallDetailPage> createState() => _InstallDetailPageState();
}

class _InstallDetailPageState extends State<InstallDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadInstallDetail();
  }

  void _loadInstallDetail() {
    context.read<InstallBloc>().add(LoadInstallDetail(id: widget.installId));
  }

  void _refreshInstallDetail() {
    context.read<InstallBloc>().add(RefreshInstallDetail(id: widget.installId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('安装记录详情'),
        backgroundColor: AppTheme.getBusinessColor('install'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshInstallDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<InstallBloc, InstallState>(
      builder: (context, state) {
        if (state is InstallLoading) {
          return const common.LoadingWidget(message: "加载中...");
        }

        if (state is InstallFailure) {
          return common.ErrorWidget(
            message: state.error,
            onRetry: _loadInstallDetail,
          );
        }

        if (state is InstallReady && state.detail != null) {
          return RefreshIndicator(
            onRefresh: () async => _refreshInstallDetail(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstallInfo(state.detail!),
                  const SizedBox(height: 16),
                  _buildMaterialsList(state.detail!),
                  const SizedBox(height: 16),
                  _buildAttachmentsList(state.detail!),
                  if (state.detail!.installQualityUrl != null) ...[
                    const SizedBox(height: 16),
                    _buildQualityReport(state.detail!),
                  ],
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildInstallInfo(InstallDetailVo detail) {
    return UnifiedCard(
      title: '安装信息',
      icon: Icons.info,
      businessType: 'install',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            label: '安装类型',
            value: detail.onlyInstall == true ? '仅安装' : '出库直接安装',
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          InfoRow(label: '物料数量', value: '${detail.materialList.length}件'),
          const SizedBox(height: AppTheme.spacingSmall),
          InfoRow(label: '附件数量', value: '${detail.imageList.length}个'),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(InstallDetailVo detail) {
    return UnifiedCard(
      title: '安装物料清单',
      icon: Icons.list_alt,
      businessType: 'install',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.materialList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('暂无物料信息', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...detail.materialList.map(
              (material) => _buildMaterialItem(material),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
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
          // 物料基本信息
          Row(
            children: [
              Expanded(
                child: Text(
                  material.materialName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${material.num}个',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '物料ID: ${material.materialId}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),

          // 安装桩号信息
          if (material.installPileNo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  '安装桩号: ${material.installPileNo}',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // 安装照片
          if (material.installImageUrl1 != null ||
              material.installImageUrl2 != null) ...[
            const SizedBox(height: 12),
            const Text(
              '安装照片:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (material.installImageUrl1 != null)
                  _buildImagePreview(material.installImageUrl1!, '安装照片1'),
                if (material.installImageUrl1 != null &&
                    material.installImageUrl2 != null)
                  const SizedBox(width: 12),
                if (material.installImageUrl2 != null)
                  _buildImagePreview(material.installImageUrl2!, '安装照片2'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(InstallDetailVo detail) {
    return UnifiedCard(
      title: '相关附件',
      icon: Icons.attach_file,
      businessType: 'install',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.imageList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('暂无附件', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...detail.imageList.map(
              (attachment) => _buildAttachmentItem(attachment),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentVO attachment) {
    final isImage = _isImageUrl(attachment.url);
    final isPdf = _isPdfUrl(attachment.url);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isImage
              ? Colors.green.shade100
              : isPdf
              ? Colors.red.shade100
              : Colors.grey.shade100,
          child: Icon(
            isImage
                ? Icons.image
                : isPdf
                ? Icons.picture_as_pdf
                : Icons.attach_file,
            color: isImage
                ? Colors.green.shade700
                : isPdf
                ? Colors.red.shade700
                : Colors.grey.shade700,
            size: 20,
          ),
        ),
        title: Text(
          attachment.name ?? '附件',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          attachment.attachmentTypeDescription,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isImage)
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () => _previewImage(attachment.url),
                tooltip: '预览图片',
              ),
            if (isPdf)
              IconButton(
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed: () => _previewPdf(attachment),
                tooltip: '查看PDF',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityReport(InstallDetailVo detail) {
    return UnifiedCard(
      title: '质量验收报告',
      icon: Icons.description,
      businessType: 'install',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppTheme.getBusinessColorLight('install'),
          child: Icon(
            Icons.description,
            color: AppTheme.getBusinessColor('install'),
            size: 20,
          ),
        ),
        title: const Text(
          '质量验收报告',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: const Text(
          '质量验收相关文档',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, size: 20),
          onPressed: () => _openQualityReport(detail.installQualityUrl!),
          tooltip: '查看报告',
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl, String label) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    final urlWithTk = imageUrl.contains('?')
        ? '$imageUrl&auth_toke=$token'
        : '$imageUrl?auth_toke=$token';
    return Expanded(
      child: GestureDetector(
        onTap: () => _previewImage(urlWithTk),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // 图片
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                // 标签
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.webp');
  }

  bool _isPdfUrl(String url) {
    return url.toLowerCase().split('?').first.endsWith('.pdf');
  }

  void _previewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('图片加载失败'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewPdf(AttachmentVO attachment) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    final urlWithTk = attachment.url.contains('?')
        ? '${attachment.url}&auth_toke=$token'
        : '${attachment.url}?auth_toke=$token';
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PdfPreviewer(url: urlWithTk)),
    );
  }

  void _openQualityReport(String url) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    final urlWithTk = url.contains('?')
        ? '$url&auth_toke=$token'
        : '$url?auth_toke=$token';
    if (_isPdfUrl(url)) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PdfPreviewer(url: urlWithTk)),
      );
    } else {
      _previewImage(urlWithTk);
    }
  }
}
