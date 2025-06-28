# Mock 数据机制使用指南

## 概述

本项目实现了一套灵活的 Mock 数据机制，支持在 Mock 数据和真实 API 之间快速切换，便于独立开发和测试。

## 架构设计

### 1. 配置管理
- `AppConfig`: 管理环境配置和数据源切换
- 支持三种环境：Development、Staging、Production
- 支持两种数据源：Mock、API

### 2. 服务抽象
- `ApiServiceInterface`: 定义 API 服务接口
- `ApiService`: 真实 API 服务实现
- `MockApiService`: Mock 数据服务实现
- `ApiServiceFactory`: 根据配置创建对应的服务实例

### 3. Mock 数据生成
- `MockDataGenerator`: 生成模拟数据
- 支持随机生成用户、列表项等数据
- 模拟网络延迟和错误场景

## 使用方法

### 快速切换数据源

在 `main.dart` 中选择以下方法之一：

```dart
// 使用 Mock 数据（当前默认）
await setupMockEnvironment();

// 使用真实 API（开发环境）
await setupDevelopmentEnvironment();

// 使用真实 API（生产环境）
await setupProductionEnvironment();
```

### 运行时切换

1. 启动应用
2. 导航到 Profile 页面
3. 点击 "Developer Settings"（仅在开发环境显示）
4. 选择环境和数据源
5. 重启应用以应用更改

### 自定义配置

```dart
await setupServiceLocator(
  environment: Environment.development,
  dataSource: DataSource.mock,
);
```

## Mock 功能特性

### 1. 真实的网络体验
- 模拟网络延迟（500ms - 2s）
- 随机失败率（可配置）
- 错误消息模拟

### 2. 丰富的测试数据
- 随机生成用户信息
- 多样化的列表项内容
- 真实的时间戳

### 3. 完整的 API 覆盖
- 登录/注册
- 用户资料获取
- 列表数据 CRUD 操作

## 开发工作流

### 独立开发（无后端）
1. 使用 `setupMockEnvironment()`
2. 所有功能基于 Mock 数据工作
3. 完整的 UI 开发和测试

### 后端集成
1. 配置真实 API 地址在 `AppConfig`
2. 切换到 `setupDevelopmentEnvironment()`
3. 逐步替换 Mock 实现

### 生产部署
1. 使用 `setupProductionEnvironment()`
2. 确保所有 Mock 相关代码不在生产包中

## 扩展 Mock 数据

### 添加新的 API 接口

1. 在 `ApiServiceInterface` 中定义接口
2. 在 `ApiService` 中实现真实逻辑
3. 在 `MockApiService` 中实现 Mock 逻辑
4. 在 `MockDataGenerator` 中添加数据生成方法

### 自定义 Mock 场景

```dart
// 自定义失败率
if (MockDataGenerator.shouldFail(failureRate: 0.3)) {
  throw 'Custom error message';
}

// 自定义延迟
await MockDataGenerator.simulateNetworkDelay(
  delay: Duration(seconds: 3),
);
```

## 最佳实践

### 1. 开发阶段
- 使用 Mock 数据进行 UI 开发
- 测试各种数据状态（空、满、错误）
- 验证加载和错误处理逻辑

### 2. 集成阶段
- 保持 Mock 和真实 API 的一致性
- 使用相同的数据模型
- 测试切换功能

### 3. 生产部署
- 移除或隐藏开发者设置
- 确保生产环境配置正确
- 监控 API 调用状态

## 配置参考

### 环境配置

```dart
enum Environment {
  development,   // 开发环境
  staging,      // 测试环境
  production,   // 生产环境
}
```

### 数据源配置

```dart
enum DataSource {
  mock,  // Mock 数据
  api,   // 真实 API
}
```

### API 基础地址

```dart
// 在 AppConfig 中配置
static String get apiBaseUrl {
  switch (_environment) {
    case Environment.development:
      return 'https://dev-api.example.com';
    case Environment.staging:
      return 'https://staging-api.example.com';
    case Environment.production:
      return 'https://api.example.com';
  }
}
```

## 故障排除

### 常见问题

1. **Mock 数据不显示**
   - 检查 `AppConfig.dataSource` 设置
   - 确认服务注册正确

2. **切换不生效**
   - 重启应用
   - 检查服务定位器配置

3. **开发者设置不显示**
   - 确认处于开发环境
   - 检查 `AppConfig.isDevelopment`

### 调试技巧

```dart
// 打印当前配置
debugPrint('Environment: ${AppConfig.environment}');
debugPrint('Data Source: ${AppConfig.dataSource}');
debugPrint('API Base URL: ${AppConfig.apiBaseUrl}');
debugPrint('Mock Enabled: ${AppConfig.isMockEnabled}');
```

## 总结

这套 Mock 机制提供了：
- 🚀 快速开发：无需后端即可开发前端
- 🔄 灵活切换：Mock 和真实数据一键切换
- 🎯 真实体验：模拟真实网络环境
- 🧪 完整测试：覆盖各种场景和状态
- 📱 运行时配置：开发者设置页面