/*
 * @Author: LeeZB
 * @Date: 2025-07-25 19:20:36
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:21:25
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/install_api_service.dart';

class MockInstallApiService implements InstallApiService {
  @override
  Future<Result<void>> doInstall(DoInstallVo request) {
    // TODO: implement doSignout
    throw UnimplementedError();
  }

  @override
  Future<Result<InstallDetailVo>> getInstallDetail(int id) {
    // TODO: implement getSignoutDetail
    throw UnimplementedError();
  }
}
