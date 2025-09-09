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
import 'package:pipe_code_flutter/bloc/project_detail/project_detail_bloc.dart';
import 'package:pipe_code_flutter/bloc/project_detail/project_detail_event.dart';
import 'package:pipe_code_flutter/bloc/project_detail/project_detail_state.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/pages/qmap/project_users.dart';
import 'package:pipe_code_flutter/models/common/org_models.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';

class ProjectDetailPage extends StatelessWidget {
  final int projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProjectDetailBloc(mapApiService: getIt<MapApiService>())
            ..add(LoadProjectDetail(projectId: projectId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('项目详情'),
          elevation: 0,
          backgroundColor: AppTheme.getBusinessColor('project'),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state.isInitialLoading
                      ? null
                      : () {
                          context.read<ProjectDetailBloc>().add(
                            RefreshProjectDetail(projectId: projectId),
                          );
                        },
                  icon: state.hasAnyLoading
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
        body: BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
          builder: (context, state) {
            // 如果是初始加载状态，显示全局loading
            if (state.isInitialLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text('正在加载项目详情...'),
                  ],
                ),
              );
            }

            // 如果没有任何数据且都不在加载中，显示无数据状态
            if (!state.hasAnyData && !state.hasAnyLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.engineering_outlined,
                      size: 64,
                      color: AppTheme.grey400,
                    ),
                    SizedBox(height: AppTheme.spacingLarge),
                    Text('暂无项目数据', style: AppTheme.titleMedium),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProjectDetailBloc>().add(
                  RefreshProjectDetail(projectId: projectId),
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                children: [
                  // 项目基础信息 - 独立状态
                  _buildProjectBasicInfoSection(context, state),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // 项目统计信息 - 独立状态
                  _buildProjectStatisticsSection(context, state),
                  const SizedBox(height: AppTheme.spacingLarge),

                  // 具体材料统计 - 独立状态
                  _buildMaterialStatisticsSection(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建项目基础信息区域 - 独立状态
  Widget _buildProjectBasicInfoSection(
    BuildContext context,
    ProjectDetailState state,
  ) {
    return UnifiedCard(
      title: '项目基础信息',
      icon: Icons.engineering,
      businessType: 'project',
      child: _buildProjectBasicInfoContent(context, state),
    );
  }

  /// 构建项目基础信息内容
  Widget _buildProjectBasicInfoContent(
    BuildContext context,
    ProjectDetailState state,
  ) {
    // 加载中状态
    if (state.isProjectBaseLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.spacingMedium),
              Text('正在加载项目基础信息...'),
            ],
          ),
        ),
      );
    }

    // 错误状态
    if (state.hasProjectBaseError) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                '加载失败',
                style: AppTheme.titleSmall.copyWith(color: AppTheme.errorColor),
              ),
              if (state.projectBaseError != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  state.projectBaseError!,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMedium),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProjectDetailBloc>().add(
                    LoadProjectDetail(projectId: projectId),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getBusinessColor('project'),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 32),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 无数据状态
    if (state.projectBase == null) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.engineering_outlined,
                size: 48,
                color: AppTheme.grey400,
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Text('暂无项目基础信息'),
            ],
          ),
        ),
      );
    }

    // 有数据状态 - 原来的内容
    final projectBase = state.projectBase!;
    return Column(
      children: [
        InfoRow(
          label: '项目名称',
          value: projectBase.projectName,
          icon: Icons.title,
          iconColor: AppTheme.getBusinessColor('project'),
        ),
        if (projectBase.projectCode != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '项目编码',
            value: projectBase.projectCode!,
            icon: Icons.tag,
            iconColor: AppTheme.getBusinessColor('project'),
          ),
        ],
        if (projectBase.auditTime != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '立项时间',
            value: _formatTimestamp(projectBase.auditTime!),
            icon: Icons.calendar_today,
            iconColor: AppTheme.getBusinessColor('project'),
          ),
        ],
        if (projectBase.startTime != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '开工时间',
            value: _formatTimestamp(projectBase.startTime!),
            icon: Icons.play_arrow,
            iconColor: AppTheme.getBusinessColor('project'),
          ),
        ],
        if (projectBase.address != null) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          InfoRow(
            label: '位置',
            value: projectBase.address!,
            icon: Icons.location_on,
            iconColor: AppTheme.getBusinessColor('project'),
          ),
        ],

        // 各方信息（可点击查看详情）
        if (projectBase.construct != null &&
            projectBase.construct!.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingLarge),
          const Divider(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildOrgSection(
            context,
            '建设方',
            projectBase.construct!,
            Icons.account_balance,
            state.projectId!,
          ),
        ],
        if (projectBase.builder != null && projectBase.builder!.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          _buildOrgSection(
            context,
            '施工方',
            projectBase.builder!,
            Icons.construction,
            state.projectId!,
          ),
        ],
        if (projectBase.supervisor != null &&
            projectBase.supervisor!.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingMedium),
          _buildOrgSection(
            context,
            '监理方',
            projectBase.supervisor!,
            Icons.visibility,
            state.projectId!,
          ),
        ],
      ],
    );
  }

  /// 构建组织信息部分（可点击跳转）
  Widget _buildOrgSection(
    BuildContext context,
    String title,
    List<SimpleOrg> orgs,
    IconData icon,
    int projectId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getBusinessColor('project'),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        ...orgs.map((org) => _buildOrgItem(context, org, icon, projectId)),
      ],
    );
  }

  /// 构建可点击的组织项
  Widget _buildOrgItem(
    BuildContext context,
    SimpleOrg org,
    IconData icon,
    int projectId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectUsersPage(
                  projectId: projectId,
                  code: org.code,
                  orgName: org.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.getBusinessColorLight('project'),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: AppTheme.getBusinessColorMedium('project'),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: AppTheme.getBusinessColor('project'),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        org.name,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        org.code,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建项目统计信息区域 - 独立状态
  Widget _buildProjectStatisticsSection(
    BuildContext context,
    ProjectDetailState state,
  ) {
    return UnifiedCard(
      title: '项目统计数据',
      icon: Icons.bar_chart,
      businessType: 'project',
      child: _buildProjectStatisticsContent(context, state),
    );
  }

  /// 构建项目统计信息内容
  Widget _buildProjectStatisticsContent(
    BuildContext context,
    ProjectDetailState state,
  ) {
    // 加载中状态
    if (state.isProjectStatisticLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.spacingMedium),
              Text('正在加载项目统计数据...'),
            ],
          ),
        ),
      );
    }

    // 错误状态
    if (state.hasProjectStatisticError) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                '加载失败',
                style: AppTheme.titleSmall.copyWith(color: AppTheme.errorColor),
              ),
              if (state.projectStatisticError != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  state.projectStatisticError!,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMedium),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProjectDetailBloc>().add(
                    LoadProjectDetail(projectId: projectId),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getBusinessColor('project'),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 32),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 无数据状态
    if (state.projectStatistic == null) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_outlined, size: 48, color: AppTheme.grey400),
              SizedBox(height: AppTheme.spacingMedium),
              Text('暂无项目统计数据'),
            ],
          ),
        ),
      );
    }

    // 有数据状态 - 原来的内容
    final statistic = state.projectStatistic!;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: AppTheme.spacingMedium,
      crossAxisSpacing: AppTheme.spacingMedium,
      children: [
        _buildStatisticCard(
          '项目内材料数量(不包括载具)',
          statistic.num ?? 0,
          Icons.inventory,
          Colors.blue,
        ),
        _buildStatisticCard(
          '安装数量',
          statistic.installNum ?? 0,
          Icons.build,
          Colors.green,
        ),
        _buildStatisticCard(
          '1次收次数',
          statistic.acceptTimes ?? 0,
          Icons.done_all,
          Colors.orange,
        ),
        _buildStatisticCard(
          '载货数量',
          statistic.acceptNum ?? 0,
          Icons.local_shipping,
          Colors.purple,
        ),
        _buildStatisticCard(
          '退回数量',
          statistic.backNum ?? 0,
          Icons.undo,
          Colors.red,
        ),
        _buildStatisticCard(
          '废弃数量',
          statistic.destroyNum ?? 0,
          Icons.delete_forever,
          Colors.grey,
        ),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              value.toString(),
              style: AppTheme.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              title,
              style: AppTheme.labelSmall.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建具体材料统计区域 - 独立状态
  Widget _buildMaterialStatisticsSection(
    BuildContext context,
    ProjectDetailState state,
  ) {
    return UnifiedCard(
      title: '具体材料统计',
      icon: Icons.list_alt,
      businessType: 'project',
      child: _buildMaterialStatisticsContent(context, state),
    );
  }

  /// 构建具体材料统计内容
  Widget _buildMaterialStatisticsContent(
    BuildContext context,
    ProjectDetailState state,
  ) {
    // 加载中状态
    if (state.isMaterialStatisticsLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.spacingMedium),
              Text('正在加载材料统计数据...'),
            ],
          ),
        ),
      );
    }

    // 错误状态
    if (state.hasMaterialStatisticsError) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                '加载失败',
                style: AppTheme.titleSmall.copyWith(color: AppTheme.errorColor),
              ),
              if (state.materialStatisticsError != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  state.materialStatisticsError!,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.grey600),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMedium),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProjectDetailBloc>().add(
                    LoadProjectDetail(projectId: projectId),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getBusinessColor('project'),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 32),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 无数据状态
    if (state.materialStatistics.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppTheme.grey400,
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Text('暂无材料统计数据'),
            ],
          ),
        ),
      );
    }

    // 有数据状态 - 原来的内容
    return Column(
      children: state.materialStatistics
          .map(
            (material) => MaterialListItem(
              materialName: material.materialName ?? '未知材料',
              quantity: material.num,
              businessType: 'project',
              icon: _getMaterialIcon(material.materialType),
            ),
          )
          .toList(),
    );
  }

  /// 根据材料类型获取对应图标
  IconData _getMaterialIcon(int? materialType) {
    switch (materialType) {
      case 1:
        return Icons.plumbing; // 管材
      case 2:
        return Icons.settings; // 管件
      default:
        return Icons.inventory_2;
    }
  }

  /// 格式化时间戳为 YYYY-MM-DD 格式
  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
