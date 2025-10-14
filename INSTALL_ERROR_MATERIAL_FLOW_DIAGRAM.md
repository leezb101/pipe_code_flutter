# 安装页面异常材料展示流程图

## 数据流图

```
┌─────────────────────────────────────────────────────────────────┐
│                         扫码操作                                  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              MaterialHandleCubit.getMaterialInfoFromQr          │
│                  获取物料信息 (MaterialInfoForBusiness)           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
                    ┌───────┴───────┐
                    │ MaterialInfo  │
                    │  ForBusiness  │
                    └───────┬───────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
    ┌─────────┐       ┌─────────┐      ┌─────────┐
    │ normals │       │ errors  │      │  ...    │
    │  List   │       │  List   │      │         │
    └────┬────┘       └────┬────┘      └─────────┘
         │                 │
         └────────┬────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│          InstallBloc.add(AppendScannedMaterial)                 │
│              处理并创建 ScanResult                                │
└───────────────────────────┬─────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
    ┌──────────┐      ┌──────────┐      ┌──────────┐
    │ Normal   │      │  Error   │      │ Message  │
    │ Material │      │ Material │      │  Toast   │
    └────┬─────┘      └────┬─────┘      └──────────┘
         │                 │
         └────────┬────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│              InstallReady.scanResults (List)                    │
│              按扫码时间顺序存储所有结果                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              _buildScanResultsList(scanResults)                 │
│                   遍历并渲染所有扫码结果                           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          │                                   │
          ▼                                   ▼
┌──────────────────────┐           ┌──────────────────────┐
│ _buildMaterialItem   │           │ _buildErrorMaterial  │
│   (正常材料卡片)       │           │       Item          │
│                      │           │   (异常材料卡片)       │
│ • 材料信息显示        │           │                      │
│ • 桩号输入框          │           │ • ErrorMaterial      │
│ • 照片上传组件        │           │   Section (红色)     │
│                      │           │ • 错误信息显示        │
│                      │           │ • 点击查看详情        │
└──────────────────────┘           └──────────────────────┘
```

## 状态结构对比

### 验收页面 (AcceptanceEditingState)
```
AcceptanceEditingState
├── currentMaterials: List<MaterialInfo>     // 所有正常材料
└── errorMaterials: List<dynamic>            // 所有异常材料 (集合)
    
UI 展示:
┌─────────────────────────────────┐
│ 正常材料 1                        │
├─────────────────────────────────┤
│ 正常材料 2                        │
├─────────────────────────────────┤
│ 正常材料 3                        │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ ⚠ 验收异常材料 (可折叠) [3]   │ │
│ ├─────────────────────────────┤ │
│ │ 异常 1                       │ │
│ │ 异常 2                       │ │
│ │ 异常 3                       │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### 安装页面 (InstallReady)
```
InstallReady
└── scanResults: List<ScanResult>           // 所有扫码结果 (按顺序)
    ├── ScanResult #1
    │   ├── normalMaterial: MaterialInfo
    │   ├── errorMaterial: null
    │   └── scanTime: DateTime
    ├── ScanResult #2
    │   ├── normalMaterial: null
    │   ├── errorMaterial: Error
    │   └── scanTime: DateTime
    └── ScanResult #3
        ├── normalMaterial: MaterialInfo
        ├── errorMaterial: null
        └── scanTime: DateTime

UI 展示:
┌─────────────────────────────────┐
│ 正常材料 1                        │  ← ScanResult #1
│ (桩号输入、照片上传)               │
├─────────────────────────────────┤
│ ⚠ 扫码异常                       │  ← ScanResult #2
│ 错误信息：xxx                     │
├─────────────────────────────────┤
│ 正常材料 2                        │  ← ScanResult #3
│ (桩号输入、照片上传)               │
└─────────────────────────────────┘
```

## ScanResult 数据结构

```dart
class ScanResult {
  // 互斥关系：只有一个会有值
  final MaterialInfo? normalMaterial;  // 正常材料
  final dynamic errorMaterial;         // 异常材料
  
  // 元数据
  final DateTime scanTime;             // 扫描时间
  
  // 未来可扩展字段:
  // final String? operator;           // 操作员
  // final GeoLocation? location;      // 扫码位置
  // final String? remarks;            // 备注
}
```

## 关键方法流程

### _onAppendScannedMaterial (InstallBloc)

```
开始
  │
  ├─ 获取当前状态 (InstallReady)
  │
  ├─ 创建扫描时间戳
  │
  ├─ 复制当前 scanResults 列表
  │
  ├─ 判断材料类型
  │   │
  │   ├─ 如果是正常材料 (normals 非空)
  │   │   │
  │   │   ├─ 检查是否重复 (materialId 去重)
  │   │   │   │
  │   │   │   ├─ 重复 → 发出提示消息 → 结束
  │   │   │   │
  │   │   │   └─ 不重复 → 继续
  │   │   │
  │   │   ├─ 创建 ScanResult (normalMaterial)
  │   │   │
  │   │   └─ 添加到 scanResults
  │   │
  │   └─ 如果是异常材料 (errors 非空)
  │       │
  │       ├─ 遍历所有 errors
  │       │
  │       ├─ 为每个 error 创建 ScanResult
  │       │
  │       ├─ 添加到 scanResults
  │       │
  │       └─ 发出"扫描到异常材料"消息
  │
  ├─ 更新 materialInfos (向后兼容)
  │
  └─ emit 新状态 → 结束
```

## UI 交互流程

```
用户点击"扫码" → 扫描二维码 → 获取结果
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                正常材料                    异常材料
                    │                         │
        ┌───────────┴───────────┐             │
        │                       │             │
    检查是否重复              显示红色卡片 ←──┘
        │                       │
  ┌─────┴─────┐           显示错误信息
  │           │                 │
重复      不重复            用户可点击
  │           │             查看详情
Toast     显示卡片
提示         │
          用户填写
         桩号/照片
```

## 组件依赖关系

```
InstallPage
  │
  ├─── InstallBloc
  │     ├── InstallState (含 ScanResult)
  │     └── InstallEvent
  │
  ├─── MaterialHandleCubit
  │     └── getMaterialInfoFromQr()
  │
  └─── UI Components
        ├── UnifiedCard (正常材料)
        │     ├── MaterialListItem
        │     ├── ImageUploadWidget
        │     └── TextField (桩号)
        │
        └── ErrorMaterialSection (异常材料)
              └── ErrorMaterialListItem
```
