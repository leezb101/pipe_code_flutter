/*
 * @Author: LeeZB
 * @Date: 2025-07-25 18:55:34
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 18:57:45
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';

/// [InstallDetailVo] extends [DoInstallVo] and serves as a placeholder for future fields or methods specific to installation details.
class InstallDetailVo extends DoInstallVo {
  const InstallDetailVo({
    required super.materialList,
    required super.imageList,
    super.installQualityUrl,
    super.onlyInstall,
    required super.signOutId,
  });
}
