# 追踪系统修复验证计划

## 当前修复状态 ✅

### 已修复的问题：
1. **TracingInterceptor 更新**: 现在使用 ImprovedTracingManager.currentPageContext
2. **扩展方法导入**: AcceptanceBloc 和 DispatchBloc 已导入扩展方法
3. **服务注册**: ImprovedTracingManager 已注册到 Service Locator
4. **导航观察器**: TracingNavigatorObserver 使用 ImprovedTracingManager

### 观察到的行为：
1. **页面导航**: ImprovedTracingManager 正确推入/移除页面上下文
2. **HTTP 请求**: TracingInterceptor 正确获取页面上下文并添加追踪头
3. **Tab 切换**: 底部标签页切换正常工作

## 待验证的测试场景

### 1. 验收申请页面导航测试
**步骤**: 从首页导航到验收申请页面
**预期结果**: 
- TracingNavigatorObserver 推入 "验收申请 (via push)" 页面上下文
- TracingInterceptor 显示正确的页面上下文
- 验收页面的操作应显示 "验收申请 - xxx" 而不是 "首页 - xxx"

### 2. 验收页面操作测试
**步骤**: 在验收申请页面执行加载材料、用户、仓库等操作
**预期结果**:
- 扩展方法应该调用 ImprovedTracingManager.scopeActionWithTitle
- 操作应显示为 "验收申请 - 加载验收材料" 等
- HTTP 请求头应包含验收申请页面的追踪信息

### 3. 并发操作测试
**步骤**: 在验收页面同时触发多个操作
**预期结果**:
- 多个操作应该并发执行而不相互干扰
- 每个操作有独立的 UUID 标识
- 操作完成顺序可能不同，但都应正确追踪

## 当前问题分析

### 页面上下文层级问题
**现象**: TracingInterceptor 显示 "主页面 (via push)" 而不是 "首页"
**原因**: TabBar 页面的上下文可能被 main 页面上下文覆盖
**解决方案**: 需要检查 Tab 页面的路由名称和上下文管理

### 混合系统问题
**现象**: 同时看到 TracingManager 和 ImprovedTracingManager 的日志
**原因**: Tab 切换仍在使用老的 TracingManager
**影响**: 可能导致上下文不一致

## 下一步行动

1. **测试验收页面导航**: 验证页面上下文是否正确更新
2. **检查 Tab 页面追踪**: 确保 Tab 页面使用正确的追踪系统
3. **验证扩展方法**: 确认 AcceptanceBloc 操作使用新的追踪系统
4. **并发测试**: 验证多个操作的并发追踪

## 成功指标

### 完全修复的标志：
1. ✅ TracingInterceptor 使用 ImprovedTracingManager
2. ⏳ 验收页面显示正确的页面上下文
3. ⏳ 验收操作显示 "验收申请 - xxx" 格式
4. ⏳ 并发操作正常工作且有独立追踪
5. ⏳ 追踪日志中左侧栏不再空白

如果以上指标全部达成，说明追踪系统完全迁移成功。
