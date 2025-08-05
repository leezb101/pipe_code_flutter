/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 18:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_bloc.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_event.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_state.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';

class ScrapPage extends StatefulWidget {
  final MaterialInfoForBusiness? materials;
  final List<String>? codes;

  const ScrapPage({super.key, this.materials, this.codes});

  @override
  State<ScrapPage> createState() => _ScrapPageState();
}

class _ScrapPageState extends State<ScrapPage> {
  List<File> _photos = [];

  // 保存已经扫描过的原始码，用于去重
  final Set<String> _scannedCodes = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeScrap();
  }

  void _initializeScrap() {
    if (widget.materials != null) {
      // 从MaterialInfoForBusiness初始化
      context.read<ScrapBloc>().add(
            InitializeScrapSubmission(materialInfoForBusiness: widget.materials!),
          );
    } else if (widget.codes != null) {
      // 从扫码结果初始化
      _scannedCodes.addAll(widget.codes!); // 保存初始的扫码
      context.read<ScrapBloc>().add(
            InitializeScrapFromCodes(codes: widget.codes!),
          );
    }
  }

  void _submitScrap() {
    // 更新bloc中的照片列表
    final photoPaths = _photos.map((p) => p.path).toList();
    context.read<ScrapBloc>().add(UpdateScrapPhotos(photoPaths: photoPaths));
    // 触发提交
    context.read<ScrapBloc>().add(const SubmitScrap());
  }

  // 扫码添加材料
  Future<void> _scanToAddMaterials() async {
    final config = QrScanConfig(
      scanType: QrScanType.scrap,
      scanMode: QrScanMode.batch,
      context: {'source': 'scrapPage'},
      existingCodesToExclude: _scannedCodes.toList(), // 传递已扫描的原始码用于去重
    );
    final result = await context.pushNamed('qr-scan', extra: config);
    if (result != null && result is List) {
      final codes = result.map((r) => r.code as String).toList();
      if (mounted) {
        // 更新已扫描码集合
        _scannedCodes.addAll(codes);
        context.read<ScrapBloc>().add(AppendMaterialsFromCodes(codes: codes));
      }
    }
  }

  // 扫码删除材料
  Future<void> _scanToRemoveMaterials() async {
    final config = QrScanConfig(
      scanType: QrScanType.scrap,
      scanMode: QrScanMode.batch,
      context: {'source': 'scrapPage'},
      isRemoveOperation: true, // 明确标记为删除操作
    );
    final result = await context.pushNamed('qr-scan', extra: config);
    if (result != null && result is List) {
      final codes = result.map((r) => r.code as String).toList();
      if (mounted) {
        context.read<ScrapBloc>().add(RemoveMaterialsFromCodes(codes: codes));
        // 删除操作后，清空已扫描码集合，允许重新扫描被删除的材料
        _scannedCodes.clear();
      }
    }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('报废记录', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: BlocListener<ScrapBloc, ScrapState>(
        listener: (context, state) {
          if (state is ScrapError) {
            ToastUtils.showError(context, state.message);
          } else if (state is ScrapSubmitted) {
            ToastUtils.showSuccess(context, state.message);
            // 返回到上一页面
            context.pop();
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ScrapBloc, ScrapState>(
      builder: (context, state) {
        if (state is ScrapLoading) {
          return common.LoadingWidget();
        } else if (state is ScrapSubmissionReady) {
          return _buildSubmissionForm(state);
        } else if (state is ScrapError) {
          return common.ErrorWidget(
            message: state.message,
            onRetry: _initializeScrap,
          );
        }
        return common.EmptyWidget(message: '正在初始化...');
      },
    );
  }

  Widget _buildSubmissionForm(ScrapSubmissionReady state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 物料列表
                _buildMaterialList(state.materialList),
                const SizedBox(height: 24),

                // 扫码按钮区域
                _buildScanButtons(),
                const SizedBox(height: 24),

                // 照片部分
                ImageUploadWidget(
                  title: '照片',
                  maxImages: 6,
                  onImagesChanged: (images) {
                    setState(() {
                      _photos = images;
                    });
                  },
                ),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
        ),

        // 底部按钮
        _buildBottomButtons(state),
      ],
    );
  }

  Widget _buildMaterialList(List<MaterialVO> materialList) {
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
            ...materialList.map((material) => _buildMaterialItem(material)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButtons() {
    return Row(
      children: [
        // 扫码添加按钮（左半圆）
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            child: ElevatedButton(
              onPressed: _scanToAddMaterials,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '扫码报废',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 扫码删除按钮（右半圆）
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: ElevatedButton(
              onPressed: _scanToRemoveMaterials,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '扫码删除',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
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
                  '数量: ${material.num}个',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${material.num}个',
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

  Widget _buildBottomButtons(ScrapSubmissionReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 提交按钮
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.isSubmitting ? null : _submitScrap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('提交', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),

          // 返回按钮
          Expanded(
            child: OutlinedButton(
              onPressed: state.isSubmitting ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '返回',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
