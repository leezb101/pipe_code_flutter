# SignoutDetailPage 数据结构澄清与实现

## 问题澄清

根据您的说明，我重新理解了数据结构：

### 数据源澄清

1. **SignoutInfoVo.materialList** - 出库物料列表
   - 用于展示出库的物料信息
   - 不包含安装相关数据

2. **SignoutInfoVo.installInfo.materialList** - 安装物料列表  
   - 包含安装相关的物料信息
   - 包含 `installPileNo`（安装桩号）
   - 包含 `installImageUrl1` 和 `installImageUrl2`（安装照片）

3. **SignoutInfoVo.imageList** - 出库现场照片
   - 展示出库时的现场照片

4. **SignoutInfoVo.installInfo.installQualityUrl** - 安装质量文档PDF
   - 安装质量相关的PDF文档

5. **SignoutInfoVo.installInfo.imageList** - 安装现场照片
   - 安装时的现场照片

## 实现修改

### 1. 修正了 `_buildMaterialItem` 方法
- **移除了安装相关代码** - 出库物料列表不再显示安装信息
- **保持简洁设计** - 只显示物料基本信息（名称、ID、数量）

### 2. 重构了 `_buildInstallInfo` 方法
现在正确展示安装信息的所有内容：
- ✅ 基本安装信息（关联出库ID、是否仅安装）
- ✅ 安装物料列表（使用 `installInfo.materialList`）
- ✅ 安装质量文档PDF预览
- ✅ 安装现场照片网格展示

### 3. 新增了专门的安装相关方法

#### `_buildInstallMaterialItem(MaterialVO material)`
- 专门用于展示安装物料信息
- 包含安装桩号显示
- 包含安装照片缩略图和预览功能
- 使用绿色主题区分安装相关内容

#### `_buildInstallImageGrid(List<AttachmentVO> imageList)`
- 展示安装现场照片的网格布局
- 3列网格布局，适合移动端查看

#### `_buildInstallImageThumbnail(AttachmentVO image)`
- 安装现场照片的缩略图组件
- 使用绿色边框区分于出库照片
- 支持点击预览大图

### 4. 更新了 `_buildImagesSection` 方法
- **明确标题** - 改为"出库现场照片"，清楚表明数据来源
- **保持原有功能** - 展示 `signoutDetail.imageList` 的内容

## 页面结构

现在页面的数据展示结构为：

```
1. 出库概要信息
2. 出库物料列表 (signoutDetail.materialList)
3. 仓库信息
4. 负责人信息
5. 安装信息 (signoutDetail.installInfo) - 条件渲染
   ├── 基本安装信息
   ├── 安装物料列表 (installInfo.materialList)
   ├── 安装质量文档 (installInfo.installQualityUrl)
   └── 安装现场照片 (installInfo.imageList)
6. 出库现场照片 (signoutDetail.imageList)
```

## 条件渲染逻辑

- **安装信息section**: 只有当 `signoutDetail.installInfo` 不为空时才显示
- **安装物料列表**: 只有当 `installInfo.materialList` 不为空时才显示
- **安装桩号**: 只有当物料的 `installPileNo` 不为空时才显示
- **安装照片**: 只有当 `installImageUrl1` 或 `installImageUrl2` 不为空时才显示
- **安装质量文档**: 只有当 `installQualityUrl` 不为空时才显示
- **安装现场照片**: 只有当 `installInfo.imageList` 不为空时才显示

## 视觉区分

- **出库相关内容**: 使用蓝色主题
- **安装相关内容**: 使用绿色主题  
- **出库现场照片**: 使用粉色主题
- **其他通用内容**: 使用相应的主题色（紫色、靛蓝色等）

这样的设计确保了数据的正确展示和良好的用户体验！
