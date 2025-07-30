/*
 * @Author: LeeZB
 * @Date: 2025-07-18 17:42:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 11:22:09
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import 'common_query_api_service_impl.dart';
import 'dispatch_api_service_impl.dart';
import 'enum_api_service_impl.dart';
import 'material_handle_api_service_impl.dart';
import 'spareqr_service_impl.dart';
import '../interfaces/enum_api_service.dart';
import '../interfaces/material_handle_api_service.dart';
import '../interfaces/spareqr_api_service.dart';
import '../interfaces/api_service_interface.dart';
import '../interfaces/auth_api_service.dart';
import '../interfaces/common_query_api_service.dart';
import '../interfaces/install_api_service.dart';
import '../interfaces/user_api_service.dart';
import '../interfaces/list_api_service.dart';
import '../interfaces/acceptance_api_service.dart';
import '../interfaces/signout_api_service.dart';
import '../interfaces/dispatch_api_service.dart';
import '../interfaces/return_api_service.dart';
import 'auth_api_service_impl.dart';
import 'install_api_service_impl.dart';
import 'user_api_service_impl.dart';
import 'list_api_service_impl.dart';
import 'acceptance_api_service_impl.dart';
import 'signout_api_service_impl.dart';
import 'return_api_service_impl.dart';

class ApiServiceImpl implements ApiServiceInterface {
  final Dio _dio;

  AuthApiService? _authService;
  UserApiService? _userService;
  ListApiService? _listService;
  SpareqrApiService? _spareService;
  AcceptanceApiService? _acceptanceService;
  CommonQueryApiService? _commonQueryService;
  MaterialHandleApiService? _materialHandleService;
  SignoutApiService? _signoutApiService;
  InstallApiService? _installApiService;
  DispatchApiService? _dispatchApiService;
  ReturnApiService? _returnApiService;

  ApiServiceImpl(this._dio);

  @override
  AuthApiService get auth => _authService ??= AuthApiServiceImpl(_dio);

  @override
  UserApiService get user => _userService ??= UserApiServiceImpl(_dio);

  @override
  ListApiService get list => _listService ??= ListApiServiceImpl(_dio);

  @override
  SpareqrApiService get spare => _spareService ??= SpareqrServiceImpl(_dio);

  @override
  AcceptanceApiService get acceptance =>
      _acceptanceService ??= AcceptanceApiServiceImpl(_dio);

  @override
  CommonQueryApiService get commonQuery =>
      _commonQueryService ??= CommonQueryApiServiceImpl(_dio);

  @override
  EnumApiService get enums => EnumApiServiceImpl(_dio);

  @override
  MaterialHandleApiService get materialHandle =>
      _materialHandleService ??= MaterialHandleApiServiceImpl(_dio);

  @override
  SignoutApiService get signout =>
      _signoutApiService ?? SignoutApiServiceImpl(_dio);

  @override
  InstallApiService get install =>
      _installApiService ??= InstallApiServiceImpl(_dio);

  @override
  DispatchApiService get dispatch =>
      _dispatchApiService ??= DispatchApiServiceImpl(_dio);

  @override
  ReturnApiService get returnApi =>
      _returnApiService ??= ReturnApiServiceImpl(_dio);
}
