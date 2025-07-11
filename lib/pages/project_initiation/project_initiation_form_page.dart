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
import '../../bloc/project_initiation/project_initiation_bloc.dart';
import '../../models/project/project_initiation.dart';
import '../../utils/toast_utils.dart';
import '../../widgets/project_initiation/project_user_selector.dart';
import '../../widgets/project_initiation/material_summary_widget.dart';

/// 立项表单页面
class ProjectInitiationFormPage extends StatefulWidget {
  final int? projectId; // 为空表示新建，有值表示编辑

  const ProjectInitiationFormPage({
    super.key,
    this.projectId,
  });

  @override
  State<ProjectInitiationFormPage> createState() => _ProjectInitiationFormPageState();
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
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProjectInfoSection(),
                    const SizedBox(height: 24),
                    _buildDateSection(),
                    const SizedBox(height: 24),
                    _buildDocumentSection(),
                    const SizedBox(height: 24),
                    _buildResponsiblePersonSection(),
                    const SizedBox(height: 24),
                    _buildSupplyTypeSection(),
                    const SizedBox(height: 24),
                    _buildSupplierSection(),
                    const SizedBox(height: 24),
                    _buildParticipantSection(),
                    const SizedBox(height: 24),
                    _buildMaterialSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            );
          }
          
          return const Center(child: Text('加载失败'));
        },
      ),
    );
  }

  /// 项目信息部分
  Widget _buildProjectInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('工程名称：'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _projectNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入工程名称';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('工程编号：'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _projectCodeController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入工程编号';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 工期部分
  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('工期：'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _startDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择开始日期';
                  }
                  return null;
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('至'),
            ),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _endDateController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择结束日期';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 文档上传部分
  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentUploadRow('立项报告：', 'XXXXX项目立项报告.pdf'),
        const SizedBox(height: 16),
        _buildDocumentUploadRow('招标文件：', 'XXXXX招标文件.pdf'),
        const SizedBox(height: 16),
        _buildDocumentUploadRow('中标文件：', 'XXXXX中标文件.pdf'),
        const SizedBox(height: 16),
        _buildDocumentUploadRow('其他附件：', 'XXXXX项目规划.pdf'),
      ],
    );
  }

  /// 负责人部分
  Widget _buildResponsiblePersonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('负责人：'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _responsiblePersonController.text.isNotEmpty ? _responsiblePersonController.text : null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  /// 供材类型部分
  Widget _buildSupplyTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('甲乙供材：'),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedSupplyType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  /// 供货厂商部分
  Widget _buildSupplierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('供货厂商：'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSupplier,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  /// 参与方部分
  Widget _buildParticipantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  /// 物料部分
  Widget _buildMaterialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaterialSummaryWidget(
          materials: _currentProject?.materialList ?? [],
          onAddMaterial: _navigateToMaterialSelection,
        ),
      ],
    );
  }

  /// 操作按钮部分
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _addMaterial,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('添加耗材'),
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProject,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('提交'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _commitProject,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                ),
                child: const Text('立项'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// 构建文档上传行
  Widget _buildDocumentUploadRow(String title, String fileName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            fileName,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        OutlinedButton(
          onPressed: () => _uploadDocument(title),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('上传附件'),
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
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
    context.push('/project-initiation/material-selection').then((result) {
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
        context.read<ProjectInitiationBloc>().add(SaveProjectDraft(project: project));
      } else {
        context.read<ProjectInitiationBloc>().add(UpdateProjectDraft(project: project));
      }
    }
  }

  /// 立项
  void _commitProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final project = _buildProjectFromForm();
      context.read<ProjectInitiationBloc>().add(CommitProject(project: project));
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