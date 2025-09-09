/*
 * @Author: LeeZB
 * @Date: 2025-09-09 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-09 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/bloc/project_users/project_users_bloc.dart';
import 'package:pipe_code_flutter/bloc/project_users/project_users_event.dart';
import 'package:pipe_code_flutter/bloc/project_users/project_users_state.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/models/qmap/map_project_user.dart';

class ProjectUsersPage extends StatelessWidget {
  final int projectId;
  final String code;
  final String orgName;

  const ProjectUsersPage({
    super.key,
    required this.projectId,
    required this.code,
    required this.orgName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectUsersBloc(mapApiService: getIt<MapApiService>())..add(
            LoadProjectUsers(
              projectId: projectId,
              code: code,
              orgName: orgName,
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$orgName - 人员列表'),
          elevation: 0,
          backgroundColor: AppTheme.getBusinessColor('project'),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            BlocBuilder<ProjectUsersBloc, ProjectUsersState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.read<ProjectUsersBloc>().add(
                            RefreshProjectUsers(
                              projectId: projectId,
                              code: code,
                              orgName: orgName,
                            ),
                          );
                        },
                  icon: state.isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: BlocListener<ProjectUsersBloc, ProjectUsersState>(
          listener: (context, state) {
            if (state.hasErrorMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppTheme.errorColor,
                  action: SnackBarAction(
                    label: '关闭',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<ProjectUsersBloc>().add(
                        const ClearUsersErrorMessage(),
                      );
                    },
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ProjectUsersBloc, ProjectUsersState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppTheme.spacingLarge),
                      Text('正在加载用户列表...'),
                    ],
                  ),
                );
              }

              if (state.hasError && !state.hasUsers) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text(
                        '加载失败',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      if (state.hasErrorMessage)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingLarge,
                          ),
                          child: Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.grey600,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppTheme.spacingXLarge),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProjectUsersBloc>().add(
                            LoadProjectUsers(
                              projectId: projectId,
                              code: code,
                              orgName: orgName,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getBusinessColor('project'),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!state.hasUsers) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.grey400,
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                      Text(
                        '暂无用户数据',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        '该组织暂时没有关联的用户',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.grey500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectUsersBloc>().add(
                    RefreshProjectUsers(
                      projectId: projectId,
                      code: code,
                      orgName: orgName,
                    ),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.spacingLarge),
                  children: [
                    // 头部信息卡片
                    UnifiedCard(
                      title: '组织信息',
                      icon: Icons.business,
                      businessType: 'project',
                      child: Column(
                        children: [
                          InfoRow(
                            label: '组织名称',
                            value: orgName,
                            icon: Icons.account_balance,
                            iconColor: AppTheme.getBusinessColor('project'),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          InfoRow(
                            label: '组织代码',
                            value: code,
                            icon: Icons.tag,
                            iconColor: AppTheme.getBusinessColor('project'),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          InfoRow(
                            label: '人员数量',
                            value: '${state.users.length}人',
                            icon: Icons.people,
                            iconColor: AppTheme.getBusinessColor('project'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),

                    // 用户列表
                    UnifiedCard(
                      title: '人员列表',
                      icon: Icons.people,
                      businessType: 'project',
                      child: Column(
                        children: state.users
                            .map((user) => _buildUserItem(user))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(MapProjectUser user) {
    return UserInfoWidget(
      name: user.name ?? '未知用户',
      phone: user.phone,
      title: user.realHandler == true ? '实际操作人' : null,
      showPushOption: true,
      isPushSelected: user.messageTo == true,
      trailing: user.realHandler == true
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getBusinessColor('project'),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                '操作人',
                style: AppTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: () {
        // 可以添加用户详情查看功能
      },
    );
  }
}
