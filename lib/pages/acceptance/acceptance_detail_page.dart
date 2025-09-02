import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_bloc.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_event.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_state.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/pdf_previewer/pdf_previewer.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';

class AcceptanceDetailPage extends StatefulWidget {
  final int acceptanceId;

  const AcceptanceDetailPage({super.key, required this.acceptanceId});

  @override
  State<AcceptanceDetailPage> createState() => _AcceptanceDetailPageState();
}

class _AcceptanceDetailPageState extends State<AcceptanceDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadAcceptanceDetail();
  }

  void _loadAcceptanceDetail() {
    context.read<AcceptanceBloc>().add(
      LoadAcceptanceDetail(acceptanceId: widget.acceptanceId),
    );
  }

  void _refreshAcceptanceDetail() {
    context.read<AcceptanceBloc>().add(
      RefreshAcceptanceDetail(acceptanceId: widget.acceptanceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text('验收详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAcceptanceDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AcceptanceBloc, AcceptanceState>(
      builder: (context, state) {
        if (state is AcceptanceLoading) {
          return common.LoadingWidget();
        }

        if (state is AcceptanceError) {
          return common.ErrorWidget(
            message: state.message,
            onRetry: _loadAcceptanceDetail,
          );
        }

        if (state is AcceptanceDetailLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _refreshAcceptanceDetail(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarehouseInfo(state.acceptanceInfo),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildMaterialsList(state.acceptanceInfo),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildAcceptancePhotos(state.acceptanceInfo),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildAttachmentsList(state.acceptanceInfo),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildSignInInfo(state.acceptanceInfo),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildWarehouseInfo(AcceptanceInfoVO acceptanceInfo) {
    return UnifiedCard(
      title: '仓库信息',
      icon: Icons.warehouse,
      businessType: 'acceptance',
      child: Column(
        children: [
          InfoRow(
            label: '仓库类型',
            value: acceptanceInfo.warehouseTypeDescription,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          InfoRow(label: '仓库ID', value: acceptanceInfo.warehouseId.toString()),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildUserListSection('仓库负责人', acceptanceInfo.warehouseUsers),
          _buildUserListSection('监理方负责人', acceptanceInfo.supervisorUsers),
          _buildUserListSection('建设方负责人', acceptanceInfo.constructionUsers),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(AcceptanceInfoVO acceptanceInfo) {
    return UnifiedCard(
      title: '物料清单 (${acceptanceInfo.materialList.length})',
      icon: Icons.inventory,
      businessType: 'acceptance',
      child: Column(
        children: acceptanceInfo.materialList.isEmpty
            ? [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        '暂无物料信息',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : acceptanceInfo.materialList
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            entry.key < acceptanceInfo.materialList.length - 1
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

  Widget _buildMaterialItem(MaterialVO material) {
    return MaterialListItem(
      materialName: material.materialName,
      materialId: material.materialId.toString(),
      quantity: material.num,
      businessType: 'acceptance',
      trailing: material.installPileNo != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.acceptanceColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '桩号: ${material.installPileNo}',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.acceptanceColor,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAttachmentsList(AcceptanceInfoVO acceptanceInfo) {
    final items = <Widget>[];

    if (acceptanceInfo.sendAcceptUrl != null &&
        acceptanceInfo.sendAcceptUrl!.trim().isNotEmpty) {
      items.add(
        _buildSimpleAttachmentRow(
          title: '报验单',
          fileUrl: acceptanceInfo.sendAcceptUrl!,
        ),
      );
    }

    if (acceptanceInfo.acceptReportUrl != null &&
        acceptanceInfo.acceptReportUrl!.trim().isNotEmpty) {
      items.add(
        _buildSimpleAttachmentRow(
          title: '验收报告',
          fileUrl: acceptanceInfo.acceptReportUrl!,
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '附件列表',
      icon: Icons.attach_file,
      businessType: 'acceptance',
      child: Column(
        children: items
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < items.length - 1
                      ? AppTheme.spacingMedium
                      : 0,
                ),
                child: entry.value,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAcceptancePhotos(AcceptanceInfoVO acceptanceInfo) {
    if (acceptanceInfo.imageList.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '验收照片 (${acceptanceInfo.imageList.length})',
      icon: Icons.photo_library,
      businessType: 'acceptance',
      child: Wrap(
        spacing: AppTheme.spacingSmall,
        runSpacing: AppTheme.spacingSmall,
        children: acceptanceInfo.imageList
            .map((attachment) => _buildImagePreview(attachment.url))
            .toList(),
      ),
    );
  }

  Widget _buildSimpleAttachmentRow({
    required String title,
    required String fileUrl,
  }) {
    final fileName = _extractFileName(fileUrl);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.acceptanceColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.acceptanceColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: AppTheme.acceptanceColor, size: 24),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(title, style: AppTheme.labelMedium),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: AppTheme.acceptanceColor),
            onPressed: () => _openPdf(fileUrl),
            tooltip: '预览',
          ),
        ],
      ),
    );
  }

  void _openPdf(String url) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PdfPreviewer(url: url)));
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final last = path.split('/').where((s) => s.isNotEmpty).last;
      return Uri.decodeComponent(last);
    } catch (_) {
      // Fallback: naive split when URL isn't strictly valid
      final cleaned = url.split('?').first.split('#').first;
      final parts = cleaned.split('/');
      return parts.isNotEmpty ? parts.last : cleaned;
    }
  }

  Widget _buildSignInInfo(AcceptanceInfoVO acceptanceInfo) {
    if (acceptanceInfo.signInInfo == null) {
      return const SizedBox.shrink();
    }

    final signInInfo = acceptanceInfo.signInInfo!;

    return UnifiedCard(
      title: '入库信息',
      icon: Icons.input,
      businessType: 'signin',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: '入库仓库ID', value: signInInfo.warehouseId.toString()),
          const SizedBox(height: AppTheme.spacingLarge),
          Text('入库物料', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.spacingSmall),
          ...signInInfo.materialList.asMap().entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key < signInInfo.materialList.length - 1
                    ? AppTheme.spacingSmall
                    : 0,
              ),
              child: _buildSimpleMaterialItem(entry.value),
            ),
          ),
          if (signInInfo.imageList.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            Text('入库照片', style: AppTheme.titleSmall),
            const SizedBox(height: AppTheme.spacingSmall),
            Wrap(
              spacing: AppTheme.spacingSmall,
              runSpacing: AppTheme.spacingSmall,
              children: signInInfo.imageList
                  .map((attachment) => _buildImagePreview(attachment.url))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleMaterialItem(MaterialVO material) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.acceptanceColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.acceptanceColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(material.materialName, style: AppTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.acceptanceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Text(
              '${material.num}个',
              style: AppTheme.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ImagePreviewWidget(imageUrls: [imagePath], initialIndex: 0),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: AppTheme.spacingSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: AppTheme.acceptanceColor.withValues(alpha: 0.3),
          ),
          image: DecorationImage(
            image: NetworkImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                AppTheme.acceptanceColor.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserListSection(String title, List<CommonUserVO> users) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (users.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                '暂无用户',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            ...users.map(
              (user) => Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            user.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.messageTo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '推送',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
