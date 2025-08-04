/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 16:37:17
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_bloc.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_event.dart';
import 'package:pipe_code_flutter/bloc/scrap/scrap_state.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class ScrapDetailPage extends StatefulWidget {
  final int scrapId;

  const ScrapDetailPage({super.key, required this.scrapId});

  @override
  State<ScrapDetailPage> createState() => _ScrapDetailPageState();
}

class _ScrapDetailPageState extends State<ScrapDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadScrapDetail();
  }

  void _loadScrapDetail() {
    context.read<ScrapBloc>().add(LoadScrapDetail(scrapId: widget.scrapId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报废详情'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScrapDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ScrapBloc, ScrapState>(
      builder: (context, state) {
        if (state is ScrapLoading) {
          return common.LoadingWidget();
        } else if (state is ScrapDetailLoaded) {
          return _buildDetailContent(state.scrapDetail);
        } else if (state is ScrapError) {
          return common.ErrorWidget(
            message: state.message,
            onRetry: _loadScrapDetail,
          );
        }
        return common.EmptyWidget(message: '暂无数据');
      },
    );
  }

  Widget _buildDetailContent(ScrapDetailVO scrapDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              const Icon(Icons.qr_code, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                '一管一码',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('报废记录', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 物料列表
          _buildMaterialList(scrapDetail.materialList),
          const SizedBox(height: 24),

          // 照片部分
          _buildPhotoSection(scrapDetail.attachmentList),
        ],
      ),
    );
  }

  Widget _buildMaterialList(List<MaterialVO> materialList) {
    if (materialList.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无物料信息', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '物料清单：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...materialList.map((material) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.materialName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (material.installPileNo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '桩号: ${material.installPileNo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${material.num}个',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPhotoSection(List<AttachmentVO> attachmentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '照片：',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (attachmentList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              children: [
                Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  '暂无照片',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: attachmentList.map((attachment) {
              return _buildPhotoItem(attachment.url);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPhotoItem(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 32, color: Colors.grey),
            SizedBox(height: 4),
            Text('图片加载失败', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showFullScreenImage(photoUrl),
      child: Hero(
        tag: photoUrl,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(photoUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String photoUrl) {
    // 判断是否为本地文件路径
    if (photoUrl.startsWith('/') || photoUrl.startsWith('file://')) {
      return Image.file(
        File(photoUrl),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey),
                Text(
                  '加载失败',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 网络图片
      return Image.network(
        photoUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey),
                Text(
                  '加载失败',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
  }

  void _showFullScreenImage(String photoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Hero(
              tag: photoUrl,
              child: InteractiveViewer(child: _buildImage(photoUrl)),
            ),
          ),
        ),
      ),
    );
  }
}
