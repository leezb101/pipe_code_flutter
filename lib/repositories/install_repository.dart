/*
 * @Author: LeeZB
 * @Date: 2025-07-25 19:21:54
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:26:36
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import 'package:pipe_code_flutter/services/api/interfaces/install_api_service.dart';

class InstallRepository {
  final InstallApiService _installApiService;
  final CommonQueryApiService _commonQueryApiService;

  InstallRepository(this._installApiService, this._commonQueryApiService);

  /// 查看安装操作详情
  Future<Result<InstallDetailVo>> getInstallDetail(int id) async {
    try {
      final result = await _installApiService.getInstallDetail(id);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '获取安装操作详情失败，请检查网络连接', data: null);
    }
  }

  /// 提交安装请求
  Future<Result<void>> doInstall(DoInstallVo request) async {
    try {
      final result = await _installApiService.doInstall(request);
      return result;
    } catch (e) {
      return Result(code: -1, msg: '提交安装请求失败，请检查网络连接', data: null);
    }
  }
}
