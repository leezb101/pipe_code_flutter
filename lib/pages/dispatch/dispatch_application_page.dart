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
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';

import '../../bloc/user/user_state.dart';
import '../../models/material/material_info_for_business.dart';

class DispatchApplicationPage extends StatelessWidget {
  final MaterialInfoForBusiness materials;

  const DispatchApplicationPage({super.key, required this.materials});

  @override
  Widget build(BuildContext context) {
    // BlocProvider is now handled by the router, so we just return the view.
    return DispatchApplicationView(materials: materials);
  }
}

class DispatchApplicationView extends StatefulWidget {
  final MaterialInfoForBusiness materials;
  const DispatchApplicationView({super.key, required this.materials});

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
    context.read<DispatchBloc>().add(
      LoadApplicationData(
        widget.materials.normals
            .map(
              (e) => MaterialVO(
                materialId: e.baseInfo.materialId,
                materialName: e.baseInfo.prodNm ?? '',
              ),
            )
            .toList(),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调拨申请'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to dispatch records page
            },
            child: const Text('调拨记录'),
          ),
        ],
      ),
      body: BlocConsumer<DispatchBloc, DispatchState>(
        listener: (context, state) {
          if (state.status == DispatchStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '操作失败')),
              );
          } else if (state.status == DispatchStatus.applySuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('调拨申请提交成功！')));
            // Pop twice to go back to the page before qr_scan_page
            Navigator.of(context)
              ..pop()
              ..pop();
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
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaterialList(widget.materials),
            const SizedBox(height: 24),
            _buildForm(context, state),
            const SizedBox(height: 24),
            _buildActionButtons(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(MaterialInfoForBusiness materials) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              '一管一码',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: materials.normals.length,
            itemBuilder: (context, index) {
              final material = materials.normals[index];
              return ListTile(
                title: Text(material.baseInfo.prodNm ?? '未知材料'),
                trailing: const Text('1个'),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, DispatchState state) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );

    final userState = context.read<UserBloc>().state as UserLoaded;
    final userName = userState.wxLoginVO.name;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('出库方项目:', state.sourceProject?.name ?? '加载中...'),
            const Divider(height: 24),
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
            const Divider(height: 24),
            _buildInfoRow(
              '发出仓库:',
              '${state.sourceWarehouse?.name ?? "加载中..."} - ${state.sourceWarehouse?.address ?? ""}',
            ),
            const Divider(height: 24),
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
            const Divider(height: 24),
            // Assuming borrower is the current user, replace with actual logic
            _buildInfoRow('借货人:', userName), // Placeholder
            const Divider(height: 24),
            Text('接收仓库负责人:', style: labelStyle),
            const SizedBox(height: 8),
            _buildWarehouseUserList(state.availableWarehouseUsers),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
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
      return const Text('没有可用的仓库负责人');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return CheckboxListTile(
          title: Text('${user.name} - ${user.phone}'),
          value: _selectedManagerIds.contains(user.userId),
          onChanged: (bool? selected) {
            setState(() {
              if (selected == true) {
                _selectedManagerIds.add(user.userId);
              } else {
                _selectedManagerIds.remove(user.userId);
              }
            });
          },
          secondary: const Text('推送'),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, DispatchState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanMoreMaterials(context),
            label: const Text('扫码调拨'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (state.status == DispatchStatus.loading ||
                        state.status == DispatchStatus.loadingSourceInfo)
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('提交'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('返回'),
              ),
            ),
          ],
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
      materialList: widget.materials.normals
          .map(
            (m) => MaterialVO(
              materialId: m.baseInfo.materialId,
              materialName: m.baseInfo.prodNm ?? '未知材料',
              num: 1,
            ),
          )
          .toList(),
      messageTo: _selectedManagerIds,
      imageList: [], // Assuming no images are attached for now
    );

    context.read<DispatchBloc>().add(SubmitDispatchApplication(request));
  }

  Future<void> _scanMoreMaterials(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );
    final currentList = context.read<DispatchBloc>().state.materialList ?? [];
    final currentCodes = currentList.map((m) => m.materialName).toList();
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: currentCodes,
      scanType: QrScanType.materialInbound,
      batch: true,
      title: '追加调拨物料',
      context: const {'source': 'dispatchApplication'},
    );
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    final res = flow.normalize(request, raw);
    if (!mounted) return;
    if (res.addedCodes.isEmpty) {
      if (res.duplicates.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('全部为重复物料, 未追加')));
      }
      return;
    }
    // 暂无物料详情接口支持，这里仅以二维码字符串构造占位 MaterialVO
    final newMaterials = res.addedCodes.map(
      (c) => MaterialVO(materialId: 0, materialName: c),
    );
    final bloc = context.read<DispatchBloc>();
    final updated = [...(bloc.state.materialList ?? []), ...newMaterials];
    bloc.add(UpdateApplicationMaterialList(updated as List<MaterialVO>));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已追加 ${res.addedCodes.length} 个物料')));
  }
}
