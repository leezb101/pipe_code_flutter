# 调拨申请页面可搜索下拉框实现

## 概述
为调拨申请页面的下拉框添加了类似 Element UI `el-select` 的可搜索功能，使用 rxDart 实现防抖（600毫秒延迟），在单个组件内集成搜索和选择功能。

## 实现细节

### 1. 新增组件：`_SearchableDropdown<T>`
创建了一个类似 Element UI 的可搜索下拉组件，支持：
- ✅ 单一输入框集成搜索和选择
- ✅ 点击展开所有选项
- ✅ 输入时实时过滤选项
- ✅ 防抖处理（600毫秒延迟）
- ✅ 已选项高亮显示（带勾选图标）
- ✅ 清除按钮（输入时显示）
- ✅ 下拉箭头指示器（动态变化）
- ✅ 自定义浮层展示（Overlay）

### 2. 技术实现

#### 核心技术栈
- **Overlay + LayerLink**: 实现自定义下拉浮层
- **CompositedTransformTarget/Follower**: 浮层位置跟随
- **RxDart BehaviorSubject**: 防抖搜索流
- **FocusNode**: 焦点管理，自动展开/收起

#### 防抖处理
```dart
_searchSubject.stream
    .debounceTime(const Duration(milliseconds: 600))
    .listen((searchText) {
  _filterItems(searchText);
});
```

#### 搜索逻辑
- 支持同时匹配 `name` 和 `address` 字段
- 不区分大小写
- 实时更新过滤结果
- 空输入时显示全部选项

### 3. 使用位置

#### 入库方项目下拉框
- 搜索字段：项目名称（`name`）
- 实时过滤项目列表
- 用户体验：点击输入框展开所有项目，输入关键词实时过滤

#### 接收仓库下拉框
- 搜索字段：仓库名称（`name`）+ 地址（`address`）
- 同时匹配两个字段的内容
- 用户体验：点击输入框展开所有仓库，输入关键词实时过滤

### 4. UI/UX 特性
- **单一输入框**：集成搜索和选择功能，无需额外搜索框
- **动态下拉箭头**：展开时向上，收起时向下
- **清除按钮**：输入内容时自动显示，可一键清空
- **已选项高亮**：当前选中项带背景色和勾选图标
- **空状态提示**：无匹配结果时显示友好提示
- **浮层定位**：跟随输入框位置，自动计算偏移
- **最大高度限制**：300px，超出可滚动
- **分隔线**：列表项之间带细线分隔
- **业务主题色**：边框、图标使用业务色（dispatch）

### 5. 交互流程
1. **打开下拉**：用户点击输入框 → 焦点进入 → 自动展开浮层显示所有选项
2. **搜索过滤**：用户输入关键词 → 600ms 防抖后过滤 → 实时更新浮层列表
3. **选择选项**：用户点击某个选项 → 选中 → 失去焦点 → 浮层自动收起 → 显示选中值
4. **点击外部**：用户点击下拉框外任意区域 → 失去焦点 → 浮层自动收起 → 恢复显示已选值
5. **页面切换**：用户导航到其他页面 → 组件自动清理 → 浮层被正确移除
6. **失去焦点**：用户点击其他输入框或组件 → 浮层收起 → 恢复显示已选中的值

### 6. 性能优化与资源管理
- **搜索优化**：使用 `BehaviorSubject` 管理搜索状态流
- **防抖处理**：600毫秒防抖，避免频繁过滤计算
- **渲染优化**：`Overlay` 实现浮层，避免重建整个组件树
- **外部点击检测**：使用 `GestureDetector` + `HitTestBehavior.translucent` 捕获全屏点击
- **生命周期管理**：
  - `deactivate()`：页面切换时自动关闭浮层
  - `dispose()`：组件销毁时完整清理资源
    - 移除焦点监听器
    - 移除 Overlay
    - 释放 TextController
    - 释放 FocusNode
    - 关闭 BehaviorSubject

## 文件修改
- `lib/pages/dispatch/dispatch_application_page.dart`
  - 添加 `rxdart` 导入
  - 创建 `_SearchableDropdown<T>` 组件
  - 更新 `_buildDropdownRow` 方法
  - 为两个下拉框添加 `getSearchText` 参数

## 使用示例

### 项目下拉框（仅搜索名称）
```dart
_buildDropdownRow<ProjectSimpleVo>(
  label: '入库方项目:',
  value: _selectedTargetProject,
  items: state.availableProjects,
  onChanged: (value) {
    setState(() {
      _selectedTargetProject = value;
    });
  },
  itemBuilder: (item) => Text(item.name),
  selectedLabelBuilder: (item) => item.name,
  errorMessage: state.availableProjectsError,
  getSearchText: (item) => item.name, // 只搜索项目名称
),
```

### 仓库下拉框（搜索名称+地址，带标识）
```dart
_buildDropdownRow<WarehouseVO>(
  label: '接收仓库:',
  value: _selectedTargetWarehouse,
  items: state.availableWarehouses,
  onChanged: (value) {
    if (value != null) {
      // 选择仓库后加载对应的用户列表
      context.read<DispatchBloc>().add(
        UpdateWarehouseUsersList(warehouseId: value.id),
      );
    }
    setState(() {
      _selectedTargetWarehouse = value;
    });
  },
  itemBuilder: (item) => _buildWarehouseItemWidget(item), // 自定义仓库项显示
  selectedLabelBuilder: (item) => '${item.name} - ${item.address}',
  errorMessage: state.availableWarehousesError,
  getSearchText: (item) => '${item.name} ${item.address}', // 同时搜索名称和地址
),
```

#### 仓库项自定义显示
```dart
Widget _buildWarehouseItemWidget(WarehouseVO warehouse) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 仓库名称和地址
            Text('${warehouse.name} - ${warehouse.address}'),
            SizedBox(height: 2),
            // 仓库类型标识
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: warehouse.isRealWarehouse
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                warehouse.isRealWarehouse ? '独立仓库' : '项目现场',
                style: TextStyle(
                  fontSize: 11,
                  color: warehouse.isRealWarehouse ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
```

## 对比传统实现的优势

### 传统两组件方案（搜索框 + 下拉框分离）
❌ 占用更多垂直空间  
❌ 需要在两个组件间切换操作  
❌ 用户认知成本高  

### 当前方案（类似 Element UI el-select）
✅ 单一输入框，操作直观  
✅ 节省页面空间  
✅ 交互流畅，符合主流 Web 应用习惯  
✅ 无需逐个浏览长列表  
✅ 实时反馈搜索结果  
✅ 防抖避免性能问题  
✅ 一键清除选择内容  

## 测试建议
1. **基础搜索**：输入关键词，验证过滤结果是否正确
2. **防抖效果**：快速连续输入，验证600ms后才触发过滤
3. **清除功能**：点击清除按钮，验证选择被清空
4. **无匹配结果**：输入不存在的关键词，验证提示显示
5. **外部点击关闭**：
   - 点击下拉框外的空白区域，验证浮层自动收起
   - 点击其他输入框，验证当前浮层自动收起
   - 点击"继续扫码"按钮，验证浮层自动收起
6. **页面切换**：
   - 打开下拉框后，点击返回按钮，验证浮层正确清理
   - 打开下拉框后，跳转到扫码页面再返回，验证浮层不会保持打开状态
7. **已选项高亮**：选择一个项目后重新打开，验证高亮显示
8. **项目下拉框**：测试按项目名称搜索
9. **仓库下拉框**：测试同时匹配仓库名称和地址
10. **边界情况**：空列表、单项列表、长列表滚动
11. **多实例测试**：同时存在两个下拉框时，打开一个能否正确关闭另一个

## 技术亮点
✅ **外部点击检测**：使用全屏 `GestureDetector` 捕获点击事件，点击浮层外自动关闭  
✅ **事件冒泡控制**：浮层内部使用嵌套 `GestureDetector` 阻止事件冒泡  
✅ **完整生命周期管理**：`deactivate()` + `dispose()` 双重保障，页面切换时自动清理  
✅ **焦点联动**：失去焦点时自动关闭，无需手动管理  

## 已知限制
- 浮层宽度固定与输入框相同
- 浮层始终显示在输入框下方（未处理屏幕底部边界）
- 暂不支持键盘上下键选择（未来可增强）
- 多个下拉框同时打开时，需要依赖焦点管理自动关闭前一个

## 未来增强方向
1. 键盘导航支持（上下方向键选择）
2. 智能浮层位置（屏幕底部时向上展开）
3. 虚拟滚动优化（超大列表性能）
4. 多选模式支持
5. 自定义空状态模板
