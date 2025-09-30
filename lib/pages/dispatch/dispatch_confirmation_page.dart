import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/nativebloc/dispatch_confirmation_controller.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/optimized_stream_builder.dart';
import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class DispatchConfirmationPage extends StatefulWidget {
  final int dispatchId;
  const DispatchConfirmationPage({super.key, required this.dispatchId});

  @override
  State<DispatchConfirmationPage> createState() =>
      _DispatchConfirmationPageState();
}

class _DispatchConfirmationPageState extends State<DispatchConfirmationPage> {
  late DispatchConfirmationController _controller;
  bool _hasShownSuccessMessage = false;
  final TextEditingController _remarkController = TextEditingController();
  final List<String> _reasonVoice = [];

  @override
  void initState() {
    super.initState();
    _controller = DispatchConfirmationController(getIt<DispatchRepository>());
    _loadDispatchDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadDispatchDetail() {
    _controller.loadDispatchDetail(widget.dispatchId);
  }

  void _confirmDispatch() {
    _controller.confirmDispatch(widget.dispatchId);
  }

  void _rejectDispatch() {
    _controller.rejectDispatch(
      dispatchId: widget.dispatchId,
      reason: _remarkController.text,
      reasonVoice: _reasonVoice,
    );
  }

  void _handleStateChange(DispatchConfirmationState state) {
    // 处理成功状态
    if (state.isSuccess && !_hasShownSuccessMessage) {
      _hasShownSuccessMessage = true;
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
        Logger.debug('刷新记录列表失败: $e', tag: 'DispatchConfirmationPage');
      }

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
    return Scaffold(
      backgroundColor: AppTheme.grey100,
      appBar: AppBar(
        title: const Text('调拨确认', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: OptimizedStreamBuilder<DispatchConfirmationState>(
        stream: _controller.state,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(state);
          });
          return _buildBody(state);
        },
        loadingBuilder: (context) => common.LoadingWidget(),
        errorBuilder: (context, error) => common.ErrorWidget(
          message: error.toString(),
          onRetry: _loadDispatchDetail,
        ),
      ),
    );
  }

  Widget _buildBody(DispatchConfirmationState state) {
    if (state.isLoading && state.dispatchDetail == null) {
      return common.LoadingWidget();
    }
    if (state.errorMessage != null && state.dispatchDetail == null) {
      return common.ErrorWidget(
        message: state.errorMessage!,
        onRetry: _loadDispatchDetail,
      );
    }

    if (state.dispatchDetail != null) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMaterialsList(state.dispatchDetail!),
                  SizedBox(height: AppTheme.spacingLarge),
                  _buildProjectInfo(state.dispatchDetail!),
                  SizedBox(height: AppTheme.spacingLarge),
                  _buildWarehouseInfo(state.dispatchDetail!),
                  SizedBox(height: AppTheme.spacingLarge),
                  _buildResponsiblePersonsSection(state.dispatchDetail!),
                  SizedBox(height: AppTheme.spacingXXLarge * 2),
                ],
              ),
            ),
          ),
          _buildConfirmationButtons(state),
        ],
      );
    }

    return const Center(child: Text('暂无数据'));
  }

  Widget _buildMaterialsList(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      businessType: 'dispatch',
      title: '调拨材料列表',
      icon: Icons.inventory_2,
      child: Column(
        children: dispatchDetail.materialList
            .map(
              (material) => MaterialListItem(
                materialName: material.materialName,
                primaryText: material.materialCode,
                batchCode: material.batchCode,
                materialId: material.materialId.toString(),
                quantity: material.num,
                showQuantityBadge: true,
                businessType: 'dispatch',
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProjectInfo(DispatchDetailVo dispatchDetail) {
    return UnifiedCard(
      businessType: 'dispatch',
      title: '项目信息',
      icon: Icons.business,
      child: Column(
        children: [
          InfoRow(
            icon: Icons.launch,
            label: '发出项目',
            value: dispatchDetail.fromProjectName ?? '未知项目',
          ),
          SizedBox(height: AppTheme.spacingSmall),
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
      businessType: 'dispatch',
      title: '仓库信息',
      icon: Icons.warehouse,
      child: Column(
        children: [
          InfoRow(
            icon: Icons.outbox,
            label: '发出仓库',
            value: dispatchDetail.fromWarehouseName ?? '未知仓库',
          ),
          SizedBox(height: AppTheme.spacingSmall),
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
    return Column(
      children: [
        if (dispatchDetail.fromWarehouseUsers.isNotEmpty)
          UnifiedCard(
            businessType: 'dispatch',
            title: '发出方负责人',
            icon: Icons.person_outline,
            child: Column(
              children: dispatchDetail.fromWarehouseUsers
                  .map((user) => _buildUserInfoItem(user))
                  .toList(),
            ),
          ),
        if (dispatchDetail.fromWarehouseUsers.isNotEmpty &&
            dispatchDetail.toWarehouseUsers.isNotEmpty)
          SizedBox(height: AppTheme.spacingLarge),
        if (dispatchDetail.toWarehouseUsers.isNotEmpty)
          UnifiedCard(
            businessType: 'dispatch',
            title: '接收方负责人',
            icon: Icons.person,
            child: Column(
              children: dispatchDetail.toWarehouseUsers
                  .map((user) => _buildUserInfoItem(user))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfoItem(CommonUserVO user) {
    return UserInfoWidget(
      name: user.name,
      phone: user.phone,
      trailing: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSmall,
          vertical: AppTheme.spacingXSmall,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.grey400),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          '推送',
          style: TextStyle(fontSize: 12, color: AppTheme.grey600),
        ),
      ),
    );
  }

  Widget _buildConfirmationButtons(DispatchConfirmationState state) {
    return UnifiedActionButtons(
      primaryButton: UnifiedButton(
        text: '确认调拨',
        type: UnifiedButtonType.primary,
        onPressed: state.isSubmitting ? null : _confirmDispatch,
        isLoading: state.isSubmitting,
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
      ),
      secondaryButton: UnifiedButton(
        text: '驳回',
        type: UnifiedButtonType.outlined,
        onPressed: state.isSubmitting ? null : _showRejectionDialog,
        foregroundColor: Colors.redAccent,
        borderColor: Colors.redAccent,
      ),
      isFullWidth: true,
    );
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('驳回调拨'),
          content: SpeechInputWidget(
            controller: _remarkController,
            onVoiceRecordingPath: (filePath) {
              setState(() {
                // 重命名为 returnRemarkVoice 以更清晰地表达其用途
                // _reasonVoice.add(filePath); --- IGNORE ---
                _reasonVoice.add(filePath);
              });
            },
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '请输入驳回原因',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
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
                Navigator.of(context).pop();
                _rejectDispatch();
              },
              child: Text('确认驳回'),
            ),
          ],
        );
      },
    );
  }
}
