import 'dart:async';
import 'dart:math';
import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/acceptance/acceptance_info_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/do_accept_sign_in_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/common_do_business_audit_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/sign_in_info_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/records/record_list_response.dart';
import 'package:pipe_code_flutter/models/records/business_record.dart';
import 'package:pipe_code_flutter/services/api/interfaces/acceptance_api_service.dart';

class MockAcceptanceApiService implements AcceptanceApiService {
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

  static const List<String> _projectNames = [
    '高新区供水改造项目',
    '工业园区管网建设',
    '老城区管网更新',
    '新区供水工程',
  ];

  static const List<String> _userNames = ['张三', '李四', '王五', '赵六', '孙七', '周八'];

  static const List<String> _supervisorNames = ['李明', '赵磊', '黄华'];

  static const List<String> _constructionNames = ['孙建国', '刘强', '陈伟'];

  static const List<String> _warehouseNames = ['王仓管', '李库管', '张管理'];

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
  }

  List<MaterialVO> _generateMockMaterials() {
    final count = 2 + _random.nextInt(4);
    return List.generate(count, (index) {
      return MaterialVO(
        materialId: 1000 + index,
        materialName: _materialNames[_random.nextInt(_materialNames.length)],
        num: 1 + _random.nextInt(5),
        installPileNo: 'K${_random.nextInt(100)}+${_random.nextInt(1000)}',
        installImageUrl1: '/uploads/images/install_${index}_1.jpg',
        installImageUrl2: '/uploads/images/install_${index}_2.jpg',
      );
    });
  }

  List<AttachmentVO> _generateMockAttachments() {
    return [
      AttachmentVO(
        type: 1,
        name: '报验单.pdf',
        url: '/uploads/docs/acceptance_report_${_random.nextInt(1000)}.pdf',
        attachFormat: 2,
      ),
      AttachmentVO(
        type: 2,
        name: '验收报告.pdf',
        url: '/uploads/docs/acceptance_audit_${_random.nextInt(1000)}.pdf',
        attachFormat: 2,
      ),
      AttachmentVO(
        type: 3,
        name: '现场照片1.jpg',
        url: '/uploads/images/site_photo_${_random.nextInt(1000)}.jpg',
        attachFormat: 1,
      ),
      AttachmentVO(
        type: 3,
        name: '现场照片2.jpg',
        url: '/uploads/images/site_photo_${_random.nextInt(1000)}.jpg',
        attachFormat: 1,
      ),
    ];
  }

  List<CommonUserVO> _generateMockUsers(List<String> names) {
    return names
        .map(
          (name) => CommonUserVO(
            userId: 1000 + _random.nextInt(100),
            realHandler: _random.nextBool(),
            name: name,
            phone:
                '138${_random.nextInt(100000000).toString().padLeft(8, '0')}',
            messageTo: _random.nextBool(),
          ),
        )
        .toList();
  }

  @override
  Future<Result<void>> submitAcceptance(DoAcceptVO request) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.1) {
      return Result(code: -1, msg: '提交失败，请检查网络连接', data: null);
    }

    return Result(code: 0, msg: 'success', data: null);
  }

  @override
  Future<Result<void>> auditAcceptance(CommonDoBusinessAuditVO request) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.05) {
      return Result(code: -1, msg: '审核失败，请重试', data: null);
    }

    return Result(code: 0, msg: 'success', data: null);
  }

  @override
  Future<Result<AcceptanceInfoVO>> getAcceptanceDetail(int id) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.05) {
      return Result(code: -1, msg: '获取详情失败，请重试', data: null);
    }

    final materials = _generateMockMaterials();
    final attachments = _generateMockAttachments();

    final acceptanceInfo = AcceptanceInfoVO(
      materialList: materials,
      imageList: attachments,
      sendAcceptUrl: '/uploads/docs/send_accept_${id}.pdf',
      acceptReportUrl: '/uploads/docs/accept_report_${id}.pdf',
      realWarehouse: _random.nextBool(),
      warehouseId: 1000 + _random.nextInt(10),
      warehouseUsers: _generateMockUsers(_warehouseNames),
      supervisorUsers: _generateMockUsers(_supervisorNames),
      constructionUsers: _generateMockUsers(_constructionNames),
      signInInfo: SignInInfoVO(
        materialList: materials,
        imageList: attachments.where((a) => a.type == 3).toList(),
        warehouseId: 1000 + _random.nextInt(10),
      ),
      acceptStatus: _random.nextInt(5), // 模拟状态
      acceptStatusName: ['待审核', '已审核', '已入库', '已完成', '已取消'][_random.nextInt(5)],
    );

    return Result(code: 0, msg: 'success', data: acceptanceInfo);
  }

  @override
  Future<Result<RecordListResponse>> getAcceptanceList({
    int? projectId,
    int? userId,
    int? pageNum,
    int? pageSize,
  }) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.05) {
      return Result(code: -1, msg: '获取列表失败，请重试', data: null);
    }

    final currentPage = pageNum ?? 1;
    final size = pageSize ?? 10;
    final total = 25 + _random.nextInt(50);

    final records = List.generate(
      size,
      (index) => BusinessRecord(
        id: (currentPage - 1) * size + index + 1,
        bizType: 1, // 验收业务类型
        projectName: _projectNames[_random.nextInt(_projectNames.length)],
        projectCode: 'PRJ${_random.nextInt(1000).toString().padLeft(4, '0')}',
        materialNum: 1 + _random.nextInt(10),
        userName: _userNames[_random.nextInt(_userNames.length)],
        doTime: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ),
    );

    final pageData = BusinessRecordPageData(
      records: records,
      total: total,
      size: size,
      current: currentPage,
    );

    final response = RecordListResponse(
      code: 0,
      msg: 'success',
      data: pageData,
    );

    return Result(code: 0, msg: 'success', data: response);
  }

  @override
  Future<Result<void>> doAcceptanceSignIn(DoAcceptSignInVO request) async {
    await _simulateNetworkDelay();

    if (_random.nextDouble() < 0.05) {
      return Result(code: -1, msg: '入库失败，请重试', data: null);
    }

    return Result(code: 0, msg: 'success', data: null);
  }
}
