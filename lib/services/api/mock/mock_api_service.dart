/*
 * @Author: LeeZB
 * @Date: 2025-07-09 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:09:05
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/chanage_password_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/dispatch_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/inventory_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/material_handle_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/project_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/recovery_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signin_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/temporary_auth_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_install_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_material_handle_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_project_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_recovery_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_scrap_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_signin_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_spareqr_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_temporary_auth_api_service.dart';

import '../interfaces/api_service_interface.dart';
import '../interfaces/auth_api_service.dart';
import '../interfaces/cut_api_service.dart';
import '../interfaces/return_api_service.dart';
import '../interfaces/user_api_service.dart';
import '../interfaces/list_api_service.dart';
import '../interfaces/acceptance_api_service.dart';
import '../interfaces/install_api_service.dart';
import '../interfaces/map_api_service.dart';
import '../interfaces/qq_lbs_api_service.dart';
import '../interfaces/profile_api_service.dart';
import 'mock_auth_api_service.dart';
import 'mock_cut_api_service.dart';
import 'mock_dispatch_api_service.dart';
import 'mock_user_api_service.dart';
import 'mock_list_api_service.dart';
import 'mock_acceptance_api_service.dart';
import 'mock_return_api_service.dart';
import 'mock_inventory_api_service.dart';
import 'mock_map_api_service.dart';
import 'mock_qq_lbs_api_service.dart';
import 'mock_profile_api_service.dart';

class MockApiService implements ApiServiceInterface {
  AuthApiService? _authService;
  UserApiService? _userService;
  ProjectApiService? _projectService;
  ListApiService? _listService;
  SpareqrApiService? _spareqrService;
  AcceptanceApiService? _acceptanceService;
  CommonQueryApiService? _commonQueryService;
  EnumApiService? _enumService;
  MaterialHandleApiService? _materialHandleService;
  SignoutApiService? _signoutApiService;
  InstallApiService? _installApiService;
  DispatchApiService? _dispatchApiService;
  ReturnApiService? _returnApiService;
  CutApiService? _cutApiService;
  InventoryApiService? _inventoryApiService;
  ScrapApiService? _scrapApiService;
  RecoveryApiService? _recoveryApiService;
  SigninApiService? _signinApiService;
  TemporaryAuthApiService? _temporaryAuthApiService;
  MapApiService? _mapApiService;
  QQLbsApiService? _qqLbsApiService;
  ProfileApiService? _profileApiService;

  @override
  AuthApiService get auth => _authService ??= MockAuthApiService();

  @override
  UserApiService get user => _userService ??= MockUserApiService();

  @override
  ProjectApiService get project => _projectService ??= MockProjectApiService();

  @override
  ListApiService get list => _listService ??= MockListApiService();

  @override
  SpareqrApiService get spare => _spareqrService ??= MockSpareqrApiService();

  @override
  AcceptanceApiService get acceptance =>
      _acceptanceService ??= MockAcceptanceApiService();

  @override
  CommonQueryApiService get commonQuery =>
      _commonQueryService ??= MockCommonQueryApiService();

  @override
  EnumApiService get enums => _enumService ??= MockEnumApiService();

  @override
  MaterialHandleApiService get materialHandle =>
      _materialHandleService ??= MockMaterialHandleApiService();

  @override
  SignoutApiService get signout =>
      _signoutApiService ??= MockSignoutApiService();

  @override
  InstallApiService get install =>
      _installApiService ??= MockInstallApiService();

  @override
  DispatchApiService get dispatch =>
      _dispatchApiService ??= MockDispatchApiService();

  @override
  ReturnApiService get returnApi =>
      _returnApiService ??= MockReturnApiService();

  @override
  CutApiService get cut => _cutApiService ??= MockCutApiService();

  @override
  InventoryApiService get inventory =>
      _inventoryApiService ??= MockInventoryApiService();

  @override
  ScrapApiService get scrap => _scrapApiService ??= MockScrapApiService();

  @override
  RecoveryApiService get recovery =>
      _recoveryApiService ??= MockRecoveryApiService();

  @override
  SigninApiService get signin => _signinApiService ??= MockSigninApiService();

  @override
  TemporaryAuthApiService get temporaryAuth =>
      _temporaryAuthApiService ??= MockTemporaryAuthApiService();

  @override
  MapApiService get mapApi => _mapApiService ??= MockMapApiService();

  @override
  ChangePasswordApiService get changePassword => throw UnimplementedError();

  @override
  QQLbsApiService get qqLbs => _qqLbsApiService ??= MockQQLbsApiService();

  @override
  ProfileApiService get profile =>
      _profileApiService ??= MockProfileApiService();
}
