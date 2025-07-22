/*
 * @Author: LeeZB
 * @Date: 2025-07-18 17:42:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 16:38:35
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:dio/dio.dart';
import 'package:pipe_code_flutter/services/api/implementations/common_query_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/enum_api_service_impl.dart';
import 'package:pipe_code_flutter/services/api/implementations/spareqr_service_impl.dart';
import 'package:pipe_code_flutter/services/api/interfaces/enum_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';
import '../interfaces/api_service_interface.dart';
import '../interfaces/auth_api_service.dart';
import '../interfaces/common_query_api_service.dart';
import '../interfaces/user_api_service.dart';
import '../interfaces/list_api_service.dart';
import '../interfaces/acceptance_api_service.dart';
import 'auth_api_service_impl.dart';
import 'user_api_service_impl.dart';
import 'list_api_service_impl.dart';
import 'acceptance_api_service_impl.dart';

class ApiServiceImpl implements ApiServiceInterface {
  final Dio _dio;

  AuthApiService? _authService;
  UserApiService? _userService;
  ListApiService? _listService;
  SpareqrApiService? _spareService;
  AcceptanceApiService? _acceptanceService;
  CommonQueryApiService? _commonQueryService;

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
}
