# 改进的 TracingManager 设计方案

## 🎯 目标

解决当前 TracingManager 在并发操作中的上下文覆盖问题，支持真正的并发追踪。

## 🚀 核心改进

### 1. 增强的追踪上下文 (EnhancedTracingContext)

```dart
class EnhancedTracingContext {
  final String id;              // 唯一标识符
  final String? parentId;       // 父操作ID，支持操作链
  final DateTime startTime;     // 开始时间
  final DateTime? endTime;      // 结束时间
  final String source;          // 操作源
  final String action;          // 操作类型
  final String? description;    // 描述
  final String? entityId;       // 实体ID
}
```

### 2. 并发支持的追踪管理器

**关键特性：**
- ✅ **并发操作隔离**：每个操作有独立的上下文ID
- ✅ **操作链追踪**：支持父子操作关系
- ✅ **性能监控**：自动计算操作耗时
- ✅ **历史记录**：保存操作历史用于分析
- ✅ **页面导航**：独立的页面上下文栈

## 📊 架构对比

### 当前架构 (有问题)
```
TracingManager (单例)
├── Queue<TracingContext> _contextStack  // 共享栈
├── pushContext()
├── popContext()
└── scopeAction()  // 假设栈顶=当前操作
```

**问题：**
- 并发操作会覆盖栈顶上下文
- 无法区分不同的操作链
- 缺乏操作性能监控

### 改进架构 (解决方案)
```
ImprovedTracingManager (单例)
├── Map<String, EnhancedTracingContext> _activeContexts    // 活跃操作
├── Queue<EnhancedTracingContext> _completedContexts      // 历史记录
├── Queue<TracingContext> _pageContextStack               // 页面导航
├── createOperationContext()                              // 创建操作上下文
├── scopeOperation()                                      // 执行追踪操作
└── getOperationChain()                                   // 获取操作链
```

**优势：**
- ✅ 支持无限并发操作
- ✅ 每个操作独立追踪
- ✅ 操作链可视化
- ✅ 性能数据收集

## 🔄 使用场景示例

### 场景1：串行操作（当前方案）
```dart
// 加载用户 -> 加载仓库
await loadUsers();
await loadWarehouses();
```

**追踪结果：**
```
Push: 验收申请 - 加载验收用户
Pop:  验收申请 - 加载验收用户
Push: 验收申请 - 加载仓库列表
Pop:  验收申请 - 加载仓库列表
```

### 场景2：并发操作（改进方案）
```dart
// 并发加载
await Future.wait([
  tracingManager.scopeOperation(userContext, loadUsers),
  tracingManager.scopeOperation(warehouseContext, loadWarehouses),
]);
```

**追踪结果：**
```
Start: [ID1] 验收申请 - 加载验收用户
Start: [ID2] 验收申请 - 加载仓库列表
End:   [ID1] 验收申请 - 加载验收用户 (500ms)
End:   [ID2] 验收申请 - 加载仓库列表 (800ms)
```

### 场景3：操作链追踪
```dart
// 父操作：初始化数据
const parentContext = createOperationContext(
  description: '验收申请 - 初始化数据加载',
);

// 子操作1：加载用户
const userContext = createOperationContext(
  description: '验收申请 - 加载验收用户',
  parentId: parentContext.id,
);

// 子操作2：加载仓库
const warehouseContext = createOperationContext(
  description: '验收申请 - 加载仓库列表',
  parentId: parentContext.id,
);
```

**操作链可视化：**
```
验收申请 - 初始化数据加载 (1200ms)
├── 验收申请 - 加载验收用户 (500ms)
└── 验收申请 - 加载仓库列表 (800ms)
```

## 📈 性能监控

改进后的 TracingManager 自动收集性能数据：

```dart
final stats = tracingManager.getPerformanceStats();
// 输出：
{
  "totalOperations": 15,
  "averageDuration": 650.5,
  "medianDuration": 500,
  "minDuration": 200,
  "maxDuration": 1500,
  "activeOperations": 2
}
```

## 🔧 迁移策略

### 阶段1：并行部署
- 保留现有 TracingManager
- 引入 ImprovedTracingManager
- 新功能使用改进版本

### 阶段2：逐步迁移
- 关键模块切换到改进版本
- 对比两个版本的数据
- 验证稳定性

### 阶段3：完全切换
- 所有模块使用改进版本
- 移除旧的 TracingManager
- 优化性能

## 🎯 立即收益

使用改进后的 TracingManager，验收模块可以：

1. **并发加载**：用户和仓库数据同时请求
2. **精确追踪**：每个操作独立记录
3. **性能监控**：实时了解操作耗时
4. **错误诊断**：快速定位慢操作
5. **用户体验**：减少等待时间

## 📝 结论

改进的 TracingManager 从根本上解决了并发追踪的问题，不仅支持当前的串行方案，更为未来的并发优化奠定了基础。

**推荐实施顺序：**
1. 🔧 实现 ImprovedTracingManager
2. 🧪 在验收模块试点使用
3. 📊 收集性能数据对比
4. 🚀 逐步推广到其他模块
5. 🎯 最终实现全并发追踪
