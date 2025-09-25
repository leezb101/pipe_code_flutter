# MaterialDetailDisplay 通用材料详情组件

## 概述

`MaterialDetailDisplay` 是一个通用的材料详情展示组件，可以在各种业务场景中复用，特别适合在弹窗、底部表单或详情页中展示材料的详细信息。

## 特性

- 🚀 **通用性强** - 支持所有材料类型，自动根据材料类型适配字段显示
- 📱 **响应式设计** - 支持紧凑模式和普通模式，适配不同容器尺寸
- 📋 **复制功能** - 支持长按复制单个字段，一键复制所有信息
- 📁 **文件预览** - 支持质保书、合格证等文件的预览功能，清晰的可点击样式
- 🎨 **主题适配** - 自动适应应用主题色彩
- ⚡ **性能优化** - 只渲染有数据的字段，避免空白显示
- 🌐 **中文本地化** - 自动将英文字段映射为中文标签
- 🧹 **智能过滤** - 过滤掉不相关的技术字段，只显示用户关心的信息

## 最新改进

### v1.1.0 (2025-09-25)
- ✨ **智能字段映射** - 自动使用 materialFieldMaps 将英文字段名转换为中文标签
- 🗂️ **智能字段过滤** - 过滤掉 otherMaterialDelivery 等不相关字段
- 📄 **增强文件展示** - currentWarrantyUrl 和 currentCertificateUrl 显示为可点击的文件卡片
- 🚫 **移除冗余字段** - 移除 warrantyUrl 和 certificateUrl，避免重复显示
- 🎨 **改进用户体验** - 文件链接采用卡片式设计，清楚指示可点击状态
- 📊 **数据优化** - 过滤掉空值和无意义的 "0" 值

## 基本用法

### 在弹窗中使用（推荐）

```dart
void _showMaterialDetail(BuildContext context, MaterialInfo material) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        material.baseInfo.prodNm ?? '材料详情',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 内容区域
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MaterialDetailDisplay(
                    material: material,
                    isCompact: true,
                    showProjectInfo: false,
                    showCopyAction: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

### 带类型信息的完整展示

```dart
class MaterialDetailSection extends StatelessWidget {
  final MaterialInfo material;
  
  @override
  Widget build(BuildContext context) {
    return MaterialDetailDisplay(
      material: material,
      materialType: MaterialTypeInfo(
        name: '球墨铸铁管',
        en: 'qiuMoZhuTie', // 用于字段映射
      ),
      materialGroup: MaterialGroupInfo(name: '管道'),
      projectName: '某某供水工程',
      projectAddress: '某某市某某区',
      showProjectInfo: true,
      showCopyAction: true,
      isCompact: false,
    );
  }
}
```

## 参数说明

| 参数              | 类型                 | 必填 | 默认值 | 描述                      |
|-------------------|----------------------|------|--------|---------------------------|
| `material`        | `MaterialInfo`       | ✅    | -      | 材料信息对象              |
| `materialType`    | `MaterialTypeInfo?`  | ❌    | null   | 材料类型信息，用于字段映射 |
| `materialGroup`   | `MaterialGroupInfo?` | ❌    | null   | 材料分组信息              |
| `projectName`     | `String?`            | ❌    | null   | 项目名称                  |
| `projectAddress`  | `String?`            | ❌    | null   | 项目地址                  |
| `showProjectInfo` | `bool`               | ❌    | true   | 是否显示项目信息          |
| `showCopyAction`  | `bool`               | ❌    | true   | 是否显示复制按钮          |
| `isCompact`       | `bool`               | ❌    | false  | 是否使用紧凑模式          |

## 文件预览功能

组件会自动识别 `currentWarrantyUrl` 和 `currentCertificateUrl` 字段，并将其显示为可点击的文件卡片：

- 🔵 **蓝色卡片设计** - 清楚指示这是可点击的文件链接
- 📄 **PDF 图标** - 直观显示文件类型
- 🔗 **外部链接图标** - 提示将打开新页面
- 🔐 **自动认证** - 自动添加用户认证token

## 字段映射机制

组件使用 `materialFieldMaps` 智能映射字段名称：

```dart
// 自动映射示例
'graphSpherRate' → '石墨球化率'
'extCorrProtType' → '外防腐类型'
'pressLvl' → '压力等级'
```

## 智能过滤机制

组件会自动过滤掉以下类型的字段：
- 技术性字段：`otherMaterialDelivery`
- 重复字段：`warrantyUrl`, `certificateUrl`（保留对应的 current 版本）
- 已显示字段：`materialId`, `materialCode`, `prodNm` 等（在概要部分已显示）
- 空值字段：null、空字符串、"0"

## 使用场景

### 1. 验收页面（AcceptancePage）✅ 已实现
- 在材料列表中点击查看详情
- 使用紧凑模式，关闭项目信息显示

### 2. 入库页面
- 扫码后确认材料信息
- 显示完整信息包括项目信息

### 3. 出库页面
- 选择出库材料时查看详情
- 可选择性显示项目信息

### 4. 移库页面
- 确认移库材料详情
- 通常不显示项目信息

### 5. 盘点页面
- 盘点时核对材料信息
- 使用紧凑模式节省空间

## 扩展使用

### 自定义材料类型映射

如果需要支持新的材料类型，需要在 `material_field_maps.dart` 中添加对应的字段映射：

```dart
const Map<String, String> newMaterialTypeFields = {
  ..._baseFields,
  'customField1': '自定义字段1',
  'customField2': '自定义字段2',
};

// 然后添加到主映射中
const Map<String, Map<String, String>> materialFieldMaps = {
  // ... 现有映射
  'newMaterialType': newMaterialTypeFields,
};
```

## 注意事项

1. **权限要求** - 文件预览功能需要用户已登录，组件会自动添加认证token
2. **网络要求** - 文件预览需要网络连接
3. **性能考虑** - 在列表中使用时建议使用懒加载，避免同时渲染大量组件
4. **主题适配** - 组件会自动适应当前应用主题，无需额外配置

## 更新日志

- **v1.1.0** (2025-09-25)
  - 智能字段映射和过滤
  - 增强文件预览体验
  - 改进用户界面设计
  
- **v1.0.0** (2025-09-25)
  - 首次发布
  - 支持基础材料信息展示
  - 支持文件预览功能
  - 支持复制功能
  - 支持紧凑模式
