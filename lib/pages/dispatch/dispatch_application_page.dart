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
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation; // enum only
// QrScanType removed

import '../../bloc/user/user_state.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_components.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/utils/tracing_context_x.dart';
import 'package:rxdart/rxdart.dart';

// 可搜索下拉组件（类似 Element UI 的 el-select）
class _SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(T) itemBuilder;
  final String Function(T item)? selectedLabelBuilder;
  final String? errorMessage;
  final String businessType;
  final String Function(T item) getSearchText;

  const _SearchableDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.selectedLabelBuilder,
    this.errorMessage,
    required this.businessType,
    required this.getSearchText,
  }) : super(key: key);

  @override
  State<_SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>.seeded(
    '',
  );
  List<T> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _textController = TextEditingController(
      text: widget.value != null ? _getDisplayText(widget.value as T) : '',
    );

    // 设置防抖，600毫秒延迟
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 600))
        .listen((searchText) {
          _filterItems(searchText);
        });

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(_SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textController.text = widget.value != null
          ? _getDisplayText(widget.value as T)
          : '';
    }
    if (oldWidget.items != widget.items) {
      _filterItems(_textController.text);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      _showOverlay();
    } else if (!_focusNode.hasFocus && _isDropdownOpen) {
      _hideOverlay();
    }
  }

  String _getDisplayText(T item) {
    return widget.selectedLabelBuilder != null
        ? widget.selectedLabelBuilder!(item)
        : widget.getSearchText(item);
  }

  void _filterItems(String searchText) {
    if (!mounted) return;

    setState(() {
      if (searchText.isEmpty) {
        _filteredItems = widget.items;
      } else {
        final lowerSearch = searchText.toLowerCase();
        _filteredItems = widget.items.where((item) {
          final searchableText = widget.getSearchText(item).toLowerCase();
          return searchableText.contains(lowerSearch);
        }).toList();
      }
    });

    if (_isDropdownOpen) {
      _updateOverlay();
    }
  }

  void _showOverlay() {
    _isDropdownOpen = true;
    _filteredItems = widget.items;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;

    // 恢复显示已选择的值
    if (widget.value != null) {
      _textController.text = _getDisplayText(widget.value as T);
    }
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // 点击外部区域关闭下拉框
          _focusNode.unfocus();
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: GestureDetector(
                  onTap: () {
                    // 阻止事件冒泡，点击下拉列表内部不关闭
                  },
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _filteredItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '没有匹配的结果',
                                style: TextStyle(color: AppTheme.grey600),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = widget.value == item;
                                return InkWell(
                                  onTap: () {
                                    widget.onChanged(item);
                                    _textController.text = _getDisplayText(
                                      item,
                                    );
                                    _focusNode.unfocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.getBusinessColor(
                                              widget.businessType,
                                            ).withOpacity(0.1)
                                          : null,
                                      border: index < _filteredItems.length - 1
                                          ? Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[200]!,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: widget.itemBuilder(item),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: AppTheme.getBusinessColor(
                                              widget.businessType,
                                            ),
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    // 页面切换或组件被移出树时，确保关闭浮层
    if (_isDropdownOpen) {
      _hideOverlay();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _hideOverlay();
    _textController.dispose();
    _focusNode.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return Row(
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getBusinessColor(widget.businessType),
            ),
          ),
          SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: '输入关键词搜索或点击选择',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_textController.text.isNotEmpty && _focusNode.hasFocus)
                IconButton(
                  icon: Icon(Icons.clear, color: AppTheme.grey600, size: 20),
                  onPressed: () {
                    _textController.clear();
                    _searchSubject.add('');
                    widget.onChanged(null);
                  },
                ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: AppTheme.getBusinessColor(widget.businessType),
              ),
              SizedBox(width: 8),
            ],
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(
              color: AppTheme.getBusinessColor(widget.businessType),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // 更新清除按钮显示
          _searchSubject.add(value);
        },
        onTap: () {
          if (!_isDropdownOpen) {
            _showOverlay();
          }
        },
      ),
    );
  }
}

class DispatchApplicationPage extends StatelessWidget {
  // final MaterialInfoForBusiness materials;
  final List<String> initialCodes;

  const DispatchApplicationPage({super.key, required this.initialCodes});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DispatchBloc>(
      create: (context) => DispatchBloc(
        dispatchRepository: getIt<DispatchRepository>(),
        commonQueryApiService: getIt<CommonQueryApiService>(),
      ),
      child: _DispatchApplicationPageView(initialCodes: initialCodes),
    );
  }
}

class _DispatchApplicationPageView extends StatelessWidget {
  final List<String> initialCodes;

  const _DispatchApplicationPageView({required this.initialCodes});

  @override
  Widget build(BuildContext context) {
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
    super.initState();
    final codes = widget.initialCodes;
    final tracingContext = context.createActionContext('初始化物料信息');
    context.read<DispatchBloc>().add(
      InitializeMaterialsFromCodes(
        codes: codes,
        tracingContext: tracingContext,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调拨申请', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
        iconTheme: const IconThemeData(color: Colors.white),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       // TODO: Navigate to dispatch records page
        //     },
        //     style: TextButton.styleFrom(foregroundColor: Colors.white),
        //     child: const Text('调拨记录'),
        //   ),
        // ],
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

          // 当材料初始化成功后，自动加载申请数据
          if (state.status == DispatchStatus.success &&
              state.materialList != null &&
              state.materialList!.isNotEmpty &&
              state.sourceProject == null && // 确保还没有加载过申请数据
              state.availableProjects.isEmpty) {
            final tracingContext = context.createActionContext('获取项目和仓库信息');
            context.read<DispatchBloc>().add(
              LoadApplicationData(
                materials: state.materialList!,
                tracingContext: tracingContext,
              ),
            );
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
      child: BlocBuilder<DispatchBloc, DispatchState>(
        builder: (context, state) {
          if (materials.isEmpty && state.errorMaterials.isEmpty) {
            return Column(
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
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 正常材料列表
              if (materials.isNotEmpty) ...[
                ...materials
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
                          primaryText: entry.value.materialCode,
                          batchCode: entry.value.batchCode,
                          quantity: entry.value.num,
                          status: entry.value.status,
                          statusName: entry.value.statusName,
                          businessType: 'dispatch',
                        ),
                      ),
                    )
                    .toList(),
              ],

              // 错误材料区域
              if (state.errorMaterials.isNotEmpty) ...[
                if (materials.isNotEmpty)
                  const SizedBox(height: AppTheme.spacingMedium),
                ErrorMaterialSection(
                  errors: state.errorMaterials,
                  onErrorItemTap: _handleErrorMaterialTap,
                ),
              ],
            ],
          );
        },
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
          _buildInfoRowWithError(
            label: '出库方项目',
            value: state.sourceProject?.name,
            errorMessage: state.sourceProjectError,
            loadingText: '加载中...',
          ),
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
            itemBuilder: (item) => Text(item.name),
            selectedLabelBuilder: (item) => item.name,
            errorMessage: state.availableProjectsError,
            getSearchText: (item) => item.name,
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildInfoRowWithError(
            label: '发出仓库',
            value: state.sourceWarehouse != null
                ? '${state.sourceWarehouse!.name} - ${state.sourceWarehouse!.address}'
                : null,
            errorMessage: state.sourceWarehouseError,
            loadingText: '加载中...',
          ),
          SizedBox(height: AppTheme.spacingMedium),
          _buildDropdownRow<WarehouseVO>(
            label: '接收仓库:',
            value: _selectedTargetWarehouse,
            items: state.availableWarehouses,
            onChanged: (value) {
              if (value != null) {
                final tracingContext = context.createActionContext('获取仓库用户');
                context.read<DispatchBloc>().add(
                  UpdateWarehouseUsersList(
                    warehouseId: value.id,
                    tracingContext: tracingContext,
                  ),
                );
              }
              setState(() {
                _selectedTargetWarehouse = value;
              });
            },
            itemBuilder: (item) => Text('${item.name} - ${item.address}'),
            selectedLabelBuilder: (item) => '${item.name} - ${item.address}',
            errorMessage: state.availableWarehousesError,
            getSearchText: (item) => '${item.name} ${item.address}',
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
    required Widget Function(T) itemBuilder,
    String Function(T item)? selectedLabelBuilder,
    String? errorMessage,
    required String Function(T item) getSearchText,
  }) {
    return _SearchableDropdown<T>(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      itemBuilder: itemBuilder,
      selectedLabelBuilder: selectedLabelBuilder,
      errorMessage: errorMessage,
      businessType: 'dispatch',
      getSearchText: getSearchText,
    );
  }

  Widget _buildInfoRowWithError({
    required String label,
    required String? value,
    required String? errorMessage,
    required String loadingText,
  }) {
    if (errorMessage != null) {
      // 显示错误状态
      return Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: AppTheme.labelLarge)),
          SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            flex: 4,
            child: Text(
              errorMessage,
              style: AppTheme.bodyMedium.copyWith(color: Colors.red),
            ),
          ),
        ],
      );
    } else if (value != null) {
      // 显示正常数据
      return InfoRow(label: label, value: value);
    } else {
      // 显示加载状态
      return InfoRow(label: label, value: loadingText);
    }
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
                  '短信通知',
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

  /// 处理错误材料点击事件
  void _handleErrorMaterialTap(dynamic errorMaterial) {
    // 简单显示错误材料信息
    String errorInfo = '';
    try {
      if (errorMaterial is Map<String, dynamic>) {
        errorInfo =
            errorMaterial['errorMessage']?.toString() ??
            errorMaterial['error_message']?.toString() ??
            '异常材料信息';
      } else {
        errorInfo = '异常材料信息';
      }
    } catch (e) {
      errorInfo = '异常材料信息';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('异常材料详情'),
        content: Text(errorInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final state = context.read<DispatchBloc>().state;

    // 检查是否有错误材料，如有则显示确认对话框
    if (state.errorMaterials.isNotEmpty) {
      final shouldContinue = await _showErrorMaterialSubmitConfirmation(
        state.errorMaterials.length,
      );
      if (!shouldContinue) {
        return; // 用户取消提交
      }
    }

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

    final tracingContext = context.createActionContext('提交申请');
    context.read<DispatchBloc>().add(
      SubmitDispatchApplication(
        request: request,
        tracingContext: tracingContext,
      ),
    );
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
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.addedCodes.isEmpty || !context.mounted) return;

    final tracingContext = context.createActionContext('追加材料');
    context.read<DispatchBloc>().add(
      UpdateApplicationMaterialWithAppendCodes(
        appendingCodes: res.addedCodes,
        tracingContext: tracingContext,
      ),
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
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.removedCodes.isEmpty || !context.mounted) return;

    final tracingContext = context.createActionContext('移除材料');
    context.read<DispatchBloc>().add(
      UpdateApplicationMaterialWithRemoveCodes(
        removingCodes: res.removedCodes,
        tracingContext: tracingContext,
      ),
    );
  }

  /// 显示错误材料提交确认对话框
  Future<bool> _showErrorMaterialSubmitConfirmation(int errorCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SubmitConfirmationDialog(
        normalCount:
            context.read<DispatchBloc>().state.materialList?.length ?? 0,
        errorCount: errorCount,
        title: '调拨申请提交确认',
        businessType: 'dispatch',
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
    return result == true;
  }
}
