/*
 * @Author: LeeZB
 * @Date: 2025-07-27 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 16:11:01
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/dispatch/dispatch_bloc.dart';
import 'package:pipe_code_flutter/bloc/user/user_bloc.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/project/project_simple_vo.dart';
import 'package:pipe_code_flutter/models/common/warehouse_vo.dart';
import 'package:pipe_code_flutter/models/dispatch/do_dispatch_apply_vo.dart';

import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation; // enum only
// QrScanType removed

import '../../bloc/user/user_state.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class DispatchApplicationPage extends StatelessWidget {
  // final MaterialInfoForBusiness materials;
  final List<String> initialCodes;

  const DispatchApplicationPage({super.key, required this.initialCodes});

  @override
  Widget build(BuildContext context) {
    // BlocProvider is now handled by the router, so we just return the view.
    return DispatchApplicationView(initialCodes: initialCodes);
  }
}

class DispatchApplicationView extends StatefulWidget {
  final List<String> initialCodes;

  const DispatchApplicationView({super.key, required this.initialCodes});

  @override
  State<DispatchApplicationView> createState() =>
      _DispatchApplicationViewState();
}

class _DispatchApplicationViewState extends State<DispatchApplicationView> {
  final _formKey = GlobalKey<FormState>();
  ProjectSimpleVo? _selectedTargetProject;
  WarehouseVO? _selectedTargetWarehouse;
  final List<int> _selectedManagerIds = [];

  @override
  void initState() {
    final codes = widget.initialCodes;
    context.read<DispatchBloc>().add(
      InitializeMaterialsFromCodes(codes: codes),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调拨申请', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to dispatch records page
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('调拨记录'),
          ),
        ],
      ),
      backgroundColor: AppTheme.grey50,
      body: BlocConsumer<DispatchBloc, DispatchState>(
        listener: (context, state) {
          if (state.status == DispatchStatus.success &&
              state.matchMessage != null) {
            ToastUtils.showSuccess(context, state.matchMessage!);
            // 清空提示信息
          }
          if (state.status == DispatchStatus.failure) {
            ToastUtils.showError(context, state.errorMessage ?? '操作失败');
          } else if (state.status == DispatchStatus.applySuccess) {
            ToastUtils.showSuccess(context, '调拨申请提交成功！');
            // Pop twice to go back to the page before qr_scan_page
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state.status == DispatchStatus.initial ||
              (state.status == DispatchStatus.loadingSourceInfo &&
                  state.materialList == null)) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DispatchState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaterialList(state.materialList ?? []),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildScanButtons(),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildForm(context, state),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(List<MaterialVO> materials) {
    return UnifiedCard(
      title: '一管一码',
      icon: Icons.inventory,
      businessType: 'dispatch',
      child: materials.isEmpty
          ? Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  '暂无物料，请扫码添加',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: materials
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key < materials.length - 1
                            ? AppTheme.spacingMedium
                            : 0,
                      ),
                      child: MaterialListItem(
                        materialName: entry.value.materialName,
                        quantity: entry.value.num,
                        businessType: 'dispatch',
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildScanButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () => _scanAppendMaterials(context),
            label: Text('继续扫码'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('dispatch'),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _scanRemoveMaterials(context),
            label: Text('扫码剔除'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              side: BorderSide(color: Colors.red.shade300),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, DispatchState state) {
    final userState = context.read<UserBloc>().state as UserLoaded;
    final userName = userState.wxLoginVO.name;

    return UnifiedCard(
      title: '调拨信息',
      icon: Icons.assignment,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: '出库方项目', value: state.sourceProject?.name ?? '加载中...'),
          SizedBox(height: AppTheme.spacingMedium),
          _buildDropdownRow<ProjectSimpleVo>(
            label: '入库方项目:',
            value: _selectedTargetProject,
            items: state.availableProjects,
            onChanged: (value) {
              setState(() {
                _selectedTargetProject = value;
              });
            },
            itemBuilder: (item) =>
                DropdownMenuItem(value: item, child: Text(item.name)),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '发出仓库',
            value:
                '${state.sourceWarehouse?.name ?? "加载中..."} - ${state.sourceWarehouse?.address ?? ""}',
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildDropdownRow<WarehouseVO>(
            label: '接收仓库:',
            value: _selectedTargetWarehouse,
            items: state.availableWarehouses,
            onChanged: (value) {
              if (value != null) {
                context.read<DispatchBloc>().add(
                  UpdateWarehouseUsersList(value.id),
                );
              }
              setState(() {
                _selectedTargetWarehouse = value;
              });
            },
            itemBuilder: (item) => DropdownMenuItem(
              value: item,
              child: Text('${item.name} - ${item.address}'),
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          InfoRow(label: '借货人', value: userName),
          SizedBox(height: AppTheme.spacingLarge),
          Text(
            '接收仓库负责人:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getBusinessColor('dispatch'),
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          _buildWarehouseUserList(state.availableWarehouseUsers),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required DropdownMenuItem<T> Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map(itemBuilder).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) => value == null ? '请选择一个选项' : null,
    );
  }

  Widget _buildWarehouseUserList(List<CommonUserVO> users) {
    if (users.isEmpty) {
      return Text('没有可用的仓库负责人', style: TextStyle(color: AppTheme.grey600));
    }
    return Column(
      children: users.map((user) {
        final isSelected = _selectedManagerIds.contains(user.userId);
        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
          child: UserInfoWidget(
            name: user.name,
            phone: user.phone,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedManagerIds.remove(user.userId);
                } else {
                  _selectedManagerIds.add(user.userId);
                }
              });
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '推送',
                  style: TextStyle(fontSize: 14, color: AppTheme.grey600),
                ),
                SizedBox(width: AppTheme.spacingSmall),
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected
                      ? AppTheme.getBusinessColor('dispatch')
                      : AppTheme.grey400,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, DispatchState state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                (state.status == DispatchStatus.loading ||
                    state.status == DispatchStatus.loadingSourceInfo)
                ? null
                : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('dispatch'),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Text(
              '提交',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              side: BorderSide(color: AppTheme.grey600),
              foregroundColor: AppTheme.grey600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Text('返回', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = context.read<DispatchBloc>().state;
    if (state.sourceProject?.id == null ||
        _selectedTargetProject?.id == null ||
        state.sourceWarehouse?.id == null ||
        _selectedTargetWarehouse?.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请确保所有项目和仓库都已选择')));
      return;
    }

    final request = DoDispatchApplyVo(
      fromProjectId: state.sourceProject!.id,
      toProjectId: _selectedTargetProject!.id,
      toWarehouseId: _selectedTargetWarehouse!.id,
      materialList: state.materialList ?? [],
      messageTo: _selectedManagerIds,
      imageList: [], // Assuming no images are attached for now
    );

    context.read<DispatchBloc>().add(SubmitDispatchApplication(request));
  }

  Future<void> _scanAppendMaterials(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'dispatchApplication_append',
        'entry': 'embedded',
        'operation': 'append',
      },
      title: '继续扫码',
    );
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.addedCodes.isEmpty || !context.mounted) return;
    context.read<DispatchBloc>().add(
      UpdateApplicationMaterialWithAppendCodes(res.addedCodes),
    );
  }

  Future<void> _scanRemoveMaterials(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'dispatchApplication_remove',
        'entry': 'embedded',
        'operation': 'remove',
      },
      title: '继续扫码',
    );
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.removedCodes.isEmpty || !context.mounted) return;
    context.read<DispatchBloc>().add(
      UpdateApplicationMaterialWithRemoveCodes(res.removedCodes),
    );
  }
}
