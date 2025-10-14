import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/records/record_type.dart';
import 'package:pipe_code_flutter/models/signout/signout_info_vo.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/rxbloc/signout_audit_controller.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/file_upload/fade_scale_route.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';
import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class SignoutAuditPage extends StatefulWidget {
  final int signoutId;
  const SignoutAuditPage({super.key, required this.signoutId});

  @override
  State<SignoutAuditPage> createState() => _SignoutAuditPageState();
}

class _SignoutAuditPageState extends State<SignoutAuditPage> {
  late SignoutAuditController _controller;
  bool _hasShownSuccessMessage = false;
  final TextEditingController _rejectReasonController = TextEditingController();
  final List<String>? _reasonVoice = [];

  @override
  void initState() {
    super.initState();
    _controller = SignoutAuditController(getIt<SignoutRepository>());
    _loadSignoutDetail();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _loadSignoutDetail() {
    _controller.loadSignoutDetail(widget.signoutId);
  }

  void _confirmAudit() {
    _controller.confirmAudit(widget.signoutId);
  }

  void _rejectAudit() {
    final reason = _rejectReasonController.text.trim();
    if (reason.isEmpty) {
      context.showErrorToast('请填写驳回原因');
      return;
    }
    _controller.rejectAudit(
      signoutId: widget.signoutId,
      reason: reason,
      reasonVoice: _reasonVoice,
    );
  }

  void _handleStateChange(SignoutAuditState state) {
    // 处理成功状态
    if (state.isSuccess && !_hasShownSuccessMessage) {
      _hasShownSuccessMessage = true;
      context.showSuccessToast('审核完成，即将返回', isGlobal: true);

      try {
        context.read<RecordsBloc>().add(
          RefreshRecords(recordType: RecordType.signout),
        );
        context.read<RecordsBloc>().add(
          RefreshRecords(recordType: RecordType.warehouseTodo),
        );
      } catch (e) {
        Logger.debug('刷新记录列表失败: ${e.toString()}', tag: 'SignoutAuditPage');
      }

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    }

    // 处理错误状态
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      context.showErrorToast(state.errorMessage!);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.clearError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey100,
      appBar: AppBar(
        title: const Text('出库确认', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.getBusinessColor('signout'),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<SignoutAuditState>(
        stream: _controller.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const SignoutAuditState();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleStateChange(state);
          });

          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(SignoutAuditState state) {
    if (state.isLoading && state.signoutDetail == null) {
      return const common.LoadingWidget(message: '正在加载出库详情...');
    }

    if (state.errorMessage != null && state.signoutDetail == null) {
      return common.ErrorWidget(
        message: state.errorMessage!,
        onRetry: _loadSignoutDetail,
      );
    }

    if (state.signoutDetail != null) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                children: <Widget>[
                  _buildMaterialsList(state.signoutDetail!),
                  SizedBox(height: AppTheme.spacingLarge),
                  _buildPhotoSection(state.signoutDetail!),
                  SizedBox(height: AppTheme.spacingLarge),
                  _buildWarehouseSection(state),
                  SizedBox(height: AppTheme.spacingXXLarge * 2),
                ],
              ),
            ),
          ),
          _buildActionButtons(state),
        ],
      );
    }

    return Center(child: Text('暂无数据'));
  }

  Widget _buildMaterialsList(SignoutInfoVo signoutDetail) {
    return UnifiedCard(
      businessType: 'signout',
      title: '材料清单',
      icon: Icons.inventory,
      child: Column(
        children: signoutDetail.materialList
            .map(
              (material) => MaterialListItem(
                materialName: material.displayMaterialName,
                primaryText: material.materialCode ?? '无',
                batchCode: material.batchCode ?? '无',
                materialId: material.displayMaterialId,
                quantity: material.displayNum,
                status: material.status,
                statusName: material.statusName,
                issueDesc: material.issueDesc,
                businessType: 'signout',
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPhotoSection(SignoutInfoVo signoutDetail) {
    return UnifiedCard(
      businessType: 'signout',
      title: '照片',
      icon: Icons.camera_alt,
      child: _buildPhotoGrid(signoutDetail.imageList),
    );
  }

  Widget _buildPhotoGrid(List<AttachmentVO> imageList) {
    if (imageList.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text('暂无照片', style: TextStyle(color: AppTheme.grey600)),
      );
    }

    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;

    return Row(
      children: imageList.asMap().entries.map((entry) {
        final index = entry.key;
        final photo = entry.value;
        final imageUrlWithToken = photo.url.contains('?')
            ? '${photo.url}&auth_toke=$token'
            : '${photo.url}?auth_toke=$token';

        return Padding(
          padding: EdgeInsets.only(right: AppTheme.spacingMedium),
          child: GestureDetector(
            onTap: () => _previewImages(imageList, index),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.grey300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Image.network(
                  imageUrlWithToken,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.grey100,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppTheme.grey600,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWarehouseSection(SignoutAuditState state) {
    return UnifiedCard(
      businessType: 'signout',
      title: '仓库信息',
      icon: Icons.warehouse,
      child: Column(
        children: [
          InfoRow(
            icon: Icons.outbox,
            label: '发出仓库',
            value: state.signoutDetail?.warehouseName ?? '未知仓库',
          ),
          if (state.signoutDetail?.warehouseUsers.isNotEmpty ?? false) ...[
            SizedBox(height: AppTheme.spacingMedium),
            _buildResponsiblePersonsSection(
              '仓库负责人',
              state.signoutDetail!.warehouseUsers,
            ),
          ],
          SizedBox(height: AppTheme.spacingMedium),
          _buildInstallationUserSection(state),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SignoutAuditState state) {
    return UnifiedActionButtons(
      primaryButton: UnifiedButton(
        text: '确认',
        type: UnifiedButtonType.primary,
        onPressed: state.isSubmitting ? null : _confirmAudit,
        isLoading: state.isSubmitting,
        backgroundColor: AppTheme.getBusinessColor('signout'),
      ),
      secondaryButton: UnifiedButton(
        text: '驳回',
        type: UnifiedButtonType.outlined,
        onPressed: state.isSubmitting ? null : _showRejectDialog,
        foregroundColor: Colors.redAccent,
        borderColor: Colors.redAccent,
      ),
      isFullWidth: true,
    );
  }

  /// 构建负责人信息部分
  Widget _buildResponsiblePersonsSection(String title, List users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title：',
          style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        ...users.map(
          (user) => Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: UserInfoWidget(
              name: user.name,
              phone: user.phone,
              trailing: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSmall,
                  vertical: AppTheme.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.grey400),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  '仓管员',
                  style: TextStyle(fontSize: 12, color: AppTheme.grey600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建安装用户信息部分
  Widget _buildInstallationUserSection(SignoutAuditState state) {
    // 优先使用SignoutInfoVo中的安装用户信息
    String? installUserName = state.signoutDetail?.installUserName;
    String? installUserPhone = state.signoutDetail?.installUserPhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出库安装负责人：',
          style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        UserInfoWidget(
          name: installUserName ?? '未知用户',
          phone: installUserPhone ?? '未知号码',
          trailing: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingXSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.getBusinessColor(
                'signout',
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              '安装人',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getBusinessColor('signout'),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _previewImages(List<AttachmentVO> imageList, int initialIndex) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;

    final imageUrls = imageList.map((photo) {
      return photo.url.contains('?')
          ? '${photo.url}&auth_toke=$token'
          : '${photo.url}?auth_toke=$token';
    }).toList();

    Navigator.of(context).push(
      FadeScaleRoute(
        page: ImagePreviewWidget(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          onUrlsChanged: (newUrls) {},
        ),
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('驳回出库'),
          content: SpeechInputWidget(
            controller: _rejectReasonController,
            onVoiceRecordingPath: (filePath) {
              setState(() {
                _reasonVoice?.add(filePath);
              });
            },
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '请输入驳回原因',
              border: OutlineInputBorder(),
            ),
          ),
          // content: TextField(
          //   controller: _rejectReasonController,
          //   maxLines: 3,
          //   decoration: const InputDecoration(
          //     hintText: '请输入驳回原因',
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.returnColor,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLarge,
                  vertical: AppTheme.spacingMedium,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _rejectAudit();
              },
              child: const Text('确认驳回'),
            ),
          ],
        );
      },
    );
  }
}
