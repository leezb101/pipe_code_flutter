import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/bloc/dispatch/dispatch_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class DispatchConfirmationPage extends StatefulWidget {
  final int dispatchId;

  const DispatchConfirmationPage({super.key, required this.dispatchId});

  @override
  State<DispatchConfirmationPage> createState() =>
      _DispatchConfirmationPageState();
}

class _DispatchConfirmationPageState extends State<DispatchConfirmationPage> {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDispatchDetail();
  }

  void _loadDispatchDetail() {
    context.read<DispatchBloc>().add(LoadDispatchDetail(widget.dispatchId));
  }

  void _confirmDispatch(bool isApproved) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final request = CommonDoBusinessAuditVO(
      id: widget.dispatchId,
      pass: isApproved,
    );

    context.read<DispatchBloc>().add(AuditDispatch(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('调拨确认'), elevation: 0),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocListener<DispatchBloc, DispatchState>(
      listener: (context, state) {
        if (state.status == DispatchStatus.auditSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          context.showSuccessToast('调拨确认成功', isGlobal: true);

          // 刷新记录列表
          try {
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.todo),
            );
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.dispatch),
            );
          } catch (e) {
            // 忽略刷新错误，不影响主流程
          }

          context.pop();
        } else if (state.status == DispatchStatus.failure) {
          setState(() {
            _isSubmitting = false;
          });
          context.showErrorToast('调拨确认失败: ${state.errorMessage}');
        }
      },
      child: BlocBuilder<DispatchBloc, DispatchState>(
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
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMaterialsList(state.dispatchDetail!),
                        const SizedBox(height: 16),
                        _buildProjectInfo(state.dispatchDetail!),
                        const SizedBox(height: 16),
                        _buildWarehouseInfo(state.dispatchDetail!),
                        const SizedBox(height: 16),
                        _buildResponsiblePersonsSection(state.dispatchDetail!),
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

  Widget _buildMaterialsList(DispatchDetailVo dispatchDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...dispatchDetail.materialList.map(
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

  Widget _buildProjectInfo(DispatchDetailVo dispatchDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '项目信息：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '发出项目: ${dispatchDetail.fromProjectName ?? '未知项目'}',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          '接收项目: ${dispatchDetail.toProjectName ?? '未知项目'}',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildWarehouseInfo(DispatchDetailVo dispatchDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '仓库信息：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          '发出仓库: ${dispatchDetail.fromWarehouseName ?? '未知仓库'}',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          '接收仓库: ${dispatchDetail.toWarehouseName ?? '未知仓库'}',
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

  Widget _buildResponsiblePersonsSection(DispatchDetailVo dispatchDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponsiblePersonsList(
          '发出方负责人：',
          dispatchDetail.fromWarehouseUsers,
        ),
        const SizedBox(height: 20),
        _buildResponsiblePersonsList(
          '接收方负责人：',
          dispatchDetail.toWarehouseUsers,
        ),
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
                onPressed: _isSubmitting ? null : () => _confirmDispatch(true),
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
                    : const Text('调拨确认', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
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
