/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:55:34
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 18:56:15
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';

class InstallDetailVo extends DoInstallVo {
  const InstallDetailVo({
    required super.materialList,
    required super.imageList,
    super.installQualityUrl,
    super.onlyInstall,
    required super.signOutId,
  });
}
