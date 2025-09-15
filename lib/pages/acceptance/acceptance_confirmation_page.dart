import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_bloc.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_event.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_state.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class AcceptanceConfirmationPage extends StatefulWidget {
  final int acceptanceId;

  const AcceptanceConfirmationPage({super.key, required this.acceptanceId});

  @override
  State<AcceptanceConfirmationPage> createState() =>
      _AcceptanceConfirmationPageState();
}

class _AcceptanceConfirmationPageState
    extends State<AcceptanceConfirmationPage> {
  bool _isSubmitting = false;

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

  void _confirmAcceptance(bool isApproved) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final request = CommonDoBusinessAuditVO(
      id: widget.acceptanceId,
      pass: isApproved,
    );

    context.read<AcceptanceBloc>().add(AuditAcceptance(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('验收确认'), elevation: 0),
      backgroundColor: AppTheme.grey50,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocListener<AcceptanceBloc, AcceptanceState>(
      listener: (context, state) {
        if (state is AcceptanceAudited) {
          setState(() {
            _isSubmitting = false;
          });
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('验收确认成功'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          // Navigator.of(context).pop(true);
          // 刷新记录列表
          try {
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.todo),
            );
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.accept),
            );
          } catch (e) {
            // 忽略刷新错误，不影响主流程
          }
          context.showSuccessToast('验收确认成功', isGlobal: true);
          context.pop();
        } else if (state is AcceptanceError) {
          setState(() {
            _isSubmitting = false;
          });
          context.showErrorToast('验收确认失败: ${state.message}');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('验收确认失败: ${state.message}'),
          //     backgroundColor: Colors.red,
          //   ),
          // );
        }
      },
      child: BlocBuilder<AcceptanceBloc, AcceptanceState>(
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
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQrCodeSection(state.acceptanceInfo),
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildMaterialsList(state.acceptanceInfo),
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildAttachmentsSection(state.acceptanceInfo),
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildWarehouseInfo(state.acceptanceInfo),
                        const SizedBox(height: AppTheme.spacingLarge),
                        _buildResponsiblePersonsSection(state.acceptanceInfo),
                        const SizedBox(height: 100), // 为底部按钮留出空间
                      ],
                    ),
                  ),
                ),
                _buildConfirmationButtons(),
              ],
            );
          }

          return const Center(child: Text('暂无数据'));
        },
      ),
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
          InfoRow(label: '仓库ID', value: acceptanceInfo.warehouseId.toString()),
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
    return UnifiedActionButtons(
      primaryButton: UnifiedButton(
        text: '验收确认',
        type: UnifiedButtonType.primary,
        onPressed: _isSubmitting ? null : () => _confirmAcceptance(true),
        isLoading: _isSubmitting,
        backgroundColor: AppTheme.acceptanceColor,
      ),
      secondaryButton: UnifiedButton(
        text: '不合格',
        type: UnifiedButtonType.outlined,
        onPressed: _isSubmitting ? null : () => _confirmAcceptance(false),
        foregroundColor: AppTheme.warningColor,
        borderColor: AppTheme.warningColor,
      ),
      isFullWidth: true,
    );
  }

  void launchUrlString(String s) {
    // 这里可以使用url_launcher包来打开链接
    // 例如：launchUrl(Uri.parse(s));
    // 但为了简化示例，这里仅打印链接
    debugPrint('打开链接: $s');
  }
}
