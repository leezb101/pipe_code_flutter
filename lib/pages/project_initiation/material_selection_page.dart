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
      backgroundColor: Colors.grey[50],
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
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMaterialInputSection(),
                        const SizedBox(height: 16),
                        _buildSelectedMaterialsList(state.selectedMaterials),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        _buildRemarksSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            );
          }
          
          return const Center(child: Text('加载失败'));
        },
      ),
    );
  }

  /// 物料输入部分
  Widget _buildMaterialInputSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_box,
                  size: 24,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  '添加物料',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField('耗材大类', _buildMaterialTypeDropdown()),
            const SizedBox(height: 16),
            _buildFormField('材料名称', _buildMaterialNameInput()),
            const SizedBox(height: 16),
            _buildFormField('数量', _buildQuantityInput()),
          ],
        ),
      ),
    );
  }

  /// 物料类型下拉框
  Widget _buildMaterialTypeDropdown() {
    return DropdownButtonFormField<project_models.MaterialType>(
      value: _selectedMaterialType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: project_models.MaterialType.values.map((project_models.MaterialType type) {
        return DropdownMenuItem<project_models.MaterialType>(
          value: type,
          child: Row(
            children: [
              Icon(
                _getMaterialTypeIcon(type),
                size: 18,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(type.label),
              if (type == _selectedMaterialType)
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
      decoration: InputDecoration(
        hintText: '请输入材料名称',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.engineering, size: 20),
      ),
    );
  }

  /// 数量输入框
  Widget _buildQuantityInput() {
    return TextFormField(
      controller: _quantityController,
      decoration: InputDecoration(
        hintText: '请输入数量',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.format_list_numbered, size: 20),
      ),
      keyboardType: TextInputType.number,
    );
  }

  /// 已选择物料列表
  Widget _buildSelectedMaterialsList(List<project_models.ProjectMaterial> materials) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 24,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  '已选择物料',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${materials.length}项',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (materials.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无选择的物料',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...materials.asMap().entries.map((entry) {
                final index = entry.key;
                final material = entry.value;
                return _buildMaterialCard(material, index);
              }),
          ],
        ),
      ),
    );
  }

  /// 物料卡片
  Widget _buildMaterialCard(project_models.ProjectMaterial material, int index) {
    final materialType = project_models.MaterialType.values.firstWhere(
      (type) => type.value == material.type,
      orElse: () => project_models.MaterialType.pipe,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getMaterialTypeIcon(materialType),
              size: 18,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      material.typeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${material.needNum}件',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeMaterial(index),
            icon: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red[50],
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build,
                  size: 24,
                  color: Colors.orange[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  '操作工具',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addMaterial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('添加', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importMaterials,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      side: BorderSide(color: Colors.green[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text('导入', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadTemplate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[600],
                      side: BorderSide(color: Colors.purple[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('模板', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 备注部分
  Widget _buildRemarksSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  size: 24,
                  color: Colors.indigo[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  '备注信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '请输入备注信息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                context.read<MaterialSelectionCubit>().updateRemarks(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 底部按钮
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '确认选择',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '返回',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建表单字段
  Widget _buildFormField(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// 获取物料类型图标
  IconData _getMaterialTypeIcon(project_models.MaterialType type) {
    switch (type) {
      case project_models.MaterialType.pipe:
        return Icons.water;
      case project_models.MaterialType.fitting:
        return Icons.settings;
      case project_models.MaterialType.equipment:
        return Icons.build_circle;
    }
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