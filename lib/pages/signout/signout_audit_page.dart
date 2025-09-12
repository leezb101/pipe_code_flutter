/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 16:15:01
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_event.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_state.dart';
import 'package:pipe_code_flutter/bloc/user/user_bloc.dart';
import 'package:pipe_code_flutter/bloc/user/user_state.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/file_upload/fade_scale_route.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class SignoutAuditPage extends StatefulWidget {
  final int signoutId;

  const SignoutAuditPage({super.key, required this.signoutId});

  @override
  State<SignoutAuditPage> createState() => _SignoutAuditPageState();
}

class _SignoutAuditPageState extends State<SignoutAuditPage> {
  @override
  void initState() {
    context.read<SignoutBloc>().add(
      LoadSignoutDetail(signinId: widget.signoutId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignoutBloc, SignoutState>(
      listener: (context, state) {
        if (state is SignoutReady) {
          if (state.warehouseInfoError != null) {
            context.showErrorToast(state.warehouseInfoError!);
          }
          if (state.warehouseUsersError != null) {
            context.showErrorToast(state.warehouseUsersError!);
          }
        } else if (state is SignoutDetailError) {
          context.showErrorToast(state.message);
        } else if (state is SignoutAudited) {
          context.showSuccessToast('审核完成，即将返回', isGlobal: true);
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.pop();
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('一管一码'),
          backgroundColor: AppTheme.getBusinessColor('signout'),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '出库记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacingSmall),
          ],
        ),
        backgroundColor: Colors.grey[50],
        body: BlocBuilder<SignoutBloc, SignoutState>(
          builder: (context, state) {
            // Show loading for initial, loading, and auditing states to avoid fallback flashes
            if (state is SignoutInitial ||
                state is SignoutLoading ||
                state is SignoutAuditing ||
                state is SignoutAudited) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SignoutReady) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMaterialsList(context, state),
                          const SizedBox(height: 16),
                          _buildPhotoSection(context, state),
                          const SizedBox(height: 16),
                          _buildWarehouseSection(state),
                        ],
                      ),
                    ),
                  ),
                  _buildActionButtons(),
                ],
              );
            }
            // Fallback (should rarely hit now)
            return const Center(child: Text('未知错误，请重试'));
          },
        ),
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context, SignoutReady state) {
    return UnifiedCard(
      title: '材料清单',
      icon: Icons.inventory,
      businessType: 'signout',
      child: Column(
        children: state.signoutDetail!.materialList
            .map((material) => _buildMaterialItem(material))
            .toList(),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: MaterialListItem(
        materialName: material.materialName,
        materialId: material.materialId.toString(),
        quantity: material.num,
        businessType: 'signout',
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, SignoutReady state) {
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
                Icon(Icons.camera_alt, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '照片：',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPhotoGrid(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context, SignoutReady state) {
    final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
    final token = authState.wxLoginVO.tk;
    return Row(
      children: <Widget>[
        if (state.signoutDetail?.imageList.isNotEmpty ?? false)
          ...state.signoutDetail!.imageList.asMap().entries.map((entry) {
            AttachmentVO photo = entry.value;
            final imgurlWithTk = photo.url.contains('?')
                ? '${photo.url}&auth_toke=$token'
                : '${photo.url}?auth_toke=$token';
            final index = entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () => _previewImages(context, state, index),
                child: Image.network(
                  imgurlWithTk,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }),
      ],
    );
  }

  void _previewImages(BuildContext context, SignoutReady state, int index) {
    Navigator.of(context).push(
      FadeScaleRoute(
        page: ImagePreviewWidget(
          imageUrls: state.signoutDetail!.imageList.map((e) => e.url).map((e) {
            final authState =
                context.read<AuthBloc>().state as AuthLoginSuccess;
            final token = authState.wxLoginVO.tk;
            return e.contains('?')
                ? '$e&auth_toke=$token'
                : '$e?auth_toke=$token';
          }).toList(),
          initialIndex: index,
          onUrlsChanged: (p0) => {},
        ),
      ),
    );
  }

  Widget _buildWarehouseSection(SignoutReady state) {
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
                  '仓库信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWarehouseInfo(state),
            const SizedBox(height: 20),
            if (state.warehouseUsers != null)
              _buildWarehouseUsers(state.warehouseUsers!.warehouseUsers),
            const SizedBox(height: 20),
            _buildInstallationUser(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseInfo(SignoutReady state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Text(
            '发出仓库：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.signoutDetail?.warehouseName ?? 'XXXX仓库--地址XXXXXXX',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseUsers(List<CommonUserVO>? users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '仓库负责人：',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            if (users != null && users.isNotEmpty)
              Expanded(
                child: Text(
                  '${users.first.name} - ${users.first.phone}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              )
            else
              const Expanded(
                child: Text(
                  '李明 - 18999990000',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstallationUser(BuildContext context) {
    final userstate = context.read<UserBloc>().state;
    String? userName, userPhone;
    if (userstate is UserLoaded) {
      userName = userstate.wxLoginVO.name;
      userPhone = userstate.wxLoginVO.phone;
    } else {
      userName = '未知';
      userPhone = '未知';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '出库安装负责人：',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$userName - $userPhone',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
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
                onPressed: _handleConfirm,
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
                  '确认',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleReject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '驳回',
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
      ),
    );
  }

  void _handleViewRecords() {
    context.go('/records?tab=signout');
  }

  void _handleConfirm() {
    context.read<SignoutBloc>().add(
      AuditSignout(
        request: CommonDoBusinessAuditVO(id: widget.signoutId, pass: true),
      ),
    );
  }

  void _handleReject() {
    context.showInfoToast('驳回审核功能待实现');
  }

  void _handleReturn() {
    context.pop();
  }
}
