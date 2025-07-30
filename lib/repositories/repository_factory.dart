/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 16:10:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/repositories/implementations/return_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';

/// Repository 工厂
///
/// 负责创建和提供所有 Repository 的实例。
/// 这是一个中心化的位置，用于管理数据仓库的依赖注入。
class RepositoryFactory {
  /// 创建并返回一个 [ReturnRepository] 实例。
  static ReturnRepository createReturnRepository() {
    // 从 ApiServiceFactory 获取 ReturnApiService 的实例
    final returnApiService = ApiServiceFactory.createReturnService();

    // 创建并返回 ReturnRepositoryImpl，并注入其依赖
    return ReturnRepositoryImpl(returnApiService);
  }
}
