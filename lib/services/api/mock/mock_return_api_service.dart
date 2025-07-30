import 'dart:async';
import 'dart:math';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/return/do_return_req_vo.dart';
import 'package:pipe_code_flutter/models/return/return_detail_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/services/api/interfaces/return_api_service.dart';

class MockReturnApiService implements ReturnApiService {
  final Random _random = Random();

  static const List<String> _materialNames = [
    'PE管材 DN110',
    'PE管材 DN160',
    'PE管材 DN200',
    'PE管材 DN250',
    '球墨铸铁管 DN100',
    '球墨铸铁管 DN150',
    '钢管 DN80',
    '钢管 DN100',
    '阀门 DN50',
    '阀门 DN100',
    '三通 DN110',
    '弯头 DN160',
  ];

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
  }

  List<MaterialVO> _generateMockMaterials() {
    final count = 1 + _random.nextInt(5);
    return List.generate(count, (index) {
      return MaterialVO(
        materialId: 1000 + index,
        materialName: _materialNames[_random.nextInt(_materialNames.length)],
        num: 1 + _random.nextInt(10),
        installPileNo: 'K${_random.nextInt(100)}+${_random.nextInt(1000)}',
        installImageUrl1: '/uploads/images/install_${index}_1.jpg',
        installImageUrl2: '/uploads/images/install_${index}_2.jpg',
      );
    });
  }

  List<AttachmentVO> _generateMockAttachments() {
    final count = 1 + _random.nextInt(3);
    return List.generate(count, (index) {
      return AttachmentVO(
        type: 3,
        name: '退库照片${index + 1}.jpg',
        url: '/uploads/images/return_photo_${_random.nextInt(1000)}.jpg',
        attachFormat: 'jpg',
      );
    });
  }

  @override
  Future<Result<ReturnDetailVo>> getReturnDetail(int id) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.05) {
      return Result(code: -1, msg: '获取退库详情失败，请重试', data: null);
    }

    final materials = _generateMockMaterials();
    final attachments = _generateMockAttachments();
    final returnType = _random.nextInt(2); // 0 或 1

    final returnDetail = ReturnDetailVo(
      materialList: materials,
      imageList: attachments,
      returnType: returnType,
      returnRemark: returnType == 0 ? '质量不合格，申请退库' : '工程多余件，申请退库',
    );

    return Result(code: 0, msg: 'success', data: returnDetail);
  }

  @override
  Future<Result<void>> doReturn(DoReturnReqVo request) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.1) {
      return Result(code: -1, msg: '退库申请提交失败，请检查网络连接', data: null);
    }

    return Result(code: 0, msg: 'success', data: null);
  }
}