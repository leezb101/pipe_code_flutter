/*
 * @Author: LeeZB
 * @Date: 2025-07-07 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-07 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/inventory/pipe_material.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../widgets/file_upload/file_upload_widget.dart';

class InventoryConfirmationPage extends StatefulWidget {
  const InventoryConfirmationPage({
    super.key,
    required this.materials,
    required this.scanMode,
  });

  final List<PipeMaterial> materials;
  final String scanMode; // 'batch' or 'delivery'

  @override
  State<InventoryConfirmationPage> createState() => _InventoryConfirmationPageState();
}

class _InventoryConfirmationPageState extends State<InventoryConfirmationPage> {
  List<File> _acceptancePhotos = [];
  List<File> _inspectionReports = [];
  List<File> _acceptanceReports = [];

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
                  color: Colors.blue[600],
                ),
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
            ...widget.materials.map((material) => _buildMaterialItem(material)).toList(),
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
            child: Icon(
              Icons.water_drop,
              size: 20,
              color: Colors.blue[700],
            ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
                  Icons.attach_file,
                  size: 24,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                const Text(
                  '附件上传',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ImageUploadWidget(
              title: '验收照片',
              onImagesChanged: (images) {
                _acceptancePhotos = images;
              },
              maxImages: 6,
            ),
            const SizedBox(height: 24),
            FileUploadWidget(
              title: '报验单',
              onFilesChanged: (files) {
                _inspectionReports = files;
              },
              allowedExtensions: ['pdf', 'doc', 'docx'],
              maxFiles: 3,
            ),
            const SizedBox(height: 24),
            FileUploadWidget(
              title: '验收报告',
              onFilesChanged: (files) {
                _acceptanceReports = files;
              },
              allowedExtensions: ['pdf', 'doc', 'docx'],
              maxFiles: 3,
            ),
          ],
        ),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleRejectAcceptance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '验收驳回',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
          ],
        ),
      ),
    );
  }

  void _handleConfirmAcceptance() {
    // TODO: Implement acceptance confirmation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('验收确认成功')),
    );
    Navigator.of(context).pop();
  }

  void _handleRejectAcceptance() {
    // TODO: Implement acceptance rejection logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('验收驳回成功')),
    );
    Navigator.of(context).pop();
  }

  void _handleProcessReturn() {
    // TODO: Implement return processing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('处理退库成功')),
    );
    Navigator.of(context).pop();
  }

  void _handleReturn() {
    Navigator.of(context).pop();
  }
}