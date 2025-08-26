/*
 * @Author: LeeZB
 * @Date: 2025-08-20 10:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-20 10:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// 材料类型字段名到中文标签的映射
/// key: 材料类型的英文标识 (e.g., 'qiuMoZhuTie')
/// value: 一个Map，其中key是后端返回的字段名，value是UI上显示的中文标签
const Map<String, Map<String, String>> materialFieldMaps = {
  'qiuMoZhuTie': qiuMoZhuTieFields,
  'gangGuan': gangGuanFields,
  'boBiBuXiuGang': boBiBuXiuGangFields,
  'gangSuFuHeGuan': gangSuFuHeGuanFields,
  'guanDaoGuanJianQiu': guanDaoGuanJianQiuFields,
  'guanDaoGuanJianGang': guanDaoGuanJianGangFields,
  'faMen': faMenFields,
  'shenSuoJie': shenSuoJieFields,
  'xiaoHuoShuan': xiaoHuoShuanFields,
  'haFuJie': haFuJieFields,
  'chengKouZhaFa': chengKouZhaFaFields,
  'wanNengLianJieQi': wanNengLianJieQiFields,
};

/// 通用基础字段
const Map<String, String> _baseFields = {
  'produceDate': '生产日期',
  'materialId': '材料ID',
  'isDestroy': '是否销毁',
  'isBack': '是否退回',
  'materialCode': '产品唯一编号',
  'transCardNo': '运单号',
  'batchCode': '批次号',
  'deliveryNumber': '发货单号',
  'mfgNm': '制造商名称',
  'mfgCode': '制造商编码',
  'purNm': '采购方名称',
  'prodStdNo': '产品型号',
  'standard': '产品标准号',
  'prodNm': '产品名称',
  'spec': '规格',
  'pressLvl': '压力等级',
  'weight': '重量',
  'deliveryCode': '归属运单号',
  'warrantyUrl': '质保书',
  'currentWarrantyUrl': '质保书地址',
  'certificateUrl': '合格证',
  'currentCertificateUrl': '合格证地址',
  'signUrl': '签名URL',
  'currentSignUrl': '签名地址',
};

/// 管道通用字段 (PipeBaseVO)
const Map<String, String> _pipeBaseFields = {
  ..._baseFields,
  'matGradeParam': '材质（牌号）参数',
  'posDev': '正偏差',
  'len': '长度(mm)',
  'industryArea': '承口铸字',
};

/// 球墨铸铁管字段 (QiuMoZhuTieVO)
const Map<String, String> qiuMoZhuTieFields = {
  ..._pipeBaseFields,
  'graphSpherRate': '石墨球化率',
  'pipeGskMatBrand': '配套胶圈材质/品牌',
  'extCorrProtType': '外防腐类型',
  'extCorrProtStd': '外防腐标准',
  'extCorrProtThk': '外防腐厚度',
  'extCorrProtAppPerfInsp': '外防腐层外观、性能检验',
  'intCorrProtType': '内防腐类型',
  'intCorrProtStd': '内防腐标准',
  'intCorrProtThk': '内防腐厚度',
  'intCorrProtAppPerfInsp': '内防腐层外观、性能检验',
  'chemCompInsp': '化学成分检验',
  'mechPerfInsp': '力学性能检验',
  'nonDsInsp': '无损检验',
};

/// 钢管字段 (GangGuanVO)
const Map<String, String> gangGuanFields = {
  ..._pipeBaseFields,
  'galvCoatWtThk': '镀锌层重量或厚度',
  'hydroTest': '静水压试验',
  'chemCompInsp': '化学成分检验',
  'mechPerfInsp': '力学性能检验',
  'nonDsInsp': '无损检验',
};

/// 薄壁不锈钢管字段 (BoBiBuXiuGangVO)
const Map<String, String> boBiBuXiuGangFields = {
  ..._pipeBaseFields,
  'chemCompInsp': '化学成分检验',
  'mechPerfInsp': '力学性能检验',
  'nonDsInsp': '无损检验',
};

/// 钢塑复合管字段 (GangSuFuHeGuanVO)
const Map<String, String> gangSuFuHeGuanFields = {
  ..._pipeBaseFields,
  'tempCorrosionResParam': '耐温与耐腐蚀参数',
  'coatingProcess': '涂覆工艺',
};

/// 管道管件(球墨)字段 (GuanDaoGuanJianVO_Qiu)
const Map<String, String> guanDaoGuanJianQiuFields = {
  ...qiuMoZhuTieFields, // 继承自球墨铸铁管
};

/// 管道管件(钢管)字段 (GuanDaoGuanJianVO_Gang)
const Map<String, String> guanDaoGuanJianGangFields = {
  ...gangGuanFields, // 继承自钢管
};

/// 管件通用字段 (FittingsBaseVO)
const Map<String, String> _fittingsBaseFields = {
  ..._baseFields,
  'intCorrProtType': '内防腐类型',
  'intCorrProtStd': '内防腐标准',
  'intCorrProtThk': '内防腐厚度',
};

/// 阀门字段 (FaMenVO)
const Map<String, String> faMenFields = {
  ..._fittingsBaseFields,
  'valveBodyMat': '阀体材质',
  'valvePlateMat': '阀板材质',
  'valveStemMat': '阀杆材质',
  'valveSeatMat': '阀座材质',
  'sealRingMat': '密封圈材质',
  'bearingMat': '轴承材质',
  'coatingMat': '涂料材质',
  'matchingGasket': '配套胶圈',
  'fastenersNutMat': '紧固件、螺母材质',
};

/// 伸缩节字段 (ShenSuoJieVO)
const Map<String, String> shenSuoJieFields = {
  ..._fittingsBaseFields,
  'body': '本体',
  'sealing': '密封',
  'limitShortPipe': '限位短管',
  'gland': '压盖',
  'matchingGasket': '配套胶圈',
  'boltsStudsNuts': '螺栓、螺柱及螺母',
};

/// 消火栓字段 (XiaoHuoShuanVO)
const Map<String, String> xiaoHuoShuanFields = {
  ..._fittingsBaseFields,
  'body': '本体',
  'valveSeatDisc': '阀座 / 阀瓣',
  'boltsStudsNuts': '螺栓、螺柱及螺母',
};

/// 抢修件通用字段 (RepairBaseVO)
const Map<String, String> _repairBaseFields = {
  ..._baseFields,
  'matGradeParam': '材质（牌号）参数',
  'posDev': '正偏差',
  'graphSpherRate': '石墨球化率',
  'pipeGskMatBrand': '配套胶圈材质/品牌',
  'chemCompInsp': '化学成分检验',
  'mechPerfInsp': '力学性能检验',
  'nonDsInsp': '无损检验',
  'extCorrProtType': '外防腐类型',
  'extCorrProtStd': '外防腐标准',
  'extCorrProtThk': '外防腐厚度',
  'extCorrProtAppPerfInsp': '外防腐层外观、性能检验',
  'intCorrProtType': '内防腐类型',
  'intCorrProtStd': '内防腐标准',
  'intCorrProtThk': '内防腐厚度',
  'intCorrProtAppPerfInsp': '内防腐层外观、性能检验',
};

/// 哈夫节字段 (HaFuJieVO)
const Map<String, String> haFuJieFields = {..._repairBaseFields};

/// 承口闸阀字段 (ChengKouZhaFaVO)
const Map<String, String> chengKouZhaFaFields = {..._repairBaseFields};

/// 万能连接器字段 (WanNengLianJieQiVO)
const Map<String, String> wanNengLianJieQiFields = {..._repairBaseFields};
