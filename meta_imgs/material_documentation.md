# Material Type Documentation

This document provides a complete reference for all material types, including all inherited fields, as defined in `MaterialTypeEnum`.

### `qiu_mo_zhu_tie` (球墨铸铁)
**Class:** `QiuMoZhuTieVO`
**Inheritance:** `QiuMoZhuTieVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `graphSpherRate` | 石墨球化率 |
| `pipeGskMatBrand` | 管道配套胶圈材质、品牌 |
| `extCorrProtType` | 外防腐类型 |
| `extCorrProtStd` | 外防腐标准 |
| `extCorrProtThk` | 外防腐厚度 |
| `extCorrProtAppPerfInsp` | 外防腐层外观、性能检验 |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `intCorrProtAppPerfInsp` | 内防腐层外观、性能检验 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |

### `gang_guan` (钢管)
**Class:** `GangGuanVO`
**Inheritance:** `GangGuanVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `galvCoatWtThk` | 镀锌层重量或厚度 |
| `hydroTest` | 静水压试验 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |

### `bo_bi_bu_xiu_gang` (薄壁不锈钢管)
**Class:** `BoBiBuXiuGangVO`
**Inheritance:** `BoBiBuXiuGangVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |

### `gang_su_fu_he_guan` (钢塑复合管)
**Class:** `GangSuFuHeGuanVO`
**Inheritance:** `GangSuFuHeGuanVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `tempCorrosionResParam` | 耐温与耐腐蚀参数 |
| `coatingProcess` | 涂覆工艺 |

### `guan_dao_guan_jian_qiu` (管道管件(球墨管件))
**Class:** `GuanDaoGuanJianVO_Qiu`
**Inheritance:** `GuanDaoGuanJianVO_Qiu` -> `QiuMoZhuTieVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `graphSpherRate` | 石墨球化率 |
| `pipeGskMatBrand` | 管道配套胶圈材质、品牌 |
| `extCorrProtType` | 外防腐类型 |
| `extCorrProtStd` | 外防腐标准 |
| `extCorrProtThk` | 外防腐厚度 |
| `extCorrProtAppPerfInsp` | 外防腐层外观、性能检验 |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `intCorrProtAppPerfInsp` | 内防腐层外观、性能检验 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |

### `guan_dao_guan_jian_gang` (管道管件(钢管管件))
**Class:** `GuanDaoGuanJianVO_Gang`
**Inheritance:** `GuanDaoGuanJianVO_Gang` -> `GangGuanVO` -> `PipeBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `len` | |
| `industryArea` | 承口铸字 (新兴未生产基地,其他厂家待确认) |
| `galvCoatWtThk` | 镀锌层重量或厚度 |
| `hydroTest` | 静水压试验 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |

### `fa_men` (阀门)
**Class:** `FaMenVO`
**Inheritance:** `FaMenVO` -> `FittingsBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `valveBodyMat` | 阀体材质 |
| `valvePlateMat` | 阀板材质 |
| `valveStemMat` | 阀杆材质 |
| `valveSeatMat` | 阀座材质 |
| `sealRingMat` | 密封圈材质 |
| `bearingMat` | 轴承材质 |
| `coatingMat` | 涂料材质 |
| `matchingGasket` | 配套胶圈 |
| `fastenersNutMat` | 紧固件、螺母材质 |

### `shen_suo_jie` (伸缩节)
**Class:** `ShenSuoJieVO`
**Inheritance:** `ShenSuoJieVO` -> `FittingsBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `body` | 本体 |
| `sealing` | 密封 |
| `limitShortPipe` | 限位短管 |
| `gland` | 压盖 |
| `matchingGasket` | 配套胶圈 |
| `boltsStudsNuts` | 螺栓、螺柱及螺母 |

### `xiao_huo_shuan` (消火栓)
**Class:** `XiaoHuoShuanVO`
**Inheritance:** `XiaoHuoShuanVO` -> `FittingsBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `body` | 本体 |
| `valveSeatDisc` | 阀座 / 阀瓣 |
| `boltsStudsNuts` | 螺栓、螺柱及螺母 |

### `ha_fu_jie` (哈夫节（适用于金属或非金属管道连接）)
**Class:** `HaFuJieVO`
**Inheritance:** `HaFuJieVO` -> `RepairBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `graphSpherRate` | 石墨球化率 |
| `pipeGskMatBrand` | 管道配套胶圈材质、品牌 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |
| `extCorrProtType` | 外防腐类型 |
| `extCorrProtStd` | 外防腐标准 |
| `extCorrProtThk` | 外防腐厚度 |
| `extCorrProtAppPerfInsp` | 外防腐层外观、性能检验 |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `intCorrProtAppPerfInsp` | 内防腐层外观、性能检验 |

### `cheng_kou_zha_fa` (承口闸阀（适用于金属或非金属管道连接）)
**Class:** `ChengKouZhaFaVO`
**Inheritance:** `ChengKouZhaFaVO` -> `RepairBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `graphSpherRate` | 石墨球化率 |
| `pipeGskMatBrand` | 管道配套胶圈材质、品牌 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |
| `extCorrProtType` | 外防腐类型 |
| `extCorrProtStd` | 外防腐标准 |
| `extCorrProtThk` | 外防腐厚度 |
| `extCorrProtAppPerfInsp` | 外防腐层外观、性能检验 |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `intCorrProtAppPerfInsp` | 内防腐层外观、性能检验 |

### `wan_neng_lian_jie_qi` (万能连接器（适用于金属或非金属管道连接）)
**Class:** `WanNengLianJieQiVO`
**Inheritance:** `WanNengLianJieQiVO` -> `RepairBaseVO` -> `MaterialBaseInfo`

| 字段名 | 备注 |
| :--- | :--- |
| `produceDate` | 生产日期 |
| `materialId` | 还未入数据库时为null |
| `isDestroy` | 材料是否已销毁 |
| `isBack` | 材料是否因不合格退回 |
| `materialCode` | 产品唯一编号 |
| `transCardNo` | 运单号,通过此单号,可以查询到该运单包含多少件货物? |
| `batchCode` | 批次号 |
| `deliveryNumber` | 已经废弃,为了兼容测试数据保留 |
| `mfgNm` | 制造商名称 |
| `mfgCode` | 制造商编码,对应VendorEnum 的code |
| `purNm` | 采购方名称 |
| `prodStdNo` | 产品型号 |
| `standard` | 产品标准号(产品型号?) |
| `prodNm` | 产品名称 |
| `spec` | 规格 |
| `pressLvl` | 压力等级 |
| `weight` | 重量 |
| `deliveryCode` | 本材料归属运单号 |
| `otherMaterialByDelivery` | 本次交付的其他材料 |
| `delivery` | 运单信息(本次运单(交付)的材料编码清单) |
| `warrantyUrl` | 质保书 |
| `currentWarrantyUrl` | 质保书访问地址 |
| `certificateUrl` | 合格证 |
| `currentCertificateUrl` | 合格证访问地址 |
| `signUrl` | |
| `currentSignUrl` | |
| `matGradeParam` | 材质（牌号）参数 |
| `posDev` | 正偏差 |
| `graphSpherRate` | 石墨球化率 |
| `pipeGskMatBrand` | 管道配套胶圈材质、品牌 |
| `chemCompInsp` | 化学成分检验 |
| `mechPerfInsp` | 力学性能检验 |
| `nonDsInsp` | 无损检验 |
| `extCorrProtType` | 外防腐类型 |
| `extCorrProtStd` | 外防腐标准 |
| `extCorrProtThk` | 外防腐厚度 |
| `extCorrProtAppPerfInsp` | 外防腐层外观、性能检验 |
| `intCorrProtType` | 内防腐类型 |
| `intCorrProtStd` | 内防腐标准 |
| `intCorrProtThk` | 内防腐厚度 |
| `intCorrProtAppPerfInsp` | 内防腐层外观、性能检验 |
