import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/bloc/dispatch/dispatch_bloc.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/utils/tracing_context_x.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';

class DispatchDetailPage extends StatelessWidget {
  final int dispatchId;

  const DispatchDetailPage({super.key, required this.dispatchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DispatchBloc>(
      create: (context) => DispatchBloc(
        dispatchRepository: getIt<DispatchRepository>(),
        commonQueryApiService: getIt<CommonQueryApiService>(),
      ),
      child: _DispatchDetailPageView(dispatchId: dispatchId),
    );
  }
}

class _DispatchDetailPageView extends StatefulWidget {
  final int dispatchId;

  const _DispatchDetailPageView({required this.dispatchId});

  @override
  State<_DispatchDetailPageView> createState() =>
      _DispatchDetailPageViewState();
}

class _DispatchDetailPageViewState extends State<_DispatchDetailPageView> {
  @override
  void initState() {
    super.initState();
    _loadDispatchDetail();
  }

  void _loadDispatchDetail() {
    context.read<DispatchBloc>().add(
      LoadDispatchDetail(
        widget.dispatchId,
        context.createActionContext('获取详情'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调拨详情'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: AppTheme.grey50,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DispatchBloc, DispatchState>(
      builder: (context, state) {
        if (state.status == DispatchStatus.loading) {
          return common.LoadingWidget();
        }

        if (state.status == DispatchStatus.failure) {
          return common.ErrorWidget(
            message: state.errorMessage ?? '加载失败',
            onRetry: _loadDispatchDetail,
          );
        }

        if (state.dispatchDetail != null) {
          return RefreshIndicator(
            onRefresh: () async {
              _loadDispatchDetail();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(state.dispatchDetail!),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildMaterialsList(state.dispatchDetail!),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildProjectInfo(state.dispatchDetail!),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildWarehouseInfo(state.dispatchDetail!),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildResponsiblePersonsSection(state.dispatchDetail!),
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildImagesSection(state.dispatchDetail!),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: Text(
            '暂无数据',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      title: '调拨记录',
      icon: Icons.swap_horiz,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '状态：',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                  vertical: AppTheme.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Text(
                  '已完成',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildSummaryInfo(dispatchDetail),
        ],
      ),
    );
  }

  Widget _buildSummaryInfo(DispatchDetailVo dispatchDetail) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InfoRow(
            icon: Icons.launch,
            label: '项目流向',
            value:
                '${dispatchDetail.fromProjectName ?? '未知项目'} → ${dispatchDetail.toProjectName ?? '未知项目'}',
          ),
          SizedBox(height: AppTheme.spacingSmall),
          InfoRow(
            icon: Icons.warehouse,
            label: '仓库流向',
            value:
                '${dispatchDetail.fromWarehouseName ?? '未知仓库'} → ${dispatchDetail.toWarehouseName ?? '未知仓库'}',
          ),
          SizedBox(height: AppTheme.spacingSmall),
          InfoRow(
            icon: Icons.inventory,
            label: '物料数量',
            value: '共 ${dispatchDetail.materialList.length} 种物料',
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(DispatchDetailVo dispatchDetail) {
    if (dispatchDetail.materialList.isEmpty) {
      return UnifiedCard(
        title: '物料清单',
        icon: Icons.inventory,
        businessType: 'dispatch',
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              '暂无物料信息',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return UnifiedCard(
      title: '物料清单 (${dispatchDetail.materialList.length})',
      icon: Icons.inventory,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dispatchDetail.materialList
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < dispatchDetail.materialList.length - 1
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
      primaryText: material.materialCode,
      batchCode: material.batchCode,
      materialId: material.materialId.toString(),
      quantity: material.num,
      businessType: 'dispatch',
    );
  }

  Widget _buildProjectInfo(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      title: '项目信息',
      icon: Icons.business,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.launch,
            label: '发出项目',
            value: dispatchDetail.fromProjectName ?? '未知项目',
          ),
          SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            icon: Icons.download,
            label: '接收项目',
            value: dispatchDetail.toProjectName ?? '未知项目',
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      title: '仓库信息',
      icon: Icons.warehouse,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.outbox,
            label: '发出仓库',
            value: dispatchDetail.fromWarehouseName ?? '未知仓库',
          ),
          SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            icon: Icons.inbox,
            label: '接收仓库',
            value: dispatchDetail.toWarehouseName ?? '未知仓库',
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiblePersonsSection(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      title: '负责人信息',
      icon: Icons.people,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dispatchDetail.fromWarehouseUsers.isNotEmpty)
            _buildResponsiblePersonsList(
              '发出方负责人',
              dispatchDetail.fromWarehouseUsers,
              AppTheme.getBusinessColor('dispatch'),
            ),
          if (dispatchDetail.fromWarehouseUsers.isNotEmpty &&
              dispatchDetail.toWarehouseUsers.isNotEmpty)
            SizedBox(height: AppTheme.spacingLarge),
          if (dispatchDetail.toWarehouseUsers.isNotEmpty)
            _buildResponsiblePersonsList(
              '接收方负责人',
              dispatchDetail.toWarehouseUsers,
              AppTheme.getBusinessColor('dispatch'),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiblePersonsList(
    String title,
    List<CommonUserVO> users,
    Color color,
  ) {
    if (users.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            '暂无负责人信息',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        ...users.map(
          (user) => Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${user.name} - ${user.phone}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: user.realHandler == true
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (user.realHandler == true)
                  Icon(Icons.check_circle_outline, color: color, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(DispatchDetailVo dispatchDetail) {
    if (dispatchDetail.imageList.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '相关照片 (${dispatchDetail.imageList.length})',
      icon: Icons.photo_library,
      businessType: 'dispatch',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppTheme.spacingSmall,
          mainAxisSpacing: AppTheme.spacingSmall,
          childAspectRatio: 1,
        ),
        itemCount: dispatchDetail.imageList.length,
        itemBuilder: (context, index) {
          final image = dispatchDetail.imageList[index];
          return _buildImageThumbnail(image);
        },
      ),
    );
  }

  Widget _buildImageThumbnail(AttachmentVO image) {
    return GestureDetector(
      onTap: () => _previewPhoto(image),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            image.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[500],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '加载失败',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
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

  void _previewPhoto(AttachmentVO photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  photo.url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '图片加载失败',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        if (photo.name?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            photo.name!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            if (photo.name?.isNotEmpty == true)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    photo.name!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
