/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 18:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_bloc.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_event.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_state.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class ScrapPage extends StatefulWidget {
  final MaterialInfoForBusiness? materials;
  final List<String>? codes;

  const ScrapPage({super.key, this.materials, this.codes});

  @override
  State<ScrapPage> createState() => _ScrapPageState();
}

class _ScrapPageState extends State<ScrapPage> {
  late final FileUploadCubit _imageUploadCubit;

  @override
  void initState() {
    super.initState();
    _imageUploadCubit = FileUploadCubit();
    _initializeScrap();
  }

  @override
  void dispose() {
    _imageUploadCubit.close();
    super.dispose();
  }

  void _initializeScrap() {
    if (widget.materials != null) {
      // 从MaterialInfoForBusiness初始化
      context.read<ScrapBloc>().add(
        InitializeScrapSubmission(materialInfoForBusiness: widget.materials!),
      );
    } else if (widget.codes != null) {
      // 从扫码结果初始化
      context.read<ScrapBloc>().add(
        InitializeScrapFromCodes(codes: widget.codes!),
      );
    }
  }

  void _submitScrap() {
    // 检查是否有错误材料
    final state = context.read<ScrapBloc>().state;
    if (state is ScrapSubmissionReady && state.errorMaterials.isNotEmpty) {
      // 显示确认对话框
      _showSubmitConfirmation(
        state.materialList.length,
        state.errorMaterials.length,
      ).then((confirmed) {
        if (confirmed) {
          _performSubmit();
        }
      });
      return;
    }

    // 没有错误材料，直接提交
    _performSubmit();
  }

  Future<bool> _showSubmitConfirmation(int normalCount, int errorCount) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => SubmitConfirmationDialog(
            normalCount: normalCount,
            errorCount: errorCount,
            title: '报废提交确认',
            businessType: 'scrap',
            onConfirm: () {}, // 对话框内部会处理
            onCancel: () {}, // 对话框内部会处理
          ),
        ) ??
        false;
  }

  void _performSubmit() {
    final uploadStates = _imageUploadCubit.state;
    final isUploading = uploadStates.any(
      (s) => s.status == UploadStatus.uploading,
    );
    if (isUploading) {
      context.showInfoToast('照片仍在上传中，请稍候...');
      return;
    }

    final hasFailures = uploadStates.any(
      (s) => s.status == UploadStatus.failure,
    );
    if (hasFailures) {
      context.showErrorToast('有图片上传失败，请重试或删除。');
      return;
    }

    final photoUrls = uploadStates
        .where(
          (s) => s.status == UploadStatus.success && s.uploadResult != null,
        )
        .map((state) => state.uploadResult!.filePath)
        .toList();

    // 更新bloc中的照片列表
    context.read<ScrapBloc>().add(UpdateScrapPhotos(photoPaths: photoUrls));
    // 触发提交
    context.read<ScrapBloc>().add(const SubmitScrap());
  }

  // 扫码添加材料
  Future<void> _scanToAddMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      // currentCodes: _scannedCodes.toList(),
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'scrapPage',
        'entry': 'embedded',
        'operation': 'append',
      },
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final result = flow.normalize(request, raw);
    if (!mounted) return;
    if (result.addedCodes.isNotEmpty) {
      context.read<ScrapBloc>().add(
        AppendMaterialsFromCodes(codes: result.addedCodes),
      );
    }
  }

  // 扫码删除材料
  Future<void> _scanToRemoveMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      // currentCodes: _scannedCodes.toList(),
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'scrapPage',
        'entry': 'embedded',
        'operation': 'remove',
      },
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final result = flow.normalize(request, raw);
    if (!mounted) return;
    if (result.removedCodes.isNotEmpty) {
      context.read<ScrapBloc>().add(
        RemoveMaterialsFromCodes(codes: result.removedCodes),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一管一码'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        // actions: [
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //     decoration: BoxDecoration(
        //       color: Colors.grey[200],
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //     child: const Text('报废记录', style: TextStyle(fontSize: 12)),
        //   ),
        //   const SizedBox(width: 16),
        // ],
      ),
      backgroundColor: Colors.grey[50],
      body: BlocListener<ScrapBloc, ScrapState>(
        listener: (context, state) async {
          if (state is ScrapSubmissionReady && state.errorMessage != null) {
            ToastUtils.showError(context, state.errorMessage!);
            // 清空错误信息
            context.read<ScrapBloc>().add(ClearScrapErrorMessage());
          } else if (state is ScrapSubmitted) {
            ToastUtils.showSuccess(context, state.message);
            // 返回到上一页面
            context.pop();
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ScrapBloc, ScrapState>(
      builder: (context, state) {
        if (state is ScrapLoading) {
          return common.LoadingWidget();
        } else if (state is ScrapSubmissionReady) {
          return _buildSubmissionForm(state);
        } else if (state is ScrapFatalError) {
          return common.ErrorWidget(
            message: state.message,
            onRetry: _initializeScrap,
          );
        }
        return common.EmptyWidget(message: '正在初始化...');
      },
    );
  }

  Widget _buildSubmissionForm(ScrapSubmissionReady state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 物料列表
                _buildMaterialList(state.materialList),
                const SizedBox(height: 24),

                // 照片部分
                BlocBuilder<FileUploadCubit, List<FileUploadState>>(
                  bloc: _imageUploadCubit,
                  builder: (context, states) {
                    return ImageUploadWidget(
                      title: '照片',
                      maxImages: 6,
                      watermarkText: '报废',
                      includeTimeWatermark: true,
                      includeLocationWatermark: true,
                      states: states,
                      onAdd: (files) {
                        _imageUploadCubit.addFiles(files);
                      },
                      onRemove: (uniqueId) {
                        _imageUploadCubit.removeFile(uniqueId);
                      },
                      onRetry: (uniqueId) {
                        _imageUploadCubit.retryUpload(uniqueId);
                      },
                    );
                  },
                ),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
        ),

        // 底部按钮
        _buildBottomButtons(state),
      ],
    );
  }

  Widget _buildMaterialList(List<MaterialVO> materialList) {
    return UnifiedCard(
      title: '材料清单',
      icon: Icons.inventory,
      businessType: 'scrap',
      child: BlocBuilder<ScrapBloc, ScrapState>(
        builder: (context, state) {
          final materials = state is ScrapSubmissionReady
              ? state.materialList
              : materialList;

          final errorMaterials = state is ScrapSubmissionReady
              ? state.errorMaterials
              : <dynamic>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 正常材料列表
              if (materials.isNotEmpty)
                ...materials.map(_buildMaterialItem)
              else
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          '暂无正常材料',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          '请通过扫码添加材料',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 错误材料展示区域
              if (errorMaterials.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                ErrorMaterialSection(
                  errors: errorMaterials,
                  title: '报废异常材料',
                  onErrorItemTap: _handleErrorMaterialTap,
                  collapsible: true,
                  initialExpanded: true,
                ),
              ],

              const SizedBox(height: AppTheme.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: UnifiedButton(
                      text: '扫码报废',
                      type: UnifiedButtonType.outlined,
                      businessType: 'scrap',
                      onPressed: _scanToAddMaterials,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: UnifiedButton(
                      text: '扫码删除',
                      type: UnifiedButtonType.outlined,
                      businessType: 'scrap',
                      foregroundColor: Colors.red,
                      borderColor: Colors.red,
                      onPressed: _scanToRemoveMaterials,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: MaterialListItem(
        onTap: () => _showMaterialDetail(context, material),
        materialName: material.materialName,
        primaryText: material.materialCode ?? '无',
        batchCode: material.batchCode ?? '无',
        materialId: material.materialCode ?? '无',
        quantity: material.num,
        status: material.status,
        statusName: material.statusName,
        businessType: 'scrap',
        icon: Icons.water_drop,
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, MaterialVO material) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          material.materialName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 内容区域
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow(
                          label: '材料名称',
                          value: material.materialName,
                          icon: Icons.label,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        InfoRow(
                          label: '材料编码',
                          value: material.materialCode ?? '无',
                          icon: Icons.qr_code,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        InfoRow(
                          label: '批次编号',
                          value: material.batchCode ?? '无',
                          icon: Icons.batch_prediction,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        InfoRow(
                          label: '数量',
                          value: '${material.num}个',
                          icon: Icons.numbers,
                        ),
                        if (material.installPileNo != null) ...[
                          const SizedBox(height: AppTheme.spacingSmall),
                          InfoRow(
                            label: '安装桩号',
                            value: material.installPileNo!,
                            icon: Icons.location_on,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(ScrapSubmissionReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 提交按钮
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : _submitScrap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('提交', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),

          // 返回按钮
          Expanded(
            child: OutlinedButton(
              onPressed: state.isSubmitting ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '返回',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleErrorMaterialTap(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('异常材料详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
              label: '二维码',
              value: _getErrorField(error, 'qrCode') ?? '无',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家编码',
              value: _getErrorField(error, 'code') ?? '无',
              icon: Icons.business,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家名称',
              value: _getErrorField(error, 'name') ?? '无',
              icon: Icons.factory,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '错误信息',
              value: _getErrorField(error, 'msg') ?? '无',
              icon: Icons.error_outline,
              valueStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleReportError(error);
            },
            child: const Text('报告问题'),
          ),
        ],
      ),
    );
  }

  String? _getErrorField(dynamic error, String field) {
    if (error is Map<String, dynamic>) {
      return error[field]?.toString();
    }
    try {
      switch (field) {
        case 'qrCode':
          return (error as dynamic).qrCode?.toString();
        case 'code':
          return (error as dynamic).code?.toString();
        case 'name':
          return (error as dynamic).name?.toString();
        case 'msg':
          return (error as dynamic).msg?.toString();
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _handleReportError(dynamic error) {
    // TODO: 实现错误报告功能
    context.showInfoToast('错误报告功能待实现');
  }
}
