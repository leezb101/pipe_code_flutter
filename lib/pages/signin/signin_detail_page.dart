/*
 * @Author: LeeZB
 * @Date: 2025-08-28 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-28 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/cubits/signin_detail_cubit.dart';
import 'package:pipe_code_flutter/services/documents/document_route_resolver.dart';
import 'package:pipe_code_flutter/services/documents/document_service.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/document_button.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:share_plus/share_plus.dart';

class SigninDetailPage extends StatefulWidget {
  final int signinId;

  const SigninDetailPage({super.key, required this.signinId});

  @override
  State<SigninDetailPage> createState() => _SigninDetailPageState();
}

class _SigninDetailPageState extends State<SigninDetailPage> {
  late final DocumentService _documentService;
  late final DocumentRouteResolver _routeResolver;

  @override
  void initState() {
    super.initState();
    _documentService = getIt<DocumentService>();
    _routeResolver = getIt<DocumentRouteResolver>();
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
        backgroundColor: AppTheme.getBusinessColor('signin'),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshSigninDetail,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
        child: SizedBox(
          width: double.infinity,
          child: DocumentButton(
            businessType: 'signin-report',
            entityId: widget.signinId,
            displayName: '入库文件',
            documentService: _documentService,
            routeResolver: _routeResolver,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
              backgroundColor: AppTheme.signinColor,
              foregroundColor: Colors.white,
            ),
            onDownloadCompleted: (filePath) {
              SharePlus.instance.share(
                ShareParams(
                  files: [XFile(filePath)],
                  text: '入库报告',
                  subject: '入库明细文件',
                ),
              );
            },
          ),
        ),
      ),
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
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectInfo(state.signinInfo!),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildWarehouseInfo(state.signinInfo!),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildSigninOperatorInfo(state.signinInfo!),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildMaterialsList(state.signinInfo!),
                const SizedBox(height: AppTheme.spacingLarge),
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

    return UnifiedCard(
      title: '项目信息',
      icon: Icons.work,
      businessType: 'signin',
      child: Column(
        children: [
          if (signinInfo.projectName != null)
            InfoRow(label: '项目名称', value: signinInfo.projectName!),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo(SignInInfoVO signinInfo) {
    return UnifiedCard(
      title: '仓库信息',
      icon: Icons.warehouse,
      businessType: 'signin',
      child: Column(
        children: [
          if (signinInfo.warehouseName != null)
            InfoRow(label: '仓库名称', value: signinInfo.warehouseName!),
        ],
      ),
    );
  }

  Widget _buildSigninOperatorInfo(SignInInfoVO signinInfo) {
    // 如果没有操作人信息则不显示这个section
    if (signinInfo.signInUserName == null) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '操作人信息',
      icon: Icons.person,
      businessType: 'signin',
      child: InfoRow(label: '入库操作人', value: signinInfo.signInUserName!),
    );
  }

  Widget _buildMaterialsList(SignInInfoVO signinInfo) {
    if (signinInfo.materialList.isEmpty) {
      return UnifiedCard(
        title: '物料清单',
        icon: Icons.inventory,
        businessType: 'signin',
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Center(
            child: Text(
              '暂无物料数据',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return UnifiedCard(
      title: '物料清单 (共${signinInfo.materialList.length}项)',
      icon: Icons.inventory,
      businessType: 'signin',
      child: Column(
        children: signinInfo.materialList
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < signinInfo.materialList.length - 1
                      ? AppTheme.spacingMedium
                      : 0,
                ),
                child: _buildMaterialItem(entry.value, entry.key + 1),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material, int index) {
    return MaterialListItem(
      materialName: material.materialName,
      primaryText: material.materialCode ?? '无',
      batchCode: material.batchCode ?? '无',
      materialId: material.materialId.toString(),
      quantity: material.num,
      status: material.status,
      statusName: material.statusName,
      businessType: 'signin',
      icon: Icons.inventory_2,
      trailing: _buildMaterialTrailing(material, index),
    );
  }

  /// 构建材料项的尾部内容（序号 + 安装图片）
  Widget _buildMaterialTrailing(MaterialVO material, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 序号徽章
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.getBusinessColor('signin'),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
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
        // 安装桩号（如果有）
        if (material.installPileNo != null) ...[
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.green.shade600),
              const SizedBox(width: 2),
              Text(
                material.installPileNo!,
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        // 安装图片（如果有）
        if (material.installImageUrl1 != null ||
            material.installImageUrl2 != null) ...[
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (material.installImageUrl1 != null)
                _buildSmallImagePreview(material.installImageUrl1!, 0, [
                  material.installImageUrl1!,
                  if (material.installImageUrl2 != null)
                    material.installImageUrl2!,
                ]),
              if (material.installImageUrl1 != null &&
                  material.installImageUrl2 != null)
                const SizedBox(width: 4),
              if (material.installImageUrl2 != null)
                _buildSmallImagePreview(
                  material.installImageUrl2!,
                  material.installImageUrl1 != null ? 1 : 0,
                  [
                    if (material.installImageUrl1 != null)
                      material.installImageUrl1!,
                    material.installImageUrl2!,
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// 构建小尺寸的图片预览
  Widget _buildSmallImagePreview(
    String imageUrl,
    int index,
    List<String> allImageUrls,
  ) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    final urlWithTk = imageUrl.contains('?')
        ? '$imageUrl&auth_toke=$token'
        : '$imageUrl?auth_toke=$token';

    final processedUrls = allImageUrls.map((url) {
      return url.contains('?')
          ? '$url&auth_toke=$token'
          : '$url?auth_toke=$token';
    }).toList();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewWidget(
              imageUrls: processedUrls,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Image.network(
            urlWithTk,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 16,
              ),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSigninPhotos(SignInInfoVO signinInfo) {
    if (signinInfo.imageList.isEmpty) {
      return const SizedBox.shrink();
    }

    return UnifiedCard(
      title: '入库照片 (共${signinInfo.imageList.length}张)',
      icon: Icons.photo_library,
      businessType: 'signin',
      child: Wrap(
        spacing: AppTheme.spacingSmall,
        runSpacing: AppTheme.spacingSmall,
        children: signinInfo.imageList.asMap().entries.map((entry) {
          final index = entry.key;
          final attachment = entry.value;
          final imageUrls = signinInfo.imageList.map((e) => e.url).toList();
          return _buildImagePreview(attachment.url, index, imageUrls);
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreview(
    String imageUrl,
    int index,
    List<String> allImageUrls,
  ) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    final urlWithTk = imageUrl.contains('?')
        ? '$imageUrl&auth_toke=$token'
        : '$imageUrl?auth_toke=$token';

    allImageUrls = allImageUrls.map((url) {
      return url.contains('?')
          ? '$url&auth_toke=$token'
          : '$url?auth_toke=$token';
    }).toList();
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
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Image.network(
            urlWithTk,
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
}
