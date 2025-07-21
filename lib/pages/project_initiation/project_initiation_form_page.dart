/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:05:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-11 17:49:53
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/project_initiation/project_initiation_bloc.dart';
import '../../models/project/project_initiation.dart';
import '../../utils/toast_utils.dart';
import '../../widgets/project_initiation/project_user_selector.dart';
import '../../widgets/project_initiation/material_summary_widget.dart';

/// 立项表单页面
class ProjectInitiationFormPage extends StatefulWidget {
  final int? projectId; // 为空表示新建，有值表示编辑

  const ProjectInitiationFormPage({super.key, this.projectId});

  @override
  State<ProjectInitiationFormPage> createState() =>
      _ProjectInitiationFormPageState();
}

class _ProjectInitiationFormPageState extends State<ProjectInitiationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _projectCodeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _responsiblePersonController = TextEditingController();

  int _selectedSupplyType = 0;
  String? _selectedSupplier;

  ProjectInitiation? _currentProject;

  @override
  void initState() {
    super.initState();
    // 加载表单数据
    context.read<ProjectInitiationBloc>().add(
      LoadProjectInitiationForm(projectId: widget.projectId),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectCodeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _responsiblePersonController.dispose();
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
      body: BlocConsumer<ProjectInitiationBloc, ProjectInitiationState>(
        listener: (context, state) {
          if (state is ProjectInitiationSuccess) {
            context.showSuccessToast(state.message);
            context.pop();
          } else if (state is ProjectInitiationError) {
            context.showErrorToast(state.message);
          }
        },
        builder: (context, state) {
          if (state is ProjectInitiationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectInitiationFormLoaded) {
            _currentProject = state.project;
            _updateFormFields(state.project);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProjectInfoSection(),
                          const SizedBox(height: 16),
                          _buildDateSection(),
                          const SizedBox(height: 16),
                          _buildDocumentSection(),
                          const SizedBox(height: 16),
                          _buildResponsiblePersonSection(),
                          const SizedBox(height: 16),
                          _buildSupplyTypeSection(),
                          const SizedBox(height: 16),
                          _buildSupplierSection(),
                          const SizedBox(height: 16),
                          _buildParticipantSection(),
                          const SizedBox(height: 16),
                          _buildMaterialSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            );
          }

          return const Center(child: Text('加载失败'));
        },
      ),
    );
  }

  /// 项目信息部分
  Widget _buildProjectInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '项目信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField('工程名称', _projectNameController, '请输入工程名称'),
            const SizedBox(height: 16),
            _buildFormField('工程编号', _projectCodeController, '请输入工程编号'),
          ],
        ),
      ),
    );
  }

  /// 工期部分
  Widget _buildDateSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '工期',
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
                  child: _buildDateField(
                    '开始日期',
                    _startDateController,
                    '请选择开始日期',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text(
                    '至',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildDateField('结束日期', _endDateController, '请选择结束日期'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 文档上传部分
  Widget _buildDocumentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  '文档附件',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDocumentUploadRow('立项报告', 'XXXXX项目立项报告.pdf'),
            const SizedBox(height: 12),
            _buildDocumentUploadRow('招标文件', 'XXXXX招标文件.pdf'),
            const SizedBox(height: 12),
            _buildDocumentUploadRow('中标文件', 'XXXXX中标文件.pdf'),
            const SizedBox(height: 12),
            _buildDocumentUploadRow('其他附件', 'XXXXX项目规划.pdf'),
          ],
        ),
      ),
    );
  }

  /// 负责人部分
  Widget _buildResponsiblePersonSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 24, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '负责人',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _responsiblePersonController.text.isNotEmpty
                  ? _responsiblePersonController.text
                  : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: ['孙博', '李四', '王五'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _responsiblePersonController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择负责人';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 供材类型部分
  Widget _buildSupplyTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, size: 24, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                const Text(
                  '甲乙供材',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedSupplyType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: SupplyType.values.map((SupplyType type) {
                return DropdownMenuItem<int>(
                  value: type.value,
                  child: Text(type.label),
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  _selectedSupplyType = value ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 供货厂商部分
  Widget _buildSupplierSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business_center, size: 24, color: Colors.teal[600]),
                const SizedBox(width: 8),
                const Text(
                  '供货厂商',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSupplier,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: ['XXXX供应商', '华润水泥供应商', '中建钢材供应商'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedSupplier = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 参与方部分
  Widget _buildParticipantSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, size: 24, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text(
                  '参与方管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProjectUserSelector(
              title: '监理方：',
              users: _currentProject?.supervisorUserList ?? [],
              onAddUser: () => _addUser('supervisor'),
              onRemoveUser: (index) => _removeUser('supervisor', index),
            ),
            const SizedBox(height: 16),
            ProjectUserSelector(
              title: '施工方：',
              users: _currentProject?.builderUserList ?? [],
              onAddUser: () => _addUser('builder'),
              onRemoveUser: (index) => _removeUser('builder', index),
            ),
          ],
        ),
      ),
    );
  }

  /// 物料部分
  Widget _buildMaterialSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '材料清单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MaterialSummaryWidget(
              materials: _currentProject?.materialList ?? [],
              onAddMaterial: _navigateToMaterialSelection,
            ),
          ],
        ),
      ),
    );
  }

  /// 操作按钮部分
  Widget _buildActionButtons() {
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addMaterial,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      side: BorderSide(color: Colors.blue[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '添加耗材',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _commitProject,
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
                      '提交',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文档上传行
  Widget _buildDocumentUploadRow(String title, String fileName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.description, size: 18, color: Colors.orange[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _uploadDocument(title),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange[600],
              side: BorderSide(color: Colors.orange[600]!),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '上传附件',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建表单字段
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hintText,
  ) {
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
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return hintText;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 构建日期字段
  Widget _buildDateField(
    String label,
    TextEditingController controller,
    String hintText,
  ) {
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
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return hintText;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 更新表单字段
  void _updateFormFields(ProjectInitiation project) {
    if (_projectNameController.text.isEmpty) {
      _projectNameController.text = project.projectName;
    }
    if (_projectCodeController.text.isEmpty) {
      _projectCodeController.text = project.projectCode;
    }
    if (_startDateController.text.isEmpty) {
      _startDateController.text = project.projectStart;
    }
    if (_endDateController.text.isEmpty) {
      _endDateController.text = project.projectEnd;
    }

    _selectedSupplyType = project.supplyType;
  }

  /// 选择日期
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  /// 上传文档
  void _uploadDocument(String documentType) {
    // 实现文档上传逻辑
    context.showInfoToast('上传$documentType功能待实现');
  }

  /// 添加用户
  void _addUser(String userType) {
    // 实现添加用户逻辑
    context.showInfoToast('添加${userType}用户功能待实现');
  }

  /// 移除用户
  void _removeUser(String userType, int index) {
    context.read<ProjectInitiationBloc>().add(
      RemoveUserFromProject(index: index, userType: userType),
    );
  }

  /// 添加物料
  void _addMaterial() {
    _navigateToMaterialSelection();
  }

  /// 导航到物料选择页面
  void _navigateToMaterialSelection() {
    context.pushNamed('material-selection').then((result) {
      if (result != null && result is List<ProjectMaterial>) {
        context.read<ProjectInitiationBloc>().add(
          AddMaterialToProject(materials: result),
        );
      }
    });
  }

  /// 保存项目
  void _saveProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = _buildProjectFromForm();
      if (widget.projectId == null) {
        context.read<ProjectInitiationBloc>().add(
          SaveProjectDraft(project: project),
        );
      } else {
        context.read<ProjectInitiationBloc>().add(
          UpdateProjectDraft(project: project),
        );
      }
    }
  }

  /// 立项
  void _commitProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = _buildProjectFromForm();
      context.read<ProjectInitiationBloc>().add(
        CommitProject(project: project),
      );
    }
  }

  /// 从表单构建项目对象
  ProjectInitiation _buildProjectFromForm() {
    return ProjectInitiation(
      id: widget.projectId,
      projectName: _projectNameController.text,
      projectCode: _projectCodeController.text,
      projectStart: _startDateController.text,
      projectEnd: _endDateController.text,
      supplyType: _selectedSupplyType,
      materialList: _currentProject?.materialList ?? [],
      constructionUserList: _currentProject?.constructionUserList ?? [],
      supervisorUserList: _currentProject?.supervisorUserList ?? [],
      builderUserList: _currentProject?.builderUserList ?? [],
    );
  }
}
