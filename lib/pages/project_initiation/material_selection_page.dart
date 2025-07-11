/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:05:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/material_selection_cubit.dart';
import '../../models/project/project_initiation.dart' as project_models;
import '../../utils/toast_utils.dart';

/// 添加耗材页面
class MaterialSelectionPage extends StatefulWidget {
  final List<project_models.ProjectMaterial>? existingMaterials;
  final String? remarks;

  const MaterialSelectionPage({
    super.key,
    this.existingMaterials,
    this.remarks,
  });

  @override
  State<MaterialSelectionPage> createState() => _MaterialSelectionPageState();
}

class _MaterialSelectionPageState extends State<MaterialSelectionPage> {
  final _materialNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _remarksController = TextEditingController();
  
  project_models.MaterialType _selectedMaterialType = project_models.MaterialType.pipe;
  
  @override
  void initState() {
    super.initState();
    _remarksController.text = widget.remarks ?? '';
    // 初始化耗材选择
    context.read<MaterialSelectionCubit>().initializeMaterialSelection(
      existingMaterials: widget.existingMaterials,
      remarks: widget.remarks,
    );
  }

  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一管一码'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<MaterialSelectionCubit, MaterialSelectionState>(
        listener: (context, state) {
          if (state is MaterialSelectionSuccess) {
            context.pop(state.selectedMaterials);
          } else if (state is MaterialSelectionError) {
            context.showErrorToast(state.message);
          }
        },
        builder: (context, state) {
          if (state is MaterialSelectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is MaterialSelectionLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMaterialInputSection(),
                  const SizedBox(height: 24),
                  _buildSelectedMaterialsList(state.selectedMaterials),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildRemarksSection(),
                  const SizedBox(height: 32),
                  _buildBottomButtons(),
                ],
              ),
            );
          }
          
          return const Center(child: Text('加载失败'));
        },
      ),
    );
  }

  /// 物料输入部分
  Widget _buildMaterialInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputRow('耗材大类：', _buildMaterialTypeDropdown()),
        const SizedBox(height: 16),
        _buildInputRow('材料名称：', _buildMaterialNameInput()),
        const SizedBox(height: 16),
        _buildInputRow('数量：', _buildQuantityInput()),
      ],
    );
  }

  /// 物料类型下拉框
  Widget _buildMaterialTypeDropdown() {
    return DropdownButtonFormField<project_models.MaterialType>(
      value: _selectedMaterialType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: project_models.MaterialType.values.map((project_models.MaterialType type) {
        return DropdownMenuItem<project_models.MaterialType>(
          value: type,
          child: Row(
            children: [
              Text(type.label),
              if (type == project_models.MaterialType.pipe) // 显示选中状态
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, color: Colors.blue, size: 16),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (project_models.MaterialType? value) {
        setState(() {
          _selectedMaterialType = value ?? project_models.MaterialType.pipe;
        });
      },
    );
  }

  /// 物料名称输入框
  Widget _buildMaterialNameInput() {
    return TextFormField(
      controller: _materialNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// 数量输入框
  Widget _buildQuantityInput() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
    );
  }

  /// 已选择物料列表
  Widget _buildSelectedMaterialsList(List<project_models.ProjectMaterial> materials) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '已选择物料：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (materials.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '暂无选择的物料',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '物料名称',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '类型',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '数量',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 60),
                    ],
                  ),
                ),
                ...materials.asMap().entries.map((entry) {
                  final index = entry.key;
                  final material = entry.value;
                  return _buildMaterialRow(material, index);
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }

  /// 物料行
  Widget _buildMaterialRow(project_models.ProjectMaterial material, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              material.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              material.typeName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${material.needNum}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: () => _removeMaterial(index),
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _addMaterial,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('添加'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _importMaterials,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('导入'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _downloadTemplate,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('下载模板'),
          ),
        ),
      ],
    );
  }

  /// 备注部分
  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '备注：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _remarksController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (value) {
            context.read<MaterialSelectionCubit>().updateRemarks(value);
          },
        ),
      ],
    );
  }

  /// 底部按钮
  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('确认'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('返回'),
          ),
        ),
      ],
    );
  }

  /// 构建输入行
  Widget _buildInputRow(String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  /// 添加物料
  void _addMaterial() {
    if (_materialNameController.text.isEmpty) {
      context.showErrorToast('请输入材料名称');
      return;
    }
    
    final quantityText = _quantityController.text;
    if (quantityText.isEmpty) {
      context.showErrorToast('请输入数量');
      return;
    }
    
    final quantity = int.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      context.showErrorToast('请输入有效的数量');
      return;
    }
    
    final material = project_models.ProjectMaterial(
      name: _materialNameController.text,
      type: _selectedMaterialType.value,
      typeName: _selectedMaterialType.label,
      needNum: quantity,
    );
    
    context.read<MaterialSelectionCubit>().addMaterial(material);
    
    // 清空输入框
    _materialNameController.clear();
    _quantityController.clear();
    
    context.showSuccessToast('物料添加成功');
  }

  /// 移除物料
  void _removeMaterial(int index) {
    context.read<MaterialSelectionCubit>().removeMaterial(index);
    context.showSuccessToast('物料移除成功');
  }

  /// 导入物料
  void _importMaterials() {
    // 模拟文件选择和导入
    context.read<MaterialSelectionCubit>().importMaterialsFromFile('');
    context.showInfoToast('导入功能待实现');
  }

  /// 下载模板
  void _downloadTemplate() {
    context.read<MaterialSelectionCubit>().downloadTemplate();
    context.showInfoToast('模板下载功能待实现');
  }

  /// 确认选择
  void _confirmSelection() {
    final cubit = context.read<MaterialSelectionCubit>();
    if (cubit.validateMaterials()) {
      cubit.confirmSelection();
    } else {
      context.showErrorToast('请至少选择一个物料');
    }
  }
}