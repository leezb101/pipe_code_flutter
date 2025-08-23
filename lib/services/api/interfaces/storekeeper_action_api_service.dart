import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_signin_request.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';

abstract class StorekeeperActionApiService {
  Future<Result<List<StorekeeperWarehouseItem>>> getStorekeeperWarehouses();

  Future<Result<void>> storekeeperSigninWithoutProject(
    StorekeeperSigninRequest request,
  );
}
