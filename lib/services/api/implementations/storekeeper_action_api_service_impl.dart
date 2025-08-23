import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_signin_request.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/storekeeper_action_api_service.dart';

class StorekeeperActionApiServiceImpl extends BaseApiService
    implements StorekeeperActionApiService {
  StorekeeperActionApiServiceImpl(super.dio);

  @override
  Future<Result<List<StorekeeperWarehouseItem>>>
  getStorekeeperWarehouses() async {
    try {
      final response = await dio.get('/wr/detail');
      if (response.statusCode == 200 && response.data != null) {
        final result = Result.safeFromJson(
          response.data,
          (json) => (json as List)
              .map((item) => StorekeeperWarehouseItem.fromJson(item))
              .toList(),
          'StorekeeperWarehouseItem',
        );
        return result;
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '获取仓库列表失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(code: -1, msg: '获取仓库列表失败$e', data: null);
    }
  }

  @override
  Future<Result<void>> storekeeperSigninWithoutProject(
    StorekeeperSigninRequest request,
  ) async {
    try {
      final response = await dio.post('/wr/save', data: request);
      if (response.statusCode == 200) {
        return Result(code: 0, msg: '入库成功', data: null);
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '入库失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(code: -1, msg: '入库失败:$e', data: null);
    }
  }
}
