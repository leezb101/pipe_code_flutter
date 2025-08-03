/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 19:12:01
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/repositories/implementations/inventory_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/inventory_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/return_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/return_repository.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/acceptance_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/auth_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/auth_repository_impl.dart';
import 'package:pipe_code_flutter/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/dispatch_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/enum_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/enum_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/install_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/install_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/list_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/list_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/material_handle_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/project_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/project_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/records_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/records_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/signout_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/signout_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/spareqr_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/spareqr_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/user_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/user_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/cut_repository_impl.dart';
import 'package:pipe_code_flutter/repositories/interfaces/scrap_repository.dart';
import 'package:pipe_code_flutter/repositories/implementations/scrap_repository_impl.dart';

/// Repository 工厂
///
/// 负责创建和提供所有 Repository 的实例。
/// 这是一个中心化的位置，用于管理数据仓库的依赖注入。
class RepositoryFactory {
  /// 创建并返回一个 [ScrapRepository] 实例。
  static ScrapRepository createScrapRepository() {
    final scrapApiService = ApiServiceFactory.createScrapService();
    return ScrapRepositoryImpl(scrapApiService);
  }

  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 创建并返回一个 [ReturnRepository] 实例。
  static ReturnRepository createReturnRepository() {
    // 从 ApiServiceFactory 获取 ReturnApiService 的实例
    final returnApiService = ApiServiceFactory.createReturnService();

    // 创建并返回 ReturnRepositoryImpl，并注入其依赖
    return ReturnRepositoryImpl(returnApiService);
  }

  /// 创建并返回一个 [AcceptanceRepository] 实例。
  static AcceptanceRepository createAcceptanceRepository() {
    // 从 ApiServiceFactory 获取 AcceptanceApiService 和 CommonQueryApiService 的实例
    final acceptanceApiService = ApiServiceFactory.createAcceptanceService();
    final commonQueryApiService = ApiServiceFactory.createCommonQueryService();

    // 创建并返回 AcceptanceRepositoryImpl，并注入其依赖
    return AcceptanceRepositoryImpl(
      acceptanceApiService,
      commonQueryApiService,
    );
  }

  /// 创建并返回一个 [AuthRepository] 实例。
  static Future<AuthRepository> createAuthRepository() async {
    await _initPrefs();
    final apiService = ApiServiceFactory.create();
    final storageService = StorageService(_prefs!);

    return AuthRepositoryImpl(
      apiService: apiService,
      storageService: storageService,
    );
  }

  /// 创建并返回一个 [DispatchRepository] 实例。
  static DispatchRepository createDispatchRepository() {
    final dispatchApiService = ApiServiceFactory.createDispatchService();
    return DispatchRepositoryImpl(dispatchApiService);
  }

  /// 创建并返回一个 [EnumRepository] 实例。
  static EnumRepository createEnumRepository() {
    final enumApiService = ApiServiceFactory.createEnumService();
    return EnumRepositoryImpl(enumApiService);
  }

  /// 创建并返回一个 [InstallRepository] 实例。
  static InstallRepository createInstallRepository() {
    final installApiService = ApiServiceFactory.createInstallApiService();
    final commonQueryApiService = ApiServiceFactory.createCommonQueryService();
    return InstallRepositoryImpl(installApiService, commonQueryApiService);
  }

  /// 创建并返回一个 [ListRepository] 实例。
  static ListRepository createListRepository() {
    final apiService = ApiServiceFactory.create();
    return ListRepositoryImpl(apiService: apiService);
  }

  /// 创建并返回一个 [MaterialHandleRepository] 实例。
  static MaterialHandleRepository createMaterialHandleRepository() {
    final materialHandleApiService =
        ApiServiceFactory.createMaterialHandleService();
    return MaterialHandleRepositoryImpl(materialHandleApiService);
  }

  /// 创建并返回一个 [ProjectRepository] 实例。
  static Future<ProjectRepository> createProjectRepository() async {
    await _initPrefs();
    final apiService = ApiServiceFactory.create();
    final storageService = StorageService(_prefs!);

    return ProjectRepositoryImpl(
      apiService: apiService,
      storageService: storageService,
    );
  }

  /// 创建并返回一个 [RecordsRepository] 实例。
  static RecordsRepository createRecordsRepository() {
    final recordsApiService = ApiServiceFactory.createRecordsService();
    final todoApiService = ApiServiceFactory.createTodoService();
    return RecordsRepositoryImpl(recordsApiService, todoApiService);
  }

  /// 创建并返回一个 [SignoutRepository] 实例。
  static SignoutRepository createSignoutRepository() {
    final signoutApiService = ApiServiceFactory.createSignoutService();
    final commonQueryApiService = ApiServiceFactory.createCommonQueryService();
    return SignoutRepositoryImpl(signoutApiService, commonQueryApiService);
  }

  /// 创建并返回一个 [SpareqrRepository] 实例。
  static SpareqrRepository createSpareqrRepository() {
    final apiService = ApiServiceFactory.create();
    return SpareqrRepositoryImpl(apiservice: apiService);
  }

  /// 创建并返回一个 [UserRepository] 实例。
  static Future<UserRepository> createUserRepository() async {
    await _initPrefs();
    final apiService = ApiServiceFactory.create();
    final storageService = StorageService(_prefs!);

    return UserRepositoryImpl(
      apiService: apiService,
      storageService: storageService,
    );
  }

  /// 创建并返回一个 [CutRepository] 实例。
  static CutRepository createCutRepository() {
    final cutApiService = ApiServiceFactory.createCutService();
    return CutRepositoryImpl(cutApiService);
  }

  /// 创建并返回一个 [InventoryRepository] 实例。
  static InventoryRepository createInventoryRepository() {
    final inventoryApiService = ApiServiceFactory.createInventoryService();
    return InventoryRepositoryImpl(apiService: inventoryApiService);
  }
}
