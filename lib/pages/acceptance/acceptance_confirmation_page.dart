import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/nativebloc/acceptance_confirmation_controller.dart';
import 'package:pipe_code_flutter/utils/tracing_context_x.dart';

class AcceptanceConfirmationPage extends StatefulWidget {
  final int acceptanceId;

  const AcceptanceConfirmationPage({super.key, required this.acceptanceId});

  @override
  State<AcceptanceConfirmationPage> createState() =>
      _AcceptanceConfirmationPageState();
}

class _AcceptanceConfirmationPageState
    extends State<AcceptanceConfirmationPage> {
  late AcceptanceConfirmationController _controller;
  bool _hasShownSuccessMessage = false;
  final TextEditingController _remarkController = TextEditingController();
  final List<String> _reasonVoice = [];

  @override
  void initState() {
    super.initState();
    _controller = AcceptanceConfirmationController(
      getIt<AcceptanceRepository>(),
    );
    _loadAcceptanceDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _loadAcceptanceDetail() {
    final tracingContext = context.createActionContext('加载验收详情');
    _controller.loadAcceptanceDetail(
      widget.acceptanceId,
      tracingContext: tracingContext,
    );
  }

  void _confirmAcceptance() {
    final tracingContext = context.createActionContext('验收确认');
    _controller.confirmAcceptance(
      widget.acceptanceId,
      tracingContext: tracingContext,
    );
  }

  void _rejectAcceptance() {
    final tracingContext = context.createActionContext('驳回验收');
    _controller.rejectAcceptance(
      acceptanceId: widget.acceptanceId,
      reason: _remarkController.text,
      reasonVoice: _reasonVoice,
      tracingContext: tracingContext,
    );
  }

  void _handleStateChange(AcceptanceConfirmationState state) {
    // 处理成功状态
    if (state.isSuccess && !_hasShownSuccessMessage) {
      _hasShownSuccessMessage = true;
      context.showSuccessToast('验收确认成功', isGlobal: true);

      // 刷新记录列表
      try {
        context.read<RecordsBloc>().add(
          RefreshRecords(recordType: RecordType.todo),
        );
        context.read<RecordsBloc>().add(
          RefreshRecords(recordType: RecordType.accept),
        );
      } catch (e) {
        Logger.debug('刷新记录列表失败: $e', tag: 'AcceptanceConfirmationPage');
      }

      // 延迟pop，让用户看到成功消息
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.pop();
        }
      });
    }

    // 处理错误状态
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      context.showErrorToast('操作失败: ${state.errorMessage}');
      // 清除错误消息，避免重复显示
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.clearError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AcceptanceConfirmationState>(
      stream: _controller.state,
      initialData: AcceptanceConfirmationState(),
      builder: (context, snapshot) {
        final state = snapshot.data ?? AcceptanceConfirmationState();

        // 延迟处理状态变化，避免在构建期间调用 setState
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleStateChange(state);
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('验收确认'),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AcceptanceConfirmationState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null &&
        state.errorMessage!.isNotEmpty &&
        state.acceptanceInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '加载失败: ${state.errorMessage}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAcceptanceDetail,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    if (state.acceptanceInfo != null) {
      return _buildAcceptanceDetail(context, state.acceptanceInfo!, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildAcceptanceDetail(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    AcceptanceConfirmationState state,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildQrCodeSection(acceptanceInfo),
                // const SizedBox(height: AppTheme.spacingLarge),
                _buildMaterialsList(acceptanceInfo),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildAttachmentsSection(acceptanceInfo),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildWarehouseInfo(acceptanceInfo),
                const SizedBox(height: AppTheme.spacingLarge),
                _buildResponsiblePersonsSection(acceptanceInfo),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
        ),
        _buildConfirmationButtons(),
      ],
    );
  }

  Widget _buildQrCodeSection(AcceptanceInfoVO? acceptanceInfo) {
    return UnifiedCard(
      title: '一管一码',
      icon: Icons.qr_code,
      businessType: 'acceptance',
      child: Column(
        children: [
          if (acceptanceInfo != null &&
              acceptanceInfo.materialList.isNotEmpty) ...[
            InfoRow(
              label: '代表性材料',
              value: acceptanceInfo.materialList.first.materialName,
            ),
          ],
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
        children: acceptanceInfo.materialList
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < acceptanceInfo.materialList.length - 1
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
      businessType: 'acceptance',
      status: material.status,
      statusName: material.statusName,
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

  Widget _buildAttachmentsSection(AcceptanceInfoVO acceptanceInfo) {
    // 筛选不同类型的附件
    final acceptancePhotos = acceptanceInfo.imageList.toList();
    final reportDocumentUrl = acceptanceInfo.sendAcceptUrl;
    final acceptanceReportUrl = acceptanceInfo.acceptReportUrl;
    final reportDocumentName = reportDocumentUrl
        ?.split('/')
        .last
        .split('?')
        .first;
    final acceptanceReportName = acceptanceReportUrl
        ?.split('/')
        .last
        .split('?')
        .first;

    return UnifiedCard(
      title: '附件信息',
      icon: Icons.attach_file,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('验收照片：', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildPhotosRow(acceptancePhotos),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildDocumentInfo('报验单', reportDocumentName, reportDocumentUrl),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildDocumentInfo('验收报告', acceptanceReportName, acceptanceReportUrl),
        ],
      ),
    );
  }

  Widget _buildPhotosRow(List<AttachmentVO> photos) {
    if (photos.isEmpty) {
      return Row(
        children: [
          _buildAttachmentPlaceholder(),
          const SizedBox(width: 16),
          _buildAttachmentPlaceholder(),
        ],
      );
    }

    return Row(
      children: [
        if (photos.isNotEmpty) _buildPhotoWidget(photos[0]),
        const SizedBox(width: 16),
        if (photos.length > 1)
          _buildPhotoWidget(photos[1])
        else
          _buildAttachmentPlaceholder(),
      ],
    );
  }

  Widget _buildPhotoWidget(AttachmentVO photo) {
    final authState = context.read<AuthBloc>().state;
    final token = (authState is AuthLoginSuccess) ? authState.wxLoginVO.tk : '';
    return GestureDetector(
      onTap: () => _previewPhoto(photo),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photo.url.contains('?')
                ? '${photo.url}&auth_toke=$token'
                : '${photo.url}?auth_toke=$token',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey.shade600,
                size: 24,
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

  Widget _buildAttachmentPlaceholder() {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Icon(Icons.image, color: Colors.blue.shade600, size: 32),
    );
  }

  Widget _buildDocumentInfo(String label, String? name, String? documentUrl) {
    final authState = context.read<AuthBloc>().state;
    final token = (authState is AuthLoginSuccess) ? authState.wxLoginVO.tk : '';
    return Row(
      children: [
        Text(
          '$label：',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              if (documentUrl?.isNotEmpty == true) {
                // 通过documentUrl打开一个预览地址，一般为PDF
                context.push(
                  '/pdf-preview',
                  extra: documentUrl!.contains('?')
                      ? '$documentUrl&auth_toke=$token'
                      : '$documentUrl?auth_toke=$token',
                );
              }
            },
            child: Text(
              name?.isNotEmpty == true ? name! : '暂无$label',
              style: TextStyle(
                fontSize: 18,
                color: documentUrl?.isNotEmpty == true
                    ? Colors.blueAccent
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
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
          InfoRow(
            label: '仓库名称',
            value: acceptanceInfo.warehouseName.toString(),
          ),
        ],
      ),
    );
  }

  void _previewPhoto(AttachmentVO photo) {
    showDialog(
      context: context,
      builder: (context) {
        final authState = context.read<AuthBloc>().state;
        final token = (authState is AuthLoginSuccess)
            ? authState.wxLoginVO.tk
            : '';
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        photo.name ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Image.network(
                    photo.url.contains('?')
                        ? '${photo.url}&auth_toke=$token'
                        : '${photo.url}?auth_toke=$token',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 48,
                      ),
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

  Widget _buildResponsiblePersonsSection(AcceptanceInfoVO acceptanceInfo) {
    return UnifiedCard(
      title: '负责人信息',
      icon: Icons.people,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiblePersonsList(
            '监理方负责人',
            acceptanceInfo.supervisorUsers,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildResponsiblePersonsList(
            '建设方负责人',
            acceptanceInfo.constructionUsers,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildResponsiblePersonsList('仓库负责人', acceptanceInfo.warehouseUsers),
        ],
      ),
    );
  }

  Widget _buildResponsiblePersonsList(String title, List<CommonUserVO> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleSmall),
        const SizedBox(height: AppTheme.spacingSmall),
        ...users.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < users.length - 1 ? AppTheme.spacingSmall : 0,
            ),
            child: _buildUserItem(entry.value),
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(CommonUserVO user) {
    return UserInfoWidget(
      name: user.name,
      phone: user.phone,
      showPushOption: true,
      isPushSelected: true,
    );
  }

  Widget _buildConfirmationButtons() {
    return StreamBuilder<AcceptanceConfirmationState>(
      stream: _controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? AcceptanceConfirmationState();
        return UnifiedActionButtons(
          primaryButton: UnifiedButton(
            text: '验收确认',
            type: UnifiedButtonType.primary,
            onPressed: state.isSubmitting ? null : _confirmAcceptance,
            isLoading: state.isSubmitting,
            backgroundColor: AppTheme.acceptanceColor,
          ),
          secondaryButton: UnifiedButton(
            text: '驳回',
            type: UnifiedButtonType.outlined,
            onPressed: state.isSubmitting ? null : _showRejectDialog,
            foregroundColor: AppTheme.warningColor,
            borderColor: AppTheme.warningColor,
          ),
          isFullWidth: true,
        );
      },
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝验收'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请说明驳回原因：'),
            const SizedBox(height: 16),
            SpeechInputWidget(
              controller: _remarkController,
              onVoiceRecordingPath: (filePath) {
                // 录音上传完成，保存路径
                _reasonVoice.add(filePath);
              },
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入驳回原因',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.returnColor,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingMedium,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _rejectAcceptance();
            },
            child: const Text('确认驳回'),
          ),
        ],
      ),
    );
  }

  void launchUrlString(String s) {
    // 这里可以使用url_launcher包来打开链接
    // 例如：launchUrl(Uri.parse(s));
    // 但为了简化示例，这里仅打印链接
    debugPrint('打开链接: $s');
  }
}
