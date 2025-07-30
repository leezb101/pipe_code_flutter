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

abstract class InstallRepository {
  Future<Result<InstallDetailVo>> getInstallDetail(int id);
  Future<Result<void>> doInstall(DoInstallVo request);
}
