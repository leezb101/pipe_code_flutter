import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_bloc.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_event.dart';
import 'package:pipe_code_flutter/bloc/acceptance/acceptance_state.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class AcceptanceDetailPage extends StatefulWidget {
  final int acceptanceId;

  const AcceptanceDetailPage({Key? key, required this.acceptanceId})
    : super(key: key);

  @override
  State<AcceptanceDetailPage> createState() => _AcceptanceDetailPageState();
}

class _AcceptanceDetailPageState extends State<AcceptanceDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadAcceptanceDetail();
  }

  void _loadAcceptanceDetail() {
    context.read<AcceptanceBloc>().add(
      LoadAcceptanceDetail(acceptanceId: widget.acceptanceId),
    );
  }

  void _refreshAcceptanceDetail() {
    context.read<AcceptanceBloc>().add(
      RefreshAcceptanceDetail(acceptanceId: widget.acceptanceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验收详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAcceptanceDetail,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AcceptanceBloc, AcceptanceState>(
      builder: (context, state) {
        if (state is AcceptanceLoading) {
          return common.LoadingWidget();
        }

        if (state is AcceptanceError) {
          return common.ErrorWidget(
            message: state.message,
            onRetry: _loadAcceptanceDetail,
          );
        }

        if (state is AcceptanceDetailLoaded) {
          return RefreshIndicator(
            onRefresh: () async => _refreshAcceptanceDetail(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarehouseInfo(state.acceptanceInfo),
                  const SizedBox(height: 16),
                  _buildMaterialsList(state.acceptanceInfo),
                  const SizedBox(height: 16),
                  _buildAttachmentsList(state.acceptanceInfo),
                  const SizedBox(height: 16),
                  _buildSignInInfo(state.acceptanceInfo),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('暂无数据'));
      },
    );
  }

  Widget _buildWarehouseInfo(AcceptanceInfoVO acceptanceInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '仓库信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('仓库类型', acceptanceInfo.warehouseTypeDescription),
            _buildInfoRow('仓库ID', acceptanceInfo.warehouseId.toString()),
            _buildUserListSection('仓库负责人', acceptanceInfo.warehouseUsers),
            _buildUserListSection('监理方负责人', acceptanceInfo.supervisorUsers),
            _buildUserListSection('建设方负责人', acceptanceInfo.constructionUsers),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList(AcceptanceInfoVO acceptanceInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '物料清单',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...acceptanceInfo.materialList.map(
              (material) => _buildMaterialItem(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  material.materialName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${material.num}个',
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ],
          ),
          if (material.installPileNo != null) ...[
            const SizedBox(height: 8),
            Text(
              '安装桩号: ${material.installPileNo}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
          if (material.installImageUrl1 != null ||
              material.installImageUrl2 != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (material.installImageUrl1 != null)
                  _buildImagePreview(material.installImageUrl1!),
                if (material.installImageUrl2 != null) ...[
                  const SizedBox(width: 8),
                  _buildImagePreview(material.installImageUrl2!),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(AcceptanceInfoVO acceptanceInfo) {
    if (acceptanceInfo.imageList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '附件列表',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...acceptanceInfo.imageList.map(
              (attachment) => _buildAttachmentItem(attachment),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentVO attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            attachment.isImage ? Icons.image : Icons.insert_drive_file,
            color: attachment.isImage ? Colors.green : Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  attachment.attachmentTypeDescription,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _previewAttachment(attachment),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInInfo(AcceptanceInfoVO acceptanceInfo) {
    if (acceptanceInfo.signInInfo == null) {
      return const SizedBox.shrink();
    }

    final signInInfo = acceptanceInfo.signInInfo!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '入库信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('入库仓库ID', signInInfo.warehouseId.toString()),
            const SizedBox(height: 12),
            const Text(
              '入库物料',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...signInInfo.materialList.map(
              (material) => _buildSimpleMaterialItem(material),
            ),
            if (signInInfo.imageList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '入库照片',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: signInInfo.imageList
                    .map((attachment) => _buildImagePreview(attachment.url))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleMaterialItem(MaterialVO material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              material.materialName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${material.num}个',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade100,
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildUserListSection(String title, List<CommonUserVO> users) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (users.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                '暂无用户',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            )
          else
            ...users
                .map(
                  (user) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                user.phone,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user.messageTo != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '推送',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  void _previewAttachment(AttachmentVO attachment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    attachment.isImage ? Icons.image : Icons.insert_drive_file,
                    color: attachment.isImage ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attachment.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (attachment.isImage)
                Image.network(
                  attachment.url,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.insert_drive_file,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('下载功能待实现')));
                },
                child: const Text('下载'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
