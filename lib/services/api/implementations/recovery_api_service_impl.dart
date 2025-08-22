import 'package:dio/src/dio.dart';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/scan_identification_response.dart';
import 'package:pipe_code_flutter/models/recovery/material_categories.dart';
import 'package:pipe_code_flutter/models/recovery/vendors_map.dart';
import 'package:pipe_code_flutter/services/api/implementations/base_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/recovery_api_service.dart';

class RecoveryApiServiceImpl extends BaseApiService
    implements RecoveryApiService {
  RecoveryApiServiceImpl(super.dio);

  @override
  Future<Result<VendorsMap>> getVendorsMap() async {
    try {
      final response = await dio.get('/r/b/vendor');
      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => VendorsMap.fromJson(json as Map<String, dynamic>),
          'VendorsMap',
        );
        return result;
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '获取供应商映射失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(code: -1, msg: 'Failed to fetch vendors map', data: null);
    }
  }

  @override
  Future<Result<MaterialCategoriesList>> getMaterialCategories(
    String code,
  ) async {
    try {
      final response = await dio.get('/r/b/info1/$code');
      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => MaterialCategoriesList.fromJson(json as List<dynamic>),
          'MaterialCategoriesList',
        );
        return result;
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '获取物料分类失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(
        code: -1,
        msg: 'Failed to fetch material categories',
        data: null,
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> submitStep3Fields({
    required String code,
    required int type,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final response = await dio.post(
        '/r/b/copy/1/$code/$type',
        data: {'key': fields},
      );
      if (response.statusCode == 200) {
        final result = Result.safeFromJson(
          response.data,
          (json) => json,
          'ScanIdentificationData',
        );
        final Map<String, dynamic> withHeaderKey = {
          'data': result.data,
          'key': response.headers['key'],
        };
        return Result<Map<String, dynamic>>(
          code: result.code,
          msg: result.msg,
          data: withHeaderKey,
        );
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '提交失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(code: -1, msg: '提交失败：$e', data: null);
    }
  }

  @override
  Future<Result<void>> submitStep4Fields(String qrCode, String key) async {
    try {
      final response = await dio.post(
        '/r/b/copy/2',
        data: {'qrCode': qrCode, 'key': key},
      );
      if (response.statusCode == 200) {
        return Result<void>(code: 0, msg: '提交成功', data: null);
      } else {
        return Result(
          code: response.data['code'] ?? -1,
          msg: response.data['msg'] ?? '提交失败',
          data: null,
        );
      }
    } catch (e) {
      return Result(code: -1, msg: '提交失败：$e', data: null);
    }
  }
}
