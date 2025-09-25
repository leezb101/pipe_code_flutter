# MaterialDetailDisplay 组件集成指南

## 快速集成到现有业务页面

### 1. 入库页面 (SigninPage) 集成示例

```dart
// 在 signin_page.dart 中添加导入
import 'package:pipe_code_flutter/widgets/material/material_detail_display.dart';

// 修改现有的 _showMaterialDetail 方法
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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '入库材料详情',
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
                    showProjectInfo: true, // 入库页面显示项目信息
                    showCopyAction: true,
                    // 如果有项目信息，可以传入
                    // projectName: '某某供水工程',
                    // projectAddress: '某某市某某区',
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

### 2. 出库页面 (SignoutPage) 集成示例

```dart
// 在 signout_page.dart 中
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
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '出库材料详情',
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
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MaterialDetailDisplay(
                    material: material,
                    isCompact: true,
                    showProjectInfo: false, // 出库页面可能不需要显示项目信息
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

### 3. 移库页面 (TransferPage) 集成示例

```dart
// 在 transfer_page.dart 中
void _showMaterialDetail(BuildContext context, MaterialInfo material) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        constraints: const BoxConstraints(
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '移库材料详情',
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
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MaterialDetailDisplay(
                  material: material,
                  isCompact: true,
                  showProjectInfo: false,
                  showCopyAction: false, // 移库页面可能不需要复制功能
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

### 4. 盘点页面 (InventoryPage) 集成示例

```dart
// 在 inventory_page.dart 中，使用更紧凑的展示方式
void _showMaterialDetail(BuildContext context, MaterialInfo material) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('盘点材料详情'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: MaterialDetailDisplay(
            material: material,
            isCompact: true,
            showProjectInfo: false,
            showCopyAction: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      );
    },
  );
}
```

### 5. 在页面内直接展示（非弹窗模式）

```dart
class MaterialDetailSection extends StatelessWidget {
  final MaterialInfo material;
  
  const MaterialDetailSection({super.key, required this.material});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MaterialDetailDisplay(
          material: material,
          isCompact: false, // 页面内展示可以使用非紧凑模式
          showProjectInfo: true,
          showCopyAction: true,
        ),
      ),
    );
  }
}
```

## 集成步骤总结

1. **添加导入**：在需要的页面文件顶部添加导入语句
   ```dart
   import 'package:pipe_code_flutter/widgets/material/material_detail_display.dart';
   ```

2. **替换现有实现**：将原有的简单文本展示替换为 `MaterialDetailDisplay` 组件

3. **配置参数**：根据业务需要配置组件参数：
   - `isCompact`: 弹窗中使用 `true`，页面中使用 `false`
   - `showProjectInfo`: 根据业务需要决定是否显示项目信息
   - `showCopyAction`: 根据用户需要决定是否显示复制功能

4. **测试验证**：确保组件在各种业务场景下都能正常工作

## 优化建议

### 性能优化
- 在列表页面中避免同时渲染大量 MaterialDetailDisplay 组件
- 考虑使用懒加载或分页来优化性能

### 用户体验优化
- 在网络较慢的环境下，考虑添加加载状态
- 为文件预览功能添加错误处理和重试机制

### 主题定制
- 组件会自动适应应用主题，无需额外配置
- 如需特殊样式，可以通过包装 Container 来实现

这个通用组件将大大减少代码重复，提高开发效率，同时确保所有业务页面的材料详情展示保持一致性。
