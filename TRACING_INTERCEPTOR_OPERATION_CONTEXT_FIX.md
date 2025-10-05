# TracingInterceptor 操作上下文修复

## 🎯 **问题诊断**

用户发现虽然页面级别的上下文已经正确（"验收申请 (via push)"），但是具体的操作（如"加载验收用户"、"加载仓库列表"）没有出现在服务器日志中。

查看终端日志发现：
- **ImprovedTracingManager** 正确跟踪操作：`验收申请 (via push) - 首页 - 加载验收用户`
- **TracingInterceptor** 只获取页面上下文：`验收申请 (via push)`

## 🔧 **根本原因**

TracingInterceptor 只获取 `currentPageContext`（页面级上下文），没有获取当前正在执行的**活跃操作上下文**。

## 🛠️ **修复方案**

更新 TracingInterceptor 的上下文获取逻辑：

```dart
// 优先获取当前活跃操作的上下文，如果没有则使用页面上下文
final activeOperations = improvedTracingManager.activeOperations;
final pageContext = improvedTracingManager.currentPageContext;

// 选择最具体的上下文：活跃操作 > 页面上下文
if (activeOperations.isNotEmpty) {
  // 使用最近开始的活跃操作（通常是当前正在执行的操作）
  final latestOperation = activeOperations.reduce((a, b) => 
    a.startTime.isAfter(b.startTime) ? a : b);
  contextDescription = latestOperation.description;
} else if (pageContext != null) {
  // 后备：使用页面上下文
  contextDescription = pageContext.description;
}
```

## 📈 **预期效果**

修复后，服务器日志应该显示：

### HTTP 请求期间
```
验收申请 (via push) - 首页 - 加载验收用户 | 李逸群
验收申请 (via push) - 首页 - 加载仓库列表 | 李逸群
```

### 非操作期间（后备）
```
验收申请 (via push) | 李逸群
```

## 🔍 **技术细节**

1. **优先级策略**：活跃操作上下文 > 页面上下文
2. **最新操作选择**：如果有多个活跃操作，选择最近开始的
3. **向后兼容**：如果没有活跃操作，回退到页面上下文
4. **操作ID跟踪**：在上下文中包含操作ID用于关联

## 🧪 **测试验证**

修复后需要验证：
1. 导航到验收申请页面
2. 触发加载操作（用户列表、仓库列表）
3. 检查服务器日志是否显示具体的操作描述
4. 确认在没有活跃操作时仍显示页面上下文

这个修复确保了 TracingInterceptor 能够获取到最具体的操作上下文，从而在服务器日志中提供完整的操作追踪信息。
