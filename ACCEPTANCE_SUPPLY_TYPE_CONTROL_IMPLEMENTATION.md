# 施工方验收供材类型控制功能实现

## 功能概述
为"施工方验收"页面（acceptance_page.dart）实现了基于 `currentProjectSupplyType` 字段的前置判断条件，用来控制材料采购方（purNm）与项目采购方（currentPurNm）匹配检查的逻辑。

## 业务规则
- **甲供材（值：0）**：菜单阶段已经拦截，页面内也跳过 purNm 判断，直接正常进行验收流程
- **乙供材（值：1）**：跳过 purNm 判断，直接正常进行验收流程  
- **甲乙混供（值：2）**：需要进行 purNm 匹配检查，只有材料的purNm与项目的currentPurNm完全一致才能继续，不一致则弹出警告让用户选择"仍然继续"或"取消操作"

## 修改文件

### 1. AcceptanceEvent (`lib/bloc/acceptance/acceptance_event.dart`)

#### 主要变更：
- 导入 `ProjectSupplyType` 枚举类型
- 修改 `InitializeMaterialsFromCodes` 事件，增加 `projectPurNm` 和 `supplyType` 参数
- 修改 `AppendEditingMaterialsByCodes` 事件，增加 `projectPurNm` 和 `supplyType` 参数
- 修改 `InitializeEditingMaterials` 事件，增加 `projectPurNm` 和 `supplyType` 参数
- 添加 `ConfirmPurchaserValidationWarning` 事件用于确认采购方验证警告

### 2. AcceptanceState (`lib/bloc/acceptance/acceptance_state.dart`)

#### 主要变更：
- 修改 `AcceptanceEditingState` 状态，增加采购方验证警告相关字段：
  - `showPurchaserValidationWarning`: 是否显示采购方验证警告
  - `purchaserMismatchMaterials`: 采购方不匹配的材料列表

### 3. AcceptanceBloc (`lib/bloc/acceptance/acceptance_bloc.dart`)

#### 主要变更：
- 导入 `ProjectSupplyType` 和 `MaterialInfo` 类型
- 添加 `_onConfirmPurchaserValidationWarning` 事件处理方法
- 添加 `_checkPurchaserMismatch` 辅助方法，实现供材类型的前置判断逻辑
- 修改相关事件处理方法，集成采购方匹配检查：
  - `_onInitializeMaterialsFromCodes`
  - `_onInitializeEditingMaterials`  
  - `_onAppendEditingMaterialsByCodes`

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
  
  // 如果是"乙供材"，则不需要进行purNm判断
  if (supplyType == ProjectSupplyType.yiGongCai) {
    return [];
  }
  
  // 如果是"甲供材"，菜单阶段应该已经拦截，但为安全起见也跳过purNm判断
  if (supplyType == ProjectSupplyType.jiaGongCai) {
    return [];
  }
  
  // 只有"甲乙混供"时，才需要进行purNm判断
  if (supplyType != ProjectSupplyType.jiaYiHunGong) {
    return [];
  }

  // 执行严格的purNm匹配检查...
}
```

### 4. 施工方验收页面 (`lib/pages/acceptance/acceptance_page.dart`)

#### 主要变更：
- 导入 `ProjectSupplyType` 相关类型
- 在调用 bloc 事件时，从 session state 中获取并传递供材类型和项目采购方信息
- 添加采购方验证警告对话框的处理逻辑
- 添加 `_showPurchaserValidationWarning` 方法，显示警告对话框
- 修改 `_scanAppendMaterials` 方法，传递供材类型参数

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

context.read<AcceptanceBloc>().add(
  InitializeMaterialsFromCodes(
    codes: codes,
    isBatch: widget.initialIsBatch ?? (codes.length > 1),
    projectPurNm: projectPurNm,
    supplyType: supplyType,
  ),
);
```

## 测试验证

创建了两个测试文件来验证功能：

### 1. 逻辑测试 (`test_acceptance_supply_type_logic.dart`)
- 测试各种供材类型下的判断逻辑
- 验证业务规则是否正确实现

### 2. 综合演示 (`acceptance_supply_type_demo.dart`)
- 模拟实际业务场景
- 展示不同供材类型下的验收流程
- 对比建设方验收和施工方验收的差异

## 与建设方验收的差异

| 验收类型       | 甲供材            | 乙供材   | 甲乙混供          |
|----------------|-------------------|----------|-------------------|
| **建设方验收** | 跳过检查          | 跳过检查 | 检查材料purNm匹配 |
| **施工方验收** | 菜单拦截+跳过检查 | 跳过检查 | 检查材料purNm匹配 |

关键差异：
- 建设方验收：关注验收材料的来源合规性
- 施工方验收：关注施工用料的采购合规性，甲供材在菜单阶段就已拦截

## 影响范围

### 直接影响：
- 施工方验收页面的采购方验证逻辑
- AcceptanceBloc 的状态管理
- 用户体验改善，减少不必要的确认对话框

### 间接影响：
- 与建设方验收形成完整的供材类型控制体系
- 提升验收流程的业务合规性

## 兼容性
- 向后兼容：如果 `supplyType` 为 null，会跳过验证（保持原有行为）
- 不会影响现有的其他验收页面或功能

## 验证结果
✅ 所有测试用例通过  
✅ 业务逻辑符合需求  
✅ 代码编译无错误  
✅ 功能实现完整  

## 总结
成功为施工方验收实现了基于供材类型的智能化采购方验证控制，与建设方验收形成完整的验收体系。只有在真正需要验证的场景下（甲乙混供且存在采购方不匹配），才会提示用户进行确认，大大提升了验收流程的效率和合规性。
