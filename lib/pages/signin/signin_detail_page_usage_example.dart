/*
 * @Author: LeeZB
 * @Date: 2025-08-28 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-28 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/*
 * 入库详情页面使用示例
 * 
 * 这个示例展示了如何正确使用 SigninDetailPage 和 SigninDetailCubit。
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/cubits/signin_detail_cubit.dart';
import 'package:pipe_code_flutter/pages/signin/signin_detail_page.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signin_repository.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class SigninDetailPageUsageExample {
  /// 导航到入库详情页面
  ///
  /// 使用方式：
  /// ```dart
  /// SigninDetailPageUsageExample.navigateToSigninDetail(context, signinId);
  /// ```
  static void navigateToSigninDetail(BuildContext context, int signinId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              SigninDetailCubit(signinRepository: getIt<SigninRepository>()),
          child: SigninDetailPage(signinId: signinId),
        ),
      ),
    );
  }

  /// 如果你需要在现有的 MultiBlocProvider 中添加 SigninDetailCubit
  /// 可以参考以下方式：
  ///
  /// ```dart
  /// MultiBlocProvider(
  ///   providers: [
  ///     // ... 其他 Cubit/Bloc
  ///     BlocProvider<SigninDetailCubit>(
  ///       create: (context) => SigninDetailCubit(
  ///         signinRepository: getIt<SigninRepository>(),
  ///       ),
  ///     ),
  ///   ],
  ///   child: SigninDetailPage(signinId: signinId),
  /// )
  /// ```

  /// 如果你使用 go_router 或其他路由管理器，可以这样配置路由：
  ///
  /// ```dart
  /// GoRoute(
  ///   path: '/signin-detail/:id',
  ///   builder: (context, state) {
  ///     final signinId = int.parse(state.pathParameters['id']!);
  ///     return BlocProvider(
  ///       create: (context) => SigninDetailCubit(
  ///         signinRepository: getIt<SigninRepository>(),
  ///       ),
  ///       child: SigninDetailPage(signinId: signinId),
  ///     );
  ///   },
  /// )
  /// ```
}

/// 如果你需要在列表页面中跳转到详情页，可以参考以下示例：
class SigninListItemExample extends StatelessWidget {
  final int signinId;
  final String signinTitle;

  const SigninListItemExample({
    super.key,
    required this.signinId,
    required this.signinTitle,
  });

  @override
  Widget build(BuildContext context) {
    return UnifiedCard(
      businessType: 'signin',
      child: ListTile(
        title: Text(signinTitle),
        subtitle: Text('入库ID: $signinId'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // 点击列表项导航到详情页
          SigninDetailPageUsageExample.navigateToSigninDetail(
            context,
            signinId,
          );
        },
      ),
    );
  }
}
