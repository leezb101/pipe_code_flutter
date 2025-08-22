/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/recovery/recovery.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// Recovery回收页面
/// 实现供应商选择 → 材料分类选择 → 材料类型选择 → 动态表单填写的完整流程
class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<RecoveryBloc>()..add(const RecoveryInitialized()),
      child: const RecoveryView(),
    );
  }
}

class RecoveryView extends StatefulWidget {
  const RecoveryView({super.key});

  @override
  State<RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends State<RecoveryView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // 清理所有控制器
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('材料回收'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocConsumer<RecoveryBloc, RecoveryState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
    );
  }

  /// 处理状态变化
  void _handleStateChanges(BuildContext context, RecoveryState state) {
    // 检查各种状态中的错误信息
    String? errorMessage;
    if (state is RecoveryVendorsLoaded && state.errorMessage != null) {
      errorMessage = state.errorMessage;
    } else if (state is RecoveryCategoriesLoaded &&
        state.errorMessage != null) {
      errorMessage = state.errorMessage;
    } else if (state is RecoveryTypesLoaded && state.errorMessage != null) {
      errorMessage = state.errorMessage;
    } else if (state is RecoveryFormReady && state.errorMessage != null) {
      errorMessage = state.errorMessage;
    } else if (state is RecoverySubmitting && state.errorMessage != null) {
      errorMessage = state.errorMessage;
    }

    // 显示错误信息并清除
    if (errorMessage != null) {
      ToastUtils.showError(context, errorMessage);
      // 清除错误信息
      context.read<RecoveryBloc>().add(const RecoveryErrorMessageCleared());
    }

    if (state is RecoverySubmissionSuccess) {
      ToastUtils.showSuccess(context, state.message);
      // 延迟导航，让用户看到成功提示
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      });
    } else if (state is RecoveryValidationError) {
      ToastUtils.showWarning(context, '请检查表单输入');
    } else if (state is RecoveryFormReady) {
      // 当表单准备就绪时，确保所有字段都有对应的控制器
      _ensureControllersForFields(state.formFields);
    }
  }

  /// 确保所有表单字段都有对应的控制器
  void _ensureControllersForFields(List<RetrieveBack> fields) {
    for (final field in fields) {
      if (!_controllers.containsKey(field.key)) {
        _controllers[field.key] = TextEditingController(text: field.value);
      }
    }

    // 清理不再需要的控制器
    final currentKeys = fields.map((f) => f.key).toSet();
    final controllersToRemove = _controllers.keys
        .where((key) => !currentKeys.contains(key))
        .toList();

    for (final key in controllersToRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
    }
  }

  /// 构建页面内容
  Widget _buildContent(BuildContext context, RecoveryState state) {
    if (state is RecoveryInitial || state is RecoveryLoading) {
      return _buildLoadingView(state);
    }

    return _buildMainContent(context, state);
  }

  /// 构建加载视图
  Widget _buildLoadingView(RecoveryState state) {
    final message = state is RecoveryLoading ? state.message : '正在初始化...';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message ?? '正在加载...', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(BuildContext context, RecoveryState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSelectionCard(context, state),
            const SizedBox(height: 16),
            if (state is RecoveryFormReady) ...[
              _buildDynamicFormCard(context, state),
              const SizedBox(height: 16),
              _buildScanButton(context),
              const SizedBox(height: 24),
              _buildActionButtons(context, state),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建选择卡片（供应商、分类、类型）
  Widget _buildSelectionCard(BuildContext context, RecoveryState state) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 制造厂家选择
            _buildVendorDropdown(context, state),
            const SizedBox(height: 16),

            // 材料大类选择
            if (state is RecoveryCategoriesLoaded ||
                state is RecoveryTypesLoaded ||
                state is RecoveryFormReady) ...[
              _buildCategoryDropdown(context, state),
              const SizedBox(height: 16),
            ],

            // 材料类型选择
            if (state is RecoveryTypesLoaded || state is RecoveryFormReady) ...[
              _buildTypeDropdown(context, state),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建供应商下拉选择框
  Widget _buildVendorDropdown(BuildContext context, RecoveryState state) {
    List<VendorOption> vendorOptions = [];
    VendorOption? selectedVendor;

    if (state is RecoveryVendorsLoaded) {
      vendorOptions = state.vendorOptions;
      selectedVendor = state.selectedVendor;
    } else if (state is RecoveryCategoriesLoaded) {
      vendorOptions = state.vendorOptions;
      selectedVendor = state.selectedVendor;
    } else if (state is RecoveryTypesLoaded) {
      vendorOptions = state.vendorOptions;
      selectedVendor = state.selectedVendor;
    } else if (state is RecoveryFormReady) {
      vendorOptions = state.vendorOptions;
      selectedVendor = state.selectedVendor;
    }

    return DropdownButtonFormField<VendorOption>(
      value: selectedVendor,
      items: vendorOptions.map((vendor) {
        return DropdownMenuItem(value: vendor, child: Text(vendor.name));
      }).toList(),
      onChanged: (VendorOption? value) {
        if (value != null) {
          context.read<RecoveryBloc>().add(
            RecoveryVendorSelected(vendorCode: value.code),
          );
        }
      },
      decoration: const InputDecoration(
        labelText: '制造厂家',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) => value == null ? '请选择制造厂家' : null,
    );
  }

  /// 构建材料分类下拉选择框
  Widget _buildCategoryDropdown(BuildContext context, RecoveryState state) {
    List<MaterialCategoryOption> categoryOptions = [];
    MaterialCategoryOption? selectedCategory;

    if (state is RecoveryCategoriesLoaded) {
      categoryOptions = state.categoryOptions;
    } else if (state is RecoveryTypesLoaded) {
      categoryOptions = state.categoryOptions;
      selectedCategory = state.selectedCategory;
    } else if (state is RecoveryFormReady) {
      categoryOptions = state.categoryOptions;
      selectedCategory = state.selectedCategory;
    }

    return DropdownButtonFormField<MaterialCategoryOption>(
      value: selectedCategory,
      items: categoryOptions.map((category) {
        return DropdownMenuItem(value: category, child: Text(category.name));
      }).toList(),
      onChanged: (MaterialCategoryOption? value) {
        if (value != null) {
          context.read<RecoveryBloc>().add(
            RecoveryCategorySelected(categoryGroup: value.group),
          );
        }
      },
      decoration: const InputDecoration(
        labelText: '材料大类',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) => value == null ? '请选择材料大类' : null,
    );
  }

  /// 构建材料类型下拉选择框
  Widget _buildTypeDropdown(BuildContext context, RecoveryState state) {
    List<MaterialTypeOption> typeOptions = [];
    MaterialTypeOption? selectedType;

    if (state is RecoveryTypesLoaded) {
      typeOptions = state.typeOptions;
    } else if (state is RecoveryFormReady) {
      typeOptions = state.typeOptions;
      selectedType = state.selectedType;
    }

    return DropdownButtonFormField<MaterialTypeOption>(
      value: selectedType,
      items: typeOptions.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.name));
      }).toList(),
      onChanged: (MaterialTypeOption? value) {
        if (value != null) {
          context.read<RecoveryBloc>().add(
            RecoveryMaterialTypeSelected(materialType: value.type),
          );
        }
      },
      decoration: const InputDecoration(
        labelText: '材料',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) => value == null ? '请选择材料类型' : null,
    );
  }

  /// 构建动态表单卡片
  Widget _buildDynamicFormCard(BuildContext context, RecoveryFormReady state) {
    if (state.formFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '材料属性',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...state.formFields.map(
              (field) => _buildDynamicField(context, state, field),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建动态表单字段
  Widget _buildDynamicField(
    BuildContext context,
    RecoveryFormReady state,
    RetrieveBack field,
  ) {
    final controller =
        _controllers[field.key] ?? TextEditingController(text: field.value);
    if (!_controllers.containsKey(field.key)) {
      _controllers[field.key] = controller;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: field.name,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          errorText: state.fieldErrors[field.key],
        ),
        onChanged: (value) {
          context.read<RecoveryBloc>().add(
            RecoveryFormFieldChanged(fieldKey: field.key, value: value),
          );
        },
        validator: (value) {
          // 这里可以根据字段类型添加不同的验证逻辑
          if (field.key.contains('必填') &&
              (value == null || value.trim().isEmpty)) {
            return '该字段为必填项';
          }
          return null;
        },
      ),
    );
  }

  /// 构建扫描按钮
  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _handleScanQRCode(context),
        icon: const Icon(Icons.qr_code_scanner, size: 28),
        label: const Text('扫描备用码', style: TextStyle(fontSize: 18)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }

  /// 处理扫描二维码
  Future<void> _handleScanQRCode(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );

    // 创建扫描配置
    final request = QrScanFlowRequest(
      operation: QrScanOperation.initial,
      currentCodes: const [],
      batch: false,
      title: '扫描补充码',
      context: const {'source': 'recovery_page', 'entry': 'embedded'},
    );

    // 导航到扫描页面
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    final res = flow.normalize(request, raw);
    if (res.rawResults.isEmpty) return;
    if (!context.mounted) return;
    // 记录扫描结果，待后续提交时提交到服务端
    // FIXME: 这里还有问题
    context.read<RecoveryBloc>().add(
      RecoveryFormFieldChanged(
        fieldKey: '扫描结果',
        value: res.rawResults.first.code,
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context, RecoveryFormReady state) {
    final isSubmitting = state is RecoverySubmitting;
    final isValidating = state.isValidating;

    return Row(
      children: [
        // 取消按钮
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting || isValidating
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: const Text('取消'),
          ),
        ),
        const SizedBox(width: 16),
        // 确定按钮
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting || isValidating
                ? null
                : () {
                    _handleSubmit(context);
                  },
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('确定'),
          ),
        ),
      ],
    );
  }

  /// 处理表单提交
  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RecoveryBloc>().add(const RecoveryFormSubmitted());
    } else {
      ToastUtils.showWarning(context, '请完善表单信息');
    }
  }
}
