# 建设方验收供材类型控制功能实现

## 功能概述
在"建设方验收"页面增加了基于 `currentProjectSupplyType` 字段的前置判断条件，用来控制材料采购方（purNm）与项目采购方匹配检查的逻辑。

## 业务规则
- **甲供材（值：0）**：跳过 purNm 判断，直接正常进行验收流程
- **乙供材（值：1）**：跳过 purNm 判断，直接正常进行验收流程  
- **甲乙混供（值：2）**：需要进行 purNm 匹配检查，如有不匹配则提示用户确认

## 修改文件

### 1. JsfAcceptanceCubit (`lib/cubits/jsf_acceptance/jsf_acceptance_cubit.dart`)

#### 主要变更：
- 导入 `ProjectSupplyType` 枚举类型
- 修改 `handleEvent` 方法签名，增加 `supplyType` 参数
- 修改所有相关的事件处理方法，增加 `supplyType` 参数传递
- 重构 `_checkPurchaserMismatch` 方法，增加供材类型的前置判断

#### 核心逻辑：
```dart
List<String> _checkPurchaserMismatch(
  List<MaterialInfo> materials,
  String? projectPurNm,
  ProjectSupplyType? supplyType,
) {
  // 前置判断：根据供材类型决定是否需要进行purNm检查
  if (supplyType == null) {
    return []; // 如果没有供材类型信息，跳过验证
  }
  
  // 如果是"甲供材"，则不需要进行purNm判断，直接返回空列表
  if (supplyType == ProjectSupplyType.jiaGongCai) {
    return [];
  }
  
  // 如果是"乙供材"，建设方验收也不需要进行purNm判断
  if (supplyType == ProjectSupplyType.yiGongCai) {
    return [];
  }
  
  // 只有"甲乙混供"时，才需要进行purNm判断
  if (supplyType != ProjectSupplyType.jiaYiHunGong) {
    return [];
  }

  // 执行原有的purNm匹配检查逻辑...
}
```

### 2. JSF验收页面 (`lib/pages/acceptance/jsf_acceptance_page.dart`)

#### 主要变更：
- 导入 `ProjectSupplyType` 相关类型
- 在调用 cubit 的 `handleEvent` 方法时，从 session state 中获取并传递 `currentProjectSupplyType`

#### 核心修改：
```dart
// 获取当前项目采购方名称和供材类型
final sessionState = context.read<SessionBloc>().state;
String? projectPurNm;
ProjectSupplyType? supplyType;
if (sessionState is SessionProjectEstablished) {
  projectPurNm = sessionState.projectPurNm;
  supplyType = sessionState.currentUserRoleInfo.currentProjectSupplyType;
}

_controller.handleEvent(
  InitializeJsfMaterialsFromCodes(codes: codes, isBatch: widget.initialIsBatch ?? true),
  projectPurNm: projectPurNm,
  supplyType: supplyType,
);
```

## 测试验证

创建了两个测试文件来验证功能：

### 1. 逻辑测试 (`test_supply_type_logic.dart`)
- 测试各种供材类型下的判断逻辑
- 验证业务规则是否正确实现

### 2. 综合演示 (`supply_type_demo.dart`)
- 模拟实际业务场景
- 展示不同供材类型下的验收流程

## 影响范围

### 直接影响：
- 建设方验收页面的采购方验证逻辑
- JsfAcceptanceCubit 的状态管理

### 间接影响：
- 改善了用户体验，减少了不必要的确认对话框
- 更符合业务流程的实际需求

## 兼容性
- 向后兼容：如果 `supplyType` 为 null，会跳过验证（保持原有行为）
- 不会影响现有的其他验收页面或功能

## 验证结果
✅ 所有测试用例通过  
✅ 业务逻辑符合需求  
✅ 代码编译无错误  
✅ 功能实现完整  

## 总结
成功实现了基于供材类型的智能化采购方验证控制，提高了验收流程的效率和用户体验。只有在真正需要验证的场景下（甲乙混供且存在采购方不匹配），才会提示用户进行确认。
