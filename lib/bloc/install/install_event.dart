/*
 * @Author: LeeZB
 * @Date: 2025-07-25 19:28:16
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:56:58
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-25 19:28:16
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-25 19:42:54
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/install/do_install_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

abstract class InstallEvent extends Equatable {
  const InstallEvent();

  @override
  List<Object?> get props => [];
}

class LoadInstallDetail extends InstallEvent {
  final int id;

  const LoadInstallDetail({required this.id});
  @override
  List<Object?> get props => [id];
}

class DoInstall extends InstallEvent {
  final DoInstallVo request;

  const DoInstall({required this.request});

  @override
  List<Object?> get props => [request];
}

class RefreshInstallDetail extends InstallEvent {
  final int id;

  const RefreshInstallDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class AppendScannedMaterial extends InstallEvent {
  final MaterialInfoForBusiness materialInfo;

  const AppendScannedMaterial({required this.materialInfo});

  @override
  List<Object?> get props => [materialInfo];
}
