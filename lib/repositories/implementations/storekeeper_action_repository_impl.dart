/*
 * @Author: LeeZB
 * @Date: 2025-08-23 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_signin_request.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';
import 'package:pipe_code_flutter/repositories/interfaces/storekeeper_action_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/storekeeper_action_api_service.dart';

class StorekeeperActionRepositoryImpl implements StorekeeperActionRepository {
  const StorekeeperActionRepositoryImpl(this._storekeeperActionApiService);

  final StorekeeperActionApiService _storekeeperActionApiService;

  @override
  Future<Result<List<StorekeeperWarehouseItem>>> getStorekeeperWarehouses() {
    return _storekeeperActionApiService.getStorekeeperWarehouses();
  }

  @override
  Future<Result<void>> storekeeperSigninWithoutProject(
    StorekeeperSigninRequest request,
  ) {
    return _storekeeperActionApiService.storekeeperSigninWithoutProject(
      request,
    );
  }
}
