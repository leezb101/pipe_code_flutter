import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_bloc.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_event.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_state.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

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
          context.showSuccessToast('验收确认成功');
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQrCodeSection(state.acceptanceInfo),
                        const SizedBox(height: 16),
                        _buildMaterialsList(state.acceptanceInfo),
                        const SizedBox(height: 16),
                        _buildAttachmentsSection(state.acceptanceInfo),
                        const SizedBox(height: 16),
                        _buildWarehouseInfo(state.acceptanceInfo),
                        const SizedBox(height: 16),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            '一管一码',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(),
          if (acceptanceInfo != null &&
              acceptanceInfo.materialList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '代表性材料: ${acceptanceInfo.materialList.first.materialName}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaterialsList(AcceptanceInfoVO acceptanceInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...acceptanceInfo.materialList.map(
          (material) => _buildMaterialItem(material),
        ),
      ],
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(material.materialName, style: const TextStyle(fontSize: 16)),
          Text('${material.num}个', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection(AcceptanceInfoVO acceptanceInfo) {
    // 筛选不同类型的附件
    final acceptancePhotos = acceptanceInfo.imageList
        .where((item) => item.type == 3)
        .toList();
    final reportDocuments = acceptanceInfo.imageList
        .where((item) => item.type == 1)
        .toList();
    final acceptanceReports = acceptanceInfo.imageList
        .where((item) => item.type == 2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '验收照片：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildPhotosRow(acceptancePhotos),
        const SizedBox(height: 20),
        _buildDocumentInfo('报验单', reportDocuments),
        const SizedBox(height: 12),
        _buildDocumentInfo('验收报告', acceptanceReports),
      ],
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
            photo.url,
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

  Widget _buildDocumentInfo(String label, List<AttachmentVO> documents) {
    return Row(
      children: [
        Text(
          '$label：',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            documents.isNotEmpty ? documents.first.name : '暂无$label',
            style: TextStyle(
              fontSize: 16,
              color: documents.isNotEmpty ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseInfo(AcceptanceInfoVO acceptanceInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '仓库：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '${acceptanceInfo.warehouseTypeDescription} (ID: ${acceptanceInfo.warehouseId})',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  void _previewPhoto(AttachmentVO photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      photo.name,
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
                  photo.url,
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
      ),
    );
  }

  Widget _buildResponsiblePersonsSection(AcceptanceInfoVO acceptanceInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponsiblePersonsList('监理方负责人：', acceptanceInfo.supervisorUsers),
        const SizedBox(height: 20),
        _buildResponsiblePersonsList(
          '建设方负责人：',
          acceptanceInfo.constructionUsers,
        ),
        const SizedBox(height: 20),
        _buildResponsiblePersonsList('仓库负责人：', acceptanceInfo.warehouseUsers),
      ],
    );
  }

  Widget _buildResponsiblePersonsList(String title, List<CommonUserVO> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...users.map((user) => _buildUserItem(user)),
      ],
    );
  }

  Widget _buildUserItem(CommonUserVO user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${user.name} - ${user.phone}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('推送', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _confirmAcceptance(true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue.shade600),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('验收确认', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _confirmAcceptance(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.orange.shade600),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('验收驳回', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade600),
                ),
                child: const Text('返回', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
