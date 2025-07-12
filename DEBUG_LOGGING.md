# 调试日志使用指南

## 问题描述
你遇到的日志截断问题（`<...>`）是Flutter的debugPrint函数的限制导致的。Flutter会自动截断超过1024字符的输出。

## 解决方案

### 1. 自动完整日志
现在网络请求的响应已经自动使用完整日志输出，不会再被截断。

### 2. 手动调试特定数据
如果需要调试特定的数据，可以使用：

```dart
import '../utils/network_logger.dart';

// 在任何地方完整打印JSON数据
NetworkLogger.printFullJson(yourData, title: 'DEBUG_DATA');

// 例如在BLoC中调试状态
NetworkLogger.printFullJson(result.data?.toJson(), title: 'LOGIN_RESULT');
```

### 3. 在代码中临时添加调试
```dart
// 在SMS登录成功后
if (result.isSuccess && result.data != null) {
  // 完整查看登录响应数据
  NetworkLogger.printFullJson(result.data!.toJson(), title: 'FULL_LOGIN_DATA');
}
```

## 日志输出格式

### 修复前（被截断）：
```
[E32m] Body:<...>
[E32m]   \xA[<...>
[E32m]     \xA[<0m  "code"<...>
```

### 修复后（完整显示）：
```
┌─── 📋 SMS_LOGIN_RESPONSE 
│
│ {
│   "code": 0,
│   "msg": "登录成功",
│   "tc": 600,
│   "data": {
│     "id": "user_123",
│     "tk": "6a328640-757b-4c17-beaf-5fcad618aa...",
│     "phone": "13800138000",
│     "name": "测试用户",
│     // ... 完整数据
│   }
│ }
│
└─── END SMS_LOGIN_RESPONSE 
```

## 使用建议

1. **网络请求**: 自动完整输出，无需额外操作
2. **BLoC状态**: 在关键状态变化时手动添加完整日志
3. **复杂对象**: 使用`NetworkLogger.printFullJson()`查看完整结构
4. **临时调试**: 在需要的地方添加调试代码，完成后记得删除

## 注意事项

- 完整日志仅在DEBUG模式下输出
- 超长数据会自动分段显示，带有`[续]`和`[未完]`标记
- 建议在生产环境前移除临时调试代码