/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:59:30
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:14:28
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';
import 'package:pipe_code_flutter/models/install/install_detail_vo.dart';

abstract class InstallApiService {
  /// 查看安装操作详情
  Future<Result<InstallDetailVo>> getInstallDetail(int id);

  /// 安装责任人发起安装
  Future<Result<void>> doInstall(DoInstallVo request);
}
