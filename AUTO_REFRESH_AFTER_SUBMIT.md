## 盘点提交后列表自动刷新功能

### 实现说明

在 `InventoryBloc._onSubmitted` 方法中，当盘点提交成功后，会自动触发列表刷新：

```dart
await _inventoryRepository.submitInventory(request);
emit(state.copyWith(submissionStatus: SubmissionStatus.success));

// 提交成功后重新刷新列表
add(const InventoryTasksFetched(isRefresh: true));
```

### 测试步骤

1. **进入盘点详情页面**
   - 从盘点列表选择一个任务
   - 进入详情页面

2. **完成盘点操作**
   - 进行扫码盘点（可选）
   - 上传两张照片
   - 点击提交按钮

3. **验证自动刷新**
   - 提交成功后会显示成功提示
   - 自动返回到列表页面
   - 验证列表中的数据已更新（如状态变化、时间更新等）
   - 不需要手动下拉刷新

### 技术细节

- 使用 `add(const InventoryTasksFetched(isRefresh: true))` 触发列表刷新
- `isRefresh: true` 确保从第一页开始重新加载
- 刷新是异步进行的，不会阻塞用户界面
- 用户返回列表页面时，新数据可能已经加载完成

### 优势

1. **用户体验好**: 提交后自动看到最新状态，无需手动刷新
2. **数据一致性**: 确保显示的数据与服务器状态一致
3. **减少操作**: 避免用户手动刷新的额外操作
4. **实时性**: 状态变化立即反映在列表中
