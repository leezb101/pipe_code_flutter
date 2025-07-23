/*
 * @Author: LeeZB
 * @Date: 2025-07-17 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 18:19:18
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/project/project_state.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import '../../bloc/project/project_bloc.dart';
import '../../models/inventory/pipe_material.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/common/warehouse_vo.dart';
import '../../models/material/material_info_base.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../widgets/file_upload/file_upload_widget.dart';
import '../../bloc/acceptance/acceptance_bloc.dart';
import '../../bloc/acceptance/acceptance_event.dart';
import '../../bloc/acceptance/acceptance_state.dart';
import '../../models/acceptance/do_accept_vo.dart';
import '../../models/acceptance/material_vo.dart';

class AcceptancePage extends StatefulWidget {
  const AcceptancePage({super.key, required this.materials});

  final MaterialInfoForBusiness materials;

  @override
  State<AcceptancePage> createState() => _AcceptancePageState();
}

class _AcceptancePageState extends State<AcceptancePage> {
  List<File> _acceptancePhotos = [];
  List<File> _inspectionReports = [];
  List<File> _acceptanceReports = [];

  // 仓库选择相关
  String _storageType = 'project'; // 'project' 或 'independent'
  String? _selectedWarehouse;
  int? _selectedWarehouseId;

  List<WarehouseVO> _warehouseList = [];

  // 用户列表相关
  List<CommonUserVO> _warehouseUsers = [];
  List<CommonUserVO> _supervisorUsers = [];
  List<CommonUserVO> _constructionUsers = [];

  // 推送选择状态
  Map<String, bool?> _userPushStates = {};

  @override
  void initState() {
    super.initState();
    // Load initial user data - using mock project and role IDs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load warehouse list first
      context.read<AcceptanceBloc>().add(const LoadWarehouseList());

      final projectId =
          (context.read<ProjectBloc>().state as ProjectRoleInfoLoaded)
              .currentProject
              .projectId;
      context.read<AcceptanceBloc>().add(
        LoadAcceptanceUsers(
          projectId: projectId,
          roleType: 1, // Example role type
        ),
      );
      context.read<AcceptanceBloc>().add(
        const LoadWarehouseUsers(
          warehouseId: 1000, // Use current warehouse ID
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcceptanceBloc, AcceptanceState>(
      listener: (context, state) {
        if (state is AcceptanceUsersLoaded) {
          setState(() {
            _supervisorUsers = state.acceptUserInfo.supervisorUsers;
            _constructionUsers = state.acceptUserInfo.constructionUsers;
            // Initialize push states
            for (var user in _supervisorUsers) {
              _userPushStates['supervisor_${user.name}'] = user.messageTo;
            }
            for (var user in _constructionUsers) {
              _userPushStates['construction_${user.name}'] = user.messageTo;
            }
          });
        } else if (state is WarehouseUsersLoaded) {
          setState(() {
            _warehouseUsers = state.warehouseUserInfo.warehouseUsers;
            // Initialize push states
            for (var user in _warehouseUsers) {
              _userPushStates['warehouse_${user.name}'] = user.messageTo;
            }
          });
        } else if (state is WarehouseListLoaded) {
          setState(() {
            _warehouseList = state.warehouseList;
            // Set default selection to first warehouse if available
            if (_warehouseList.isNotEmpty) {
              _selectedWarehouse = _warehouseList.first.name;
              _selectedWarehouseId = _warehouseList.first.id;

              // 如果当前是独立仓库模式，自动获取默认仓库的人员
              if (_storageType == 'independent') {
                context.read<AcceptanceBloc>().add(
                  LoadWarehouseUsers(warehouseId: _warehouseList.first.id),
                );
              }
            }
          });
        } else if (state is AcceptanceError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('一管一码'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '验收记录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMaterialsList(),
                    const SizedBox(height: 16),
                    _buildAttachmentSection(),
                    const SizedBox(height: 16),
                    _buildWarehouseSection(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
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
                Icon(Icons.inventory, size: 24, color: Colors.blue[600]),
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
            ...widget.materials.normals
                .map((material) => _buildMaterialItem(material))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfoBase material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.water_drop, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.prodNm ?? '无',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material.materialCode ?? '无',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '1个',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ImageUploadWidget(
              title: '验收照片',
              onImagesChanged: (images) {
                setState(() {
                  _acceptancePhotos = images;
                });
              },
              maxImages: 6,
            ),
            const SizedBox(height: 24),
            FileUploadWidget(
              title: '报验单',
              onFilesChanged: (files) {
                setState(() {
                  _inspectionReports = files;
                });
              },
              allowedExtensions: ['pdf', 'doc', 'docx'],
              maxFiles: 3,
            ),
            const SizedBox(height: 24),
            FileUploadWidget(
              title: '验收报告',
              onFilesChanged: (files) {
                setState(() {
                  _acceptanceReports = files;
                });
              },
              allowedExtensions: ['pdf', 'doc', 'docx'],
              maxFiles: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseSection() {
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
                Icon(Icons.warehouse, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  '仓库管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStorageTypeSelection(),
            if (_storageType == 'independent') ...[
              const SizedBox(height: 20),
              _buildWarehouseSelection(),
            ],
            const SizedBox(height: 20),
            if (_storageType == 'independent')
              _buildUserSection('仓库负责人', _warehouseUsers, 'warehouse'),
            if (_storageType == 'independent') const SizedBox(height: 20),
            _buildUserSection('监理方负责人', _supervisorUsers, 'supervisor'),
            const SizedBox(height: 20),
            _buildUserSection('建设方负责人', _constructionUsers, 'construction'),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageTypeSelection() {
    return Row(
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'project',
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                  // 切换回项目现场时清空仓库负责人列表
                  _warehouseUsers.clear();
                  // 清除相关的推送状态
                  _userPushStates.removeWhere(
                    (key, value) => key.startsWith('warehouse_'),
                  );
                });
              },
            ),
            const Text('项目现场', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(width: 32),
        Row(
          children: [
            Radio<String>(
              value: 'independent',
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                  // 切换到独立仓库时也清空仓库负责人列表（用户需要重新选择仓库）
                  _warehouseUsers.clear();
                  // 清除相关的推送状态
                  _userPushStates.removeWhere(
                    (key, value) => key.startsWith('warehouse_'),
                  );
                });

                // 如果已有选中的仓库，自动获取仓库人员
                if (_selectedWarehouseId != null) {
                  context.read<AcceptanceBloc>().add(
                    LoadWarehouseUsers(warehouseId: _selectedWarehouseId!),
                  );
                }
              },
            ),
            const Text('独立仓库', style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildWarehouseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择已有仓库：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedWarehouseId,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedWarehouse = _warehouseList
                      .firstWhere((w) => w.id == newValue)
                      .name;
                  _selectedWarehouseId = newValue!;
                });

                // 获取仓库用户
                if (newValue != null) {
                  context.read<AcceptanceBloc>().add(
                    LoadWarehouseUsers(warehouseId: newValue),
                  );
                }
              },
              items: _warehouseList.map<DropdownMenuItem<int>>((
                WarehouseVO warehouse,
              ) {
                return DropdownMenuItem<int>(
                  value: warehouse.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${warehouse.name} - ${warehouse.address}'),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSection(
    String title,
    List<CommonUserVO> users,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title：',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('暂无用户数据', style: TextStyle(color: Colors.grey)),
          )
        else
          ...users.map((user) => _buildUserItem(user, type)).toList(),
      ],
    );
  }

  Widget _buildUserItem(CommonUserVO user, String type) {
    final key = '${type}_${user.name}';
    final isSelected = _userPushStates[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _userPushStates[key] = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Text('推送', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

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
                  child: ElevatedButton(
                    onPressed: _handleScanAcceptance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '扫码验收',
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
                    onPressed: _handleSupplementReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '补录返告',
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
                  child: OutlinedButton(
                    onPressed: _handleProcessReturn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '处理退库',
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
                    onPressed: _handleConfirmAcceptance,
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
                      '验收确认',
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleReturn,
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

  void _handleViewRecords() {
    // Navigate to records page with acceptance tab selected
    context.go('/records?tab=accept');
  }

  void _handleScanAcceptance() {
    // 转换材料列表
    // final materialVOList = _convertPipeMaterialsToMaterialVOs(widget.materials);

    final materialVOList = widget.materials.normals
        .map(
          (e) => MaterialVO(
            materialId: e.materialId,
            materialName: e.prodNm ?? '',
          ),
        )
        .toList();

    // 获取选中的用户ID列表
    final selectedUserIds = _getSelectedUserIds();

    // 确定仓库类型：项目现场为false，独立仓库为true
    final realWarehouse = _storageType == 'independent';

    // 获取仓库ID，如果未选择则默认为0
    final warehouseId = _selectedWarehouseId ?? 0;

    // FIXME: 这里是测试用的假的materialVOList

    final materialVOListForTest = [
      MaterialVO(materialId: 1, materialName: "管材1"),
      MaterialVO(materialId: 2, materialName: "管材2"),
    ];
    // 创建DoAcceptVO对象
    final doAcceptVO = DoAcceptVO(
      materialList: materialVOList,
      // materialList: materialVOListForTest,
      imageList: const [], // 暂时为空，后续处理文件上传
      realWarehouse: realWarehouse,
      warehouseId: warehouseId,
      messageTo: selectedUserIds,
    );

    // 打印调试信息
    print('DoAcceptVO 数据:');
    print('  材料数量: ${doAcceptVO.materialList.length}');
    print('  仓库类型: ${realWarehouse ? "独立仓库" : "项目现场"}');
    print('  仓库ID: $warehouseId');
    print('  通知用户ID: $selectedUserIds');

    // 通过BLoC提交验收数据
    context.read<AcceptanceBloc>().add(SubmitAcceptance(request: doAcceptVO));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正在提交验收数据...')));
  }

  void _handleSupplementReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('补录返告功能')));
  }

  void _handleProcessReturn() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('处理退库功能')));
  }

  void _handleConfirmAcceptance() {
    print('验收照片数量: ${_acceptancePhotos.length}');
    print('报验单数量: ${_inspectionReports.length}');
    print('验收报告数量: ${_acceptanceReports.length}');
    print('仓库类型: $_storageType');
    print('选择的仓库: $_selectedWarehouse');
    print('推送状态: $_userPushStates');

    // Collect selected user IDs for push notifications
    final selectedUserIds = <int>[];
    _userPushStates.forEach((key, value) {
      if (value != null && value) {
        print('选中推送用户: $key');
        // In real implementation, map user names to IDs
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('验收确认成功')));
    Navigator.of(context).pop();
  }

  void _handleReturn() {
    Navigator.of(context).pop();
  }

  List<MaterialVO> _convertPipeMaterialsToMaterialVOs(
    List<PipeMaterial> materials,
  ) {
    return materials.map((material) {
      return MaterialVO(
        materialId: int.tryParse(material.id) ?? 0,
        materialName: material.materialName,
        num: material.quantity,
      );
    }).toList();
  }

  List<int> _getSelectedUserIds() {
    final selectedUserIds = <int>[];

    // 遍历推送状态，找到选中的用户
    _userPushStates.forEach((key, isSelected) {
      if (isSelected == true) {
        // 从key中解析出用户类型和用户名
        final parts = key.split('_');
        if (parts.length >= 2) {
          final userType =
              parts[0]; // 'supervisor', 'construction', 'warehouse'
          final userName = parts.sublist(1).join('_'); // 支持用户名包含下划线的情况

          // 根据用户类型在对应列表中查找用户ID
          CommonUserVO? user;
          switch (userType) {
            case 'supervisor':
              user = _supervisorUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
            case 'construction':
              user = _constructionUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
            case 'warehouse':
              user = _warehouseUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
          }

          if (user != null && user.userId > 0) {
            selectedUserIds.add(user.userId);
          }
        }
      }
    });

    return selectedUserIds;
  }
}
