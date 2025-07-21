/*
 * @Author: LeeZB
 * @Date: 2025-07-09 10:15:25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 10:26:09
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/services/api/interfaces/spareqr_api_service.dart';

import 'auth_api_service.dart';
import 'user_api_service.dart';
import 'list_api_service.dart';
import 'acceptance_api_service.dart';
import 'common_query_api_service.dart';

abstract class ApiServiceInterface {
  AuthApiService get auth;
  UserApiService get user;
  ListApiService get list;
  SpareqrApiService get spare;
  AcceptanceApiService get acceptance;
  CommonQueryApiService get commonQuery;
}
