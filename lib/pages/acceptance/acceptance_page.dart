/*
 * @Author: LeeZB
 * @Date: 2025-07-17 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-17 19:36:23
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/inventory/pipe_material.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../widgets/file_upload/file_upload_widget.dart';

class AcceptancePage extends StatefulWidget {
  const AcceptancePage({super.key, required this.materials});

  final List<PipeMaterial> materials;

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
  String? _selectedManager;
  bool _isNewManager = false;

  // 新增负责人信息
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // 模拟数据
  final List<String> _warehouses = [
    'XXXX仓库-地址XXXXXXXX',
    'YYYY仓库-地址YYYYYYYY',
    'ZZZZ仓库-地址ZZZZZZZZ',
  ];

  final List<String> _managers = ['李明', '王强', '张华'];

  @override
  void initState() {
    super.initState();
    _selectedWarehouse = _warehouses.first;
    _selectedManager = _managers.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
            ...widget.materials
                .map((material) => _buildMaterialItem(material))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(PipeMaterial material) {
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
                  material.materialName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material.specification,
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
              '${material.quantity}${material.unit}',
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
            const SizedBox(height: 20),
            _buildWarehouseSelection(),
            const SizedBox(height: 20),
            _buildManagerSection(),
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
                });
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
            child: DropdownButton<String>(
              value: _selectedWarehouse,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWarehouse = newValue;
                });
              },
              items: _warehouses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '仓库负责人：',
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
            child: DropdownButton<String>(
              value: _selectedManager,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedManager = newValue;
                });
              },
              items: _managers.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(value),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _isNewManager,
              onChanged: (bool? value) {
                setState(() {
                  _isNewManager = value ?? false;
                });
              },
            ),
            const Text('是否新增仓库负责人', style: TextStyle(fontSize: 16)),
          ],
        ),
        if (_isNewManager) ...[
          const SizedBox(height: 16),
          _buildNewManagerForm(),
        ],
      ],
    );
  }

  Widget _buildNewManagerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '姓名：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '请输入姓名',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '手机号：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: '请输入手机号',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('查看验收记录')));
  }

  void _handleScanAcceptance() {
    print('验收照片数量: ${_acceptancePhotos.length}');
    print('报验单数量: ${_inspectionReports.length}');
    print('验收报告数量: ${_acceptanceReports.length}');
    print('仓库类型: $_storageType');
    print('选择的仓库: $_selectedWarehouse');
    print('负责人: $_selectedManager');
    if (_isNewManager) {
      print('新增负责人: ${_nameController.text}, ${_phoneController.text}');
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('扫码验收功能')));
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
    print('负责人: $_selectedManager');
    if (_isNewManager) {
      print('新增负责人: ${_nameController.text}, ${_phoneController.text}');
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('验收确认成功')));
    Navigator.of(context).pop();
  }

  void _handleReturn() {
    Navigator.of(context).pop();
  }
}
