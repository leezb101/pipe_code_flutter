/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 18:09:22
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-20 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../../models/material/scan_identification_response.dart';
import '../../../models/material/material_info_base.dart';
import '../../../models/common/result.dart';
import '../interfaces/identification_api_service.dart';

/// Mock扫码识别API服务实现
class MockIdentificationApiService implements IdentificationApiService {
  @override
  Future<Result<ScanIdentificationData>> scanMaterialIdentification(
    String code,
  ) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 根据不同的扫码内容返回不同的模拟数据
    final data = _getMockDataByCode(code);
    return Result(code: 0, msg: '成功', data: data);
  }

  ScanIdentificationData _getMockDataByCode(String code) {
    // 根据扫码内容返回不同类型的材料数据
    if (code.contains('729960879520481280')) {
      return _createMockData(
        code: code,
        type: 0, // 球墨铸铁
        group: 0, // 管材
        materialCode: 'xxtest0001',
        productName: 'K9级球墨铸铁管',
        extendedFields: {
          'matGradeParam': 'FCD450',
          'posDev': '+0.8%',
          'len': null,
          'graphSpherRate': '≥92%',
          'pipeGskMatBrand': '硅橡胶-戈尔',
          'extCorrProtType': '沥青防腐',
          'extCorrProtStd': 'ASTM A716',
          'extCorrProtThk': '1.5mm',
          'extCorrProtAppPerfInsp': '漆膜完整，无剥落',
          'intCorrProtType': '普通水泥砂浆',
          'intCorrProtStd': 'CJ/T 120',
          'intCorrProtThk': '3.0mm',
          'intCorrProtAppPerfInsp': '衬里密实，无空鼓',
          'chemCompInsp': '微量元素合格',
          'mechPerfInsp': '抗冲击韧性好',
          'nonDsInsp': '射线探伤结果通过',
        },
      );
    } else if (code.contains('729960875670110208')) {
      return _createMockData(
        code: code,
        type: 1, // 钢管
        group: 0, // 管材
        materialCode: 'STEEL001',
        productName: '螺旋焊接钢管',
        extendedFields: {
          'steelGrade': 'Q235B',
          'weldingType': '双面埋弧焊',
          'coatingType': '3PE防腐层',
          'coatingThickness': '3.0mm',
          'hydroTestPressure': '1.5MPa',
          'testDuration': '10分钟',
          'certificateNo': 'CERT-2025-001',
        },
      );
    } else if (code.contains('XT03K3312500172041')) {
      return _createMockData(
        code: code,
        type: 6, // 阀门
        group: 1, // 管件
        materialCode: 'VALVE001',
        productName: '球阀',
        extendedFields: {
          'valveType': '球阀',
          'operationType': '手动',
          'sealMaterial': 'PTFE',
          'bodyMaterial': '铸铁',
          'connectionType': '法兰连接',
          'operatingTemp': '-10°C ~ 120°C',
          'testPressure': '1.5MPa',
          'workingPressure': '1.0MPa',
        },
      );
    } else {
      // 默认返回通用材料信息
      return _createMockData(
        code: code,
        type: 0,
        group: 0,
        materialCode: 'DEFAULT001',
        productName: '通用材料',
        extendedFields: {'remark': '通用材料信息'},
      );
    }
  }

  ScanIdentificationData _createMockData({
    required String code,
    required int type,
    required int group,
    required String materialCode,
    required String productName,
    Map<String, dynamic> extendedFields = const {},
  }) {
    final baseInfo = MaterialInfoBase(
      materialCode: materialCode,
      deliveryNumber: 'DN-2025-001',
      batchCode: 'BATCH-${DateTime.now().millisecondsSinceEpoch}',
      mfgNm: '新兴铸管',
      purNm: '北方管道公司',
      prodStdNo: 'JIS G5526',
      prodNm: productName,
      spec: 'DN400 PN1.0',
      pressLvl: 'PN1.0',
      weight: '400kg',
    );

    final materialInfo = MaterialInfo(
      baseInfo: baseInfo,
      extendedFields: extendedFields,
    );

    final data = ScanIdentificationData(
      info: materialInfo,
      projectName: '智慧水务示例项目',
      projectId: 50,
      projectAddress: '某某市某某区某某路段',
      materialCode: materialCode,
      cut: false,
      type: type,
      group: group,
      lat: 39.9042,
      lng: 116.4074,
      img: null,
      accepts: null,
      history: null,
      installs: null,
    );

    return data;
  }
}
