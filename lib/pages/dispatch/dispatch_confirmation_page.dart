import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/dispatch/dispatch_detail_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/bloc/dispatch/dispatch_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';

class DispatchConfirmationPage extends StatelessWidget {
  final int dispatchId;

  const DispatchConfirmationPage({super.key, required this.dispatchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DispatchBloc>(
      create: (context) => DispatchBloc(
        dispatchRepository: getIt(),
        commonQueryApiService: getIt(),
      ),
      child: _DispatchConfirmationPageView(dispatchId: dispatchId),
    );
  }
}

class _DispatchConfirmationPageView extends StatefulWidget {
  final int dispatchId;

  const _DispatchConfirmationPageView({required this.dispatchId});

  @override
  State<_DispatchConfirmationPageView> createState() =>
      _DispatchConfirmationPageViewState();
}

class _DispatchConfirmationPageViewState
    extends State<_DispatchConfirmationPageView> {
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
      backgroundColor: AppTheme.grey100,
      appBar: AppBar(
        title: const Text('调拨确认', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
                        SizedBox(
                          height: AppTheme.spacingXXLarge * 2,
                        ), // 为底部按钮留出空间
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
    return UnifiedCard(
      businessType: 'dispatch',
      title: '调拨材料列表',
      icon: Icons.inventory_2,
      child: Column(
        children: dispatchDetail.materialList
            .map(
              (material) => MaterialListItem(
                materialName: material.materialName,
                quantity: material.num,
                showQuantityBadge: true,
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
            label: '发出项目',
            value: dispatchDetail.fromProjectName ?? '未知项目',
          ),
          SizedBox(height: AppTheme.spacingSmall),
          InfoRow(label: '接收项目', value: dispatchDetail.toProjectName ?? '未知项目'),
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
            label: '发出仓库',
            value: dispatchDetail.fromWarehouseName ?? '未知仓库',
          ),
          SizedBox(height: AppTheme.spacingSmall),
          InfoRow(
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
        UnifiedCard(
          businessType: 'dispatch',
          title: '发出方负责人',
          icon: Icons.person_outline,
          child: Column(
            children: dispatchDetail.fromWarehouseUsers
                .map(
                  (user) => UserInfoWidget(
                    name: user.name,
                    phone: user.phone,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grey400),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '推送',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: AppTheme.spacingLarge),
        UnifiedCard(
          businessType: 'dispatch',
          title: '接收方负责人',
          icon: Icons.person,
          child: Column(
            children: dispatchDetail.toWarehouseUsers
                .map(
                  (user) => UserInfoWidget(
                    name: user.name,
                    phone: user.phone,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grey400),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '推送',
                        style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationButtons() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _confirmDispatch(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getBusinessColor('dispatch'),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLarge,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        '调拨确认',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: AppTheme.spacingLarge,
                  ),
                  side: BorderSide(color: AppTheme.grey600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Text(
                  '返回',
                  style: TextStyle(fontSize: 16, color: AppTheme.grey600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
