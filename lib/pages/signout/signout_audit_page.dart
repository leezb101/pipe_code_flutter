// /*
//  * @Author: LeeZB
//  * @Date: 2025-07-25 18:45:00
//  * @LastEditors: Leezb101 leezb101@126.com
//  * @LastEditTime: 2025-07-28 16:15:01
//  * @copyright: Copyright © 2025 高新供水.
//  */
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
// import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
// import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
// import 'package:pipe_code_flutter/bloc/signout/signout_event.dart';
// import 'package:pipe_code_flutter/bloc/signout/signout_state.dart';
// import 'package:pipe_code_flutter/bloc/user/user_bloc.dart';
// import 'package:pipe_code_flutter/bloc/user/user_state.dart';
// import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
// import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
// import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
// import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
// import 'package:pipe_code_flutter/utils/toast_utils.dart';
// import 'package:pipe_code_flutter/widgets/file_upload/fade_scale_route.dart';
// import 'package:pipe_code_flutter/widgets/file_upload/image_preview_widget.dart';
// import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';
// import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

// class SignoutAuditPage extends StatefulWidget {
//   final int signoutId;

//   const SignoutAuditPage({super.key, required this.signoutId});

//   @override
//   State<SignoutAuditPage> createState() => _SignoutAuditPageState();
// }

// class _SignoutAuditPageState extends State<SignoutAuditPage> {
//   @override
//   void initState() {
//     context.read<SignoutBloc>().add(
//       LoadSignoutDetail(signinId: widget.signoutId),
//     );
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<SignoutBloc, SignoutState>(
//       listener: (context, state) {
//         if (state is SignoutReady) {
//           if (state.warehouseInfoError != null) {
//             context.showErrorToast(state.warehouseInfoError!);
//           }
//           if (state.warehouseUsersError != null) {
//             context.showErrorToast(state.warehouseUsersError!);
//           }
//         } else if (state is SignoutDetailError) {
//           context.showErrorToast(state.message);
//         } else if (state is SignoutAudited) {
//           context.showSuccessToast('审核完成，即将返回', isGlobal: true);
//           Future.delayed(const Duration(seconds: 2), () {
//             if (context.mounted) {
//               context.pop();
//             }
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('一管一码'),
//           backgroundColor: AppTheme.getBusinessColor('signout'),
//           foregroundColor: Colors.white,
//           iconTheme: const IconThemeData(color: Colors.white),
//           elevation: 0,
//           centerTitle: true,
//           // actions: [
//           //   TextButton(
//           //     onPressed: _handleViewRecords,
//           //     child: const Text(
//           //       '出库记录',
//           //       style: TextStyle(
//           //         fontSize: 16,
//           //         fontWeight: FontWeight.w600,
//           //         color: Colors.white,
//           //       ),
//           //     ),
//           //   ),
//           //   SizedBox(width: AppTheme.spacingSmall),
//           // ],
//         ),
//         backgroundColor: Colors.grey[50],
//         body: BlocBuilder<SignoutBloc, SignoutState>(
//           builder: (context, state) {
//             // Show loading for initial, loading, and auditing states to avoid fallback flashes
//             if (state is SignoutInitial ||
//                 state is SignoutLoading ||
//                 state is SignoutAuditing ||
//                 state is SignoutAudited) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (state is SignoutReady) {
//               return Column(
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           _buildMaterialsList(context, state),
//                           const SizedBox(height: 16),
//                           _buildPhotoSection(context, state),
//                           const SizedBox(height: 16),
//                           _buildWarehouseSection(state),
//                         ],
//                       ),
//                     ),
//                   ),
//                   _buildActionButtons(),
//                 ],
//               );
//             }
//             // Fallback (should rarely hit now)
//             return const Center(child: Text('未知错误，请重试'));
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMaterialsList(BuildContext context, SignoutReady state) {
//     return UnifiedCard(
//       title: '材料清单',
//       icon: Icons.inventory,
//       businessType: 'signout',
//       child: Column(
//         children: state.signoutDetail!.materialList
//             .map((material) => _buildMaterialItem(material))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildMaterialItem(MaterialVO material) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppTheme.spacingMedium),
//       child: MaterialListItem(
//         materialName: material.materialName,
//         materialId: material.materialId.toString(),
//         quantity: material.num,
//         businessType: 'signout',
//       ),
//     );
//   }

//   Widget _buildPhotoSection(BuildContext context, SignoutReady state) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.camera_alt, size: 24, color: Colors.green[600]),
//                 const SizedBox(width: 8),
//                 const Text(
//                   '照片：',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildPhotoGrid(context, state),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhotoGrid(BuildContext context, SignoutReady state) {
//     final authState = context.read<AuthBloc>().state as AuthLoginSuccess;
//     final token = authState.wxLoginVO.tk;
//     return Row(
//       children: <Widget>[
//         if (state.signoutDetail?.imageList.isNotEmpty ?? false)
//           ...state.signoutDetail!.imageList.asMap().entries.map((entry) {
//             AttachmentVO photo = entry.value;
//             final imgurlWithTk = photo.url.contains('?')
//                 ? '${photo.url}&auth_toke=$token'
//                 : '${photo.url}?auth_toke=$token';
//             final index = entry.key;
//             return Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: InkWell(
//                 onTap: () => _previewImages(context, state, index),
//                 child: Image.network(
//                   imgurlWithTk,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             );
//           }),
//       ],
//     );
//   }

//   void _previewImages(BuildContext context, SignoutReady state, int index) {
//     Navigator.of(context).push(
//       FadeScaleRoute(
//         page: ImagePreviewWidget(
//           imageUrls: state.signoutDetail!.imageList.map((e) => e.url).map((e) {
//             final authState =
//                 context.read<AuthBloc>().state as AuthLoginSuccess;
//             final token = authState.wxLoginVO.tk;
//             return e.contains('?')
//                 ? '$e&auth_toke=$token'
//                 : '$e?auth_toke=$token';
//           }).toList(),
//           initialIndex: index,
//           onUrlsChanged: (p0) => {},
//         ),
//       ),
//     );
//   }

//   Widget _buildWarehouseSection(SignoutReady state) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.warehouse, size: 24, color: Colors.orange[600]),
//                 const SizedBox(width: 8),
//                 const Text(
//                   '仓库信息',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildWarehouseInfo(state),
//             const SizedBox(height: 20),
//             if (state.warehouseUsers != null)
//               _buildWarehouseUsers(state.warehouseUsers!.warehouseUsers),
//             const SizedBox(height: 20),
//             _buildInstallationUser(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWarehouseInfo(SignoutReady state) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange[50],
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.orange[200]!),
//       ),
//       child: Row(
//         children: [
//           Text(
//             '发出仓库：',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               state.signoutDetail?.warehouseName ?? 'XXXX仓库--地址XXXXXXX',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWarehouseUsers(List<CommonUserVO>? users) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               '仓库负责人：',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(width: 8),
//             if (users != null && users.isNotEmpty)
//               Expanded(
//                 child: Text(
//                   '${users.first.name} - ${users.first.phone}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//               )
//             else
//               const Expanded(
//                 child: Text(
//                   '李明 - 18999990000',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInstallationUser(BuildContext context) {
//     final userstate = context.read<UserBloc>().state;
//     String? userName, userPhone;
//     if (userstate is UserLoaded) {
//       userName = userstate.wxLoginVO.name;
//       userPhone = userstate.wxLoginVO.phone;
//     } else {
//       userName = '未知';
//       userPhone = '未知';
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               '出库安装负责人：',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 '$userName - $userPhone',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _handleConfirm,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                 ),
//                 child: const Text(
//                   '确认',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: _showRejectDialog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 2,
//                 ),
//                 child: const Text(
//                   '驳回',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _handleReturn,
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.grey[600],
//                   side: BorderSide(color: Colors.grey[400]!),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text(
//                   '返回',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleViewRecords() {
//     context.goNamed('records', queryParameters: {'tab': 'signout'});
//   }

//   void _showRejectDialog() {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('驳回流程'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 16),
//               SpeechInputWidget(
//                 controller: controller,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: '请输入驳回原因',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('取消'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _handleReject();
//               },
//               child: const Text('确认'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _handleConfirm() {
//     context.read<SignoutBloc>().add(
//       AuditSignout(
//         request: CommonDoBusinessAuditVO(id: widget.signoutId, pass: true),
//       ),
//     );
//   }

//   void _handleReject() {
//     context.showInfoToast('驳回审核功能待实现');
//   }

//   void _handleReturn() {
//     context.pop();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/bloc/records/records_bloc.dart';
import 'package:pipe_code_flutter/bloc/records/records_event.dart';
import 'package:pipe_code_flutter/bloc/user/user_bloc.dart';
import 'package:pipe_code_flutter/bloc/user/user_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/constants/app_theme.dart';
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
                materialName: material.materialName,
                primaryText: material.materialCode ?? '无',
                batchCode: material.batchCode ?? '无',
                materialId: material.materialId.toString(),
                quantity: material.num,
                status: material.status,
                statusName: material.statusName,
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
          // content: SpeechInputWidget(
          //   controller: _rejectReasonController,
          //   onVoiceRecordingPath: (filePath) {
          //     setState(() {
          //       _reasonVoice?.add(filePath);
          //     });
          //   },
          //   maxLines: 3,
          //   decoration: const InputDecoration(
          //     hintText: '请输入驳回原因',
          //     border: OutlineInputBorder(),
          //   ),
          // ),
          content: TextField(
            controller: _rejectReasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '请输入驳回原因',
              border: OutlineInputBorder(),
            ),
          ),
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
