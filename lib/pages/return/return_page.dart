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
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../bloc/return/return_bloc.dart';
import '../../utils/go_router_popuntil.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/sync_vendor_data_error.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation; // enum only
// QrScanType removed
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key, required this.codes});

  final List<String> codes;

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  // 退库表单数据
  int _returnType = 0; // 默认质量不合格退库
  String _returnRemark = '';
  late final FileUploadCubit _imageUploadCubit;
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageUploadCubit = FileUploadCubit();
    // 加载物料信息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReturnBloc>().add(
        LoadReturnMaterialCodes(codes: widget.codes),
      );
    });
  }

  @override
  void dispose() {
    _imageUploadCubit.close();
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
                  return route.name == 'main';
                },
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('退库申请'),
          backgroundColor: AppTheme.getBusinessColor('return'),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '退库记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: AppTheme.grey50,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  children: [
                    _buildMaterialsList(),
                    const SizedBox(height: AppTheme.spacingLarge),
                    _buildMaterialButtonSection(),
                    const SizedBox(height: AppTheme.spacingLarge),
                    _buildReturnTypeSection(),
                    const SizedBox(height: AppTheme.spacingLarge),
                    _buildReturnRemarkSection(),
                    const SizedBox(height: AppTheme.spacingLarge),
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
    return UnifiedCard(
      title: '退库物料',
      icon: Icons.inventory,
      businessType: 'return',
      child: BlocBuilder<ReturnBloc, ReturnState>(
        builder: (context, state) {
          final materials = state.returnDetail?.materialList ?? [];
          final errorMaterials = state.errorMaterials;

          print(
            'ReturnPage: _buildMaterialsList - materials count: ${materials.length}, errorMaterials count: ${errorMaterials.length}',
          );
          if (errorMaterials.isNotEmpty) {
            print(
              'ReturnPage: First error material: ${errorMaterials.first.qrCode}',
            );
          }

          if (state.status == ReturnStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 正常材料列表
              if (materials.isNotEmpty)
                ...materials.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < materials.length - 1
                          ? AppTheme.spacingMedium
                          : 0,
                    ),
                    child: _buildMaterialItemFromVO(entry.value),
                  ),
                )
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
                          '暂无退库物料',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          '请通过扫码添加物料',
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
                  title: '退库异常材料',
                  onErrorItemTap: _handleErrorMaterialTap,
                  collapsible: true,
                  initialExpanded: true,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // 通过 MaterialVO 构造展示（追加/移除后的实时列表）
  Widget _buildMaterialItemFromVO(MaterialVO vo) {
    return MaterialListItem(
      materialName: vo.materialName,
      primaryText: vo.materialCode ?? '无',
      batchCode: vo.batchCode ?? '无',
      materialId: vo.materialId.toString(),
      quantity: vo.num,
      status: vo.status,
      statusName: vo.statusName,
      businessType: 'return',
    );
  }

  Widget _buildMaterialButtonSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 5,
          child: ElevatedButton(
            onPressed: _scanAppendMaterials,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingLarge,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: const Text('追加物料'),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          flex: 5,
          child: ElevatedButton(
            onPressed: _scanRemoveMaterials,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingLarge,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: const Text('移除物料'),
          ),
        ),
      ],
    );
  }

  Widget _buildReturnTypeSection() {
    return UnifiedCard(
      title: '退库类型',
      icon: Icons.category,
      businessType: 'return',
      child: _buildReturnTypeOptions(),
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
        SizedBox(height: AppTheme.spacingMedium),
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
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        color: _returnType == value
            ? color.withValues(alpha: 0.1)
            : Colors.white,
      ),
      child: RadioListTile<int>(
        value: value,
        groupValue: _returnType,
        onChanged: (value) {
          setState(() {
            _returnType = value!;
            context.read<ReturnBloc>().add(UpdateReturnType(returnType: value));
          });
        },
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: AppTheme.spacingSmall),
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
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        activeColor: color,
      ),
    );
  }

  Widget _buildReturnRemarkSection() {
    return UnifiedCard(
      title: '退库原因',
      icon: Icons.note_alt,
      businessType: 'return',
      child: SpeechInputWidget(
        controller: _remarkController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: '请详细说明退库原因...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.getBusinessColor('return')),
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
        onVoiceRecordingPath: (value) {
          context.read<ReturnBloc>().add(
            UpdateReturnRemarkVoice(returnRemarkVoice: [value]),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return UnifiedCard(
      title: '相关图片',
      icon: Icons.attach_file,
      businessType: 'return',
      child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
        bloc: _imageUploadCubit,
        builder: (context, states) {
          return ImageUploadWidget(
            title: '退库图片',
            states: states,
            watermarkText: '退库',
            includeTimeWatermark: true,
            includeLocationWatermark: true,
            onAdd: (files) {
              _imageUploadCubit.addFiles(files);
            },
            onRemove: (uniqueId) {
              _imageUploadCubit.removeFile(uniqueId);
            },
            onRetry: (uniqueId) {
              _imageUploadCubit.retryUpload(uniqueId);
            },
            maxImages: 6,
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
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
                      backgroundColor: AppTheme.getBusinessColor('return'),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
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
            SizedBox(height: AppTheme.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLarge,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
    context.goNamed('records', queryParameters: {'tab': 'accept'});
  }

  void _handleSubmitReturn() {
    // 验证表单
    if (_returnRemark.trim().isEmpty) {
      context.showErrorToast('请填写退库原因');
      return;
    }

    // 检查是否有错误材料
    final state = context.read<ReturnBloc>().state;
    if (state.errorMaterials.isNotEmpty) {
      // 显示确认对话框
      final materialCount = state.returnDetail?.materialList?.length ?? 0;
      _showSubmitConfirmation(materialCount, state.errorMaterials.length).then((
        confirmed,
      ) {
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
            title: '退库提交确认',
            businessType: 'return',
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

    final photoAttachments = uploadStates
        .where(
          (s) => s.status == UploadStatus.success && s.uploadResult != null,
        )
        .map(
          (state) => AttachmentVO(
            type: 1, // 1 for image
            name: state.uploadResult!.fileName,
            url: state.uploadResult!.filePath,
            attachFormat: state.uploadResult!.fileType,
          ),
        )
        .toList();

    // 通过BLoC提交退库申请
    context.read<ReturnBloc>().add(
      UpdateImageList(imageList: photoAttachments),
    );
    context.read<ReturnBloc>().add(const SubmitReturn());
  }

  void _handleReturn() {
    context.pop();
  }

  // --- 扫码追加/移除逻辑集成 QrScanFlowService ---
  Future<void> _scanAppendMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );
    final currentList =
        context.read<ReturnBloc>().state.returnDetail?.materialList ?? [];
    // 不维护原始码集合，传空数组使 normalize 视所有扫码为新增
    final currentCodes = <String>[];
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: currentCodes,
      batch: true,
      title: '追加退库物料',
      context: const {
        'source': 'returnPage_append',
        'entry': 'embedded',
        'operation': 'append',
      },
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final res = flow.normalize(request, raw);
    if (!mounted) return;
    if (res.addedCodes.isEmpty) return;
    try {
      final repo = getIt<MaterialHandleRepository>();
      final rsp = await repo.scanBatchToQueryAll(res.addedCodes);
      if (rsp.isSuccess && rsp.data != null) {
        // 将获取到的真实物料追加（基于 materialId 去重）
        // 记录重复的id，进行toast提示
        final existingIds = currentList.map((m) => m.materialId).toSet();
        final fetched = rsp.data!.normals;
        final appended = <MaterialVO>[];
        for (final m in fetched) {
          final id = m.baseInfo.materialId;
          if (existingIds.contains(id)) {
            if (mounted) context.showInfoToast('物料 $id 已存在');
            continue;
          }
          appended.add(
            MaterialVO(
              materialId: id,
              materialName: m.baseInfo.prodNm ?? '',
              num: 1,
            ),
          );
        }

        // 处理错误材料
        final currentErrorMaterials = context
            .read<ReturnBloc>()
            .state
            .errorMaterials;
        final newErrorMaterials = List<SyncVendorDataError>.from(
          currentErrorMaterials,
        );
        int newErrorCount = 0;

        for (final error in rsp.data!.errors) {
          // 简单的重复检查，基于qrCode
          final qrCode = error.qrCode ?? '';
          final isDuplicate = newErrorMaterials.any(
            (existingError) =>
                (existingError.qrCode ?? '') == qrCode && qrCode.isNotEmpty,
          );

          if (!isDuplicate) {
            newErrorMaterials.add(error);
            newErrorCount++;
          }
        }

        if (mounted) {
          context.read<ReturnBloc>().add(
            UpdateReturnMaterials(materials: [...currentList, ...appended]),
          );

          if (newErrorCount > 0) {
            context.read<ReturnBloc>().add(
              UpdateReturnErrorMaterials(errorMaterials: newErrorMaterials),
            );
          }

          final messages = <String>[];
          if (appended.isNotEmpty) {
            messages.add('已追加 ${appended.length} 个正常物料');
          }
          if (newErrorCount > 0) {
            messages.add('发现 ${newErrorCount} 个异常物料');
          }

          if (messages.isNotEmpty) {
            context.showSuccessToast(messages.join('，'));
          } else {
            context.showInfoToast('未发现新的物料');
          }
        }
      } else {
        if (mounted) context.showInfoToast('未查到新增物料');
      }
    } catch (e) {
      if (mounted) context.showErrorToast('获取物料失败');
    }
  }

  Future<void> _scanRemoveMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );
    final currentList =
        context.read<ReturnBloc>().state.returnDetail?.materialList ?? [];
    // 不基于前端 currentCodes 过滤，传空使所有扫码进入 removedCodes
    final currentCodes = <String>[];
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      currentCodes: currentCodes,
      batch: true,
      title: '移除退库物料',
      context: const {
        'source': 'returnPage_remove',
        'entry': 'embedded',
        'operation': 'remove',
      },
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final res = flow.normalize(request, raw);
    if (!mounted) return;
    if (res.removedCodes.isEmpty) return;
    try {
      final repo = getIt<MaterialHandleRepository>();
      final rsp = await repo.scanBatchToQueryAll(res.removedCodes);
      if (rsp.isSuccess && rsp.data != null) {
        final idsToRemove = rsp.data!.normals
            .map((m) => m.baseInfo.materialId)
            .toSet();

        // 处理错误材料的移除
        final currentErrorMaterials = context
            .read<ReturnBloc>()
            .state
            .errorMaterials;
        final errorCodesToRemove = rsp.data!.errors
            .map((error) => error.qrCode ?? '')
            .where((code) => code.isNotEmpty)
            .toSet();

        final updatedErrors = currentErrorMaterials
            .where((error) => !errorCodesToRemove.contains(error.qrCode ?? ''))
            .toList();

        if (idsToRemove.isEmpty && errorCodesToRemove.isEmpty) {
          if (mounted) context.showInfoToast('未匹配到可移除的物料');
          return;
        }

        final remaining = currentList
            .where((m) => !idsToRemove.contains(m.materialId))
            .toList();

        if (mounted) {
          context.read<ReturnBloc>().add(
            UpdateReturnMaterials(materials: remaining),
          );

          if (updatedErrors.length < currentErrorMaterials.length) {
            context.read<ReturnBloc>().add(
              UpdateReturnErrorMaterials(errorMaterials: updatedErrors),
            );
          }

          final removedNormalCount = currentList.length - remaining.length;
          final removedErrorCount =
              currentErrorMaterials.length - updatedErrors.length;

          final messages = <String>[];
          if (removedNormalCount > 0) {
            messages.add('移除${removedNormalCount}个正常物料');
          }
          if (removedErrorCount > 0) {
            messages.add('移除${removedErrorCount}个异常物料');
          }

          if (messages.isNotEmpty) {
            context.showSuccessToast(messages.join('，'));
          } else {
            context.showInfoToast('未移除任何物料');
          }
        }
      } else {
        if (mounted) context.showInfoToast('未匹配到可移除的码');
      }
    } catch (e) {
      if (mounted) context.showErrorToast('移除失败');
    }
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
