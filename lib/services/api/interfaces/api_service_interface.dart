/*
 * @Author: LeeZB
 * @Date: 2025-07-09 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:07:35
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/project_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/qq_lbs_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/recovery_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/scrap_api_service.dart';

import 'enum_api_service.dart';
import 'install_api_service.dart';
import 'signout_api_service.dart';
import 'spareqr_api_service.dart';
import 'auth_api_service.dart';
import 'user_api_service.dart';
import 'list_api_service.dart';
import 'acceptance_api_service.dart';
import 'common_query_api_service.dart';
import 'material_handle_api_service.dart';
import 'dispatch_api_service.dart';
import 'return_api_service.dart';
import 'cut_api_service.dart';
import 'inventory_api_service.dart';
import 'signin_api_service.dart';
import 'temporary_auth_api_service.dart';
import 'map_api_service.dart';
import 'chanage_password_api_service.dart';

abstract class ApiServiceInterface {
  AuthApiService get auth;
  UserApiService get user;
  ProjectApiService get project;
  ListApiService get list;
  SpareqrApiService get spare;
  AcceptanceApiService get acceptance;
  CommonQueryApiService get commonQuery;
  EnumApiService get enums;
  MaterialHandleApiService get materialHandle;
  SignoutApiService get signout;
  InstallApiService get install;
  DispatchApiService get dispatch;
  ReturnApiService get returnApi;
  CutApiService get cut;
  InventoryApiService get inventory;
  ScrapApiService get scrap;
  RecoveryApiService get recovery;
  SigninApiService get signin;
  TemporaryAuthApiService get temporaryAuth;
  MapApiService get mapApi;
  ChangePasswordApiService get changePassword;
  QQLbsApiService get qqLbs;
}
