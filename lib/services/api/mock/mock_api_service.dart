/*
 * @Author: LeeZB
 * @Date: 2025-07-09 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:21:36
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/material_handle_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_install_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_material_handle_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_signout_api_service.dart';
import 'package:pipe_code_flutter/services/api/mock/mock_spareqr_api_service.dart';

import '../interfaces/api_service_interface.dart';
import '../interfaces/auth_api_service.dart';
import '../interfaces/user_api_service.dart';
import '../interfaces/list_api_service.dart';
import '../interfaces/acceptance_api_service.dart';
import '../interfaces/install_api_service.dart';
import 'mock_auth_api_service.dart';
import 'mock_user_api_service.dart';
import 'mock_list_api_service.dart';
import 'mock_acceptance_api_service.dart';

class MockApiService implements ApiServiceInterface {
  AuthApiService? _authService;
  UserApiService? _userService;
  ListApiService? _listService;
  SpareqrApiService? _spareqrService;
  AcceptanceApiService? _acceptanceService;
  CommonQueryApiService? _commonQueryService;
  EnumApiService? _enumService;
  MaterialHandleApiService? _materialHandleService;
  SignoutApiService? _signoutApiService;
  InstallApiService? _installApiService;

  @override
  AuthApiService get auth => _authService ??= MockAuthApiService();

  @override
  UserApiService get user => _userService ??= MockUserApiService();

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
}
