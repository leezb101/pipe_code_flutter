import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/install_api_service.dart';

class InstallApiServiceImpl extends BaseApiService
    implements InstallApiService {
  InstallApiServiceImpl(super.dio);

  @override
  Future<Result<InstallDetailVo>> getInstallDetail(int id) async {
    final response = await dio.get(
      '/install/detail',
      queryParameters: {'id': id},
    );
    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'InstallDetailVo',
      );

      if (result.isSuccess && result.data != null) {
        final installDetail = InstallDetailVo.fromJson(
          result.data as Map<String, dynamic>,
        );
        return Result(code: 0, msg: 'success', data: installDetail);
      } else {
        return Result(
          code: result.code,
          msg: result.msg ?? '获取安装详情失败',
          data: null,
        );
      }
    } else {
      return Result(code: -1, msg: '获取安装详情失败，请重试', data: null);
    }
  }

  @override
  Future<Result<void>> doInstall(DoInstallVo request) async {
    final response = await dio.post('/install/do', data: request);

    if (response.statusCode == 200) {
      final result = Result.safeFromJson(
        response.data,
        (json) => json,
        'DoInstall',
      );

      if (result.isSuccess) {
        return Result(code: 0, msg: 'success');
      } else {
        return Result(code: result.code, msg: result.msg ?? '安装失败');
      }
    } else {
      return Result(code: -1, msg: '安装失败，请重试');
    }
  }
}
