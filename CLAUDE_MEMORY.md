# SSE+HTTP 通知系统设计和实现成果

## 系统概述

### 目标
实现一个基于SSE(Server-Sent Events)+HTTP模式的实时通知系统，用于水管理项目的实时消息接收、解析和分发。

### 核心逻辑流程
1. 用户登录成功后，判断`WxLoginVO.own`字段是否为`true`
2. 若`own=true`，调用SSE接口建立监听通道
3. 接收服务端消息，进入解析流程
4. 解析成功后，通过通用分发机制触发后续操作
5. 各模块根据职责决定是否响应通知并执行操作
6. 处理APP切入后台、杀死进程等边界情况

## 架构设计

### 核心组件架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  SessionBloc    │───▶│NotificationMgr │───▶│   SSE Service   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│BackgroundHandler│◀───│  Dispatcher    │◀───│Message Parser   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │Auth Helper      │
                       └─────────────────┘
```

### 技术栈选择
- **SSE连接**: HTTP Client (原生Dart实现)
- **状态管理**: BLoC + Cubit (遵循现有项目模式)
- **依赖注入**: GetIt (现有项目模式)
- **认证机制**: 复用现有`tk` token系统
- **消息解析**: 策略模式，支持多种消息格式
- **事件分发**: Stream-based发布订阅模式

## 核心组件详解

### 1. SSE服务 (`SseService`)
**文件**: `lib/services/sse/sse_service.dart`

**功能**:
- 基于HTTP Client的SSE连接实现
- 自动重连机制(指数退避)
- 心跳检测和连接监控
- 连接状态管理

**关键特性**:
- 支持Last-Event-ID用于消息去重
- 自动处理网络异常和超时
- 电池优化的后台处理
- 完整的错误恢复机制

### 2. 认证帮助类 (`SseAuthHelper`)
**文件**: `lib/services/sse/sse_auth_helper.dart`

**功能**:
- 集成现有UserRepository获取认证信息
- 复用现有`tk` token机制
- 权限检查(`own`字段验证)
- 认证状态刷新和管理

**关键方法**:
- `getAuthHeaders()`: 获取SSE连接认证头
- `hasNotificationPermission()`: 检查通知权限
- `refreshAuthInfo()`: 刷新认证信息

### 3. 通知管理器 (`NotificationManager`)
**文件**: `lib/services/notification/notification_manager.dart`

**功能**:
- 系统状态管理和协调
- 健康检查和性能监控
- 统计信息收集
- 单例模式实现

**核心状态**:
- `idle`: 空闲状态
- `starting`: 启动中
- `running`: 运行中
- `stopping`: 停止中
- `stopped`: 已停止
- `error`: 错误状态

### 4. 消息分发器 (`NotificationDispatcher`)
**文件**: `lib/services/notification/notification_dispatcher.dart`

**功能**:
- 基于Stream的事件分发系统
- 支持多处理器注册
- 优先级管理
- 事件跟踪和监控

**核心接口**:
- `NotificationHandler`: 处理器契约
- `BaseNotificationHandler`: 处理器基类
- `NotificationDispatchEvent`: 分发事件类型

### 5. 消息解析器 (`MessageParser`)
**文件**: `lib/services/notification/message_parser.dart`

**功能**:
- 策略模式的消息解析
- 支持多种消息格式(JSON/文本)
- 错误处理和验证
- 可扩展的解析器注册

**解析器类型**:
- `JsonMessageParser`: JSON格式消息解析
- `TextMessageParser`: 纯文本消息解析
- `MessageParserFactory`: 解析器工厂

### 6. 后台处理器 (`BackgroundNotificationHandler`)
**文件**: `lib/services/notification/background_handler.dart`

**功能**:
- 应用生命周期状态管理
- 后台连接策略
- 电池优化处理
- 应用终止清理

**生命周期处理**:
- `foreground` → `background`: 连接保持策略
- `background` → `foreground`: 重新连接机制
- `detached`: 应用终止清理

## 数据模型

### 1. SSE消息 (`SseMessageVO`)
**文件**: `lib/models/notification/sse_message_vo.dart`

```dart
class SseMessageVO {
  final String id;        // 消息唯一标识
  final String event;     // 事件类型
  final String data;      // 消息数据
  final DateTime? timestamp; // 时间戳
}
```

### 2. 通知消息 (`NotificationMessageVO`)
**文件**: `lib/models/notification/notification_message_vo.dart`

```dart
class NotificationMessageVO {
  final String id;                    // 消息ID
  final String type;                  // 消息类型
  final String title;                 // 消息标题
  final String content;               // 消息内容
  final NotificationPriority priority; // 优先级
  final NotificationActionVO? action; // 关联操作
  final DateTime? expiresAt;          // 过期时间
}
```

### 3. 通知操作 (`NotificationActionVO`)
**文件**: `lib/models/notification/notification_action_vo.dart`

```dart
class NotificationActionVO {
  final String type;           // 操作类型
  final String method;         // 调用方法
  final String? url;          // 请求URL
  final Map<String, dynamic>? params; // 请求参数
  final UiActionVO? uiAction; // UI操作
}
```

## 集成点和使用方式

### 1. 自动启动机制
在`SessionBloc`中，当用户登录成功且项目建立时：
```dart
// SessionBloc._onProjectSelected()
if (wxLoginVO.own) {
  _startNotificationSystem(wxLoginVO);
}
```

### 2. 依赖注入配置
在`service_locator.dart`中注册：
```dart
// Notification Services
getIt.registerSingleton<NotificationManager>(
  NotificationManager.instance,
);
getIt.registerSingleton<BackgroundNotificationHandler>(
  BackgroundNotificationHandler.instance,
);
```

### 3. 环境配置
在`AppConfig.dart`中添加SSE相关配置：
```dart
static String get sseBaseUrl {
  switch (_environment) {
    case Environment.development:
      return 'http://10.3.6.235/sse';
    // ... 其他环境配置
  }
}
```

## 文件结构清单

### 新增文件
```
lib/
├── models/notification/
│   ├── sse_message_vo.dart
│   ├── notification_message_vo.dart
│   ├── notification_action_vo.dart
│   └── (对应的.g.dart文件)
├── services/
│   ├── sse/
│   │   ├── sse_service.dart
│   │   └── sse_auth_helper.dart
│   └── notification/
│       ├── notification_manager.dart
│       ├── notification_dispatcher.dart
│       ├── message_parser.dart
│       └── background_handler.dart
```

### 修改文件
```
lib/
├── config/
│   ├── app_config.dart          // 添加SSE配置
│   └── service_locator.dart     // 注册通知服务
├── bloc/
│   └── session/
│       └── session_bloc.dart     // 集成通知系统启动
└── pubspec.yaml                  // 添加eventflux依赖
```

## 核心特性总结

### ✅ 已实现功能
1. **权限控制**: 仅当`wxLoginVO.own=true`时启动
2. **认证集成**: 复用现有`tk` token机制
3. **实时连接**: SSE长连接，支持自动重连
4. **消息解析**: 支持JSON和文本格式，可扩展
5. **事件分发**: Stream-based发布订阅模式
6. **生命周期**: 完整的前后台状态管理
7. **错误恢复**: 多层级的错误处理和恢复
8. **性能优化**: 电池友好的后台处理
9. **监控统计**: 完整的运行状态监控
10. **日志记录**: 详细的调试和错误日志

### 🔧 技术亮点
- **Clean Architecture**: 遵循现有项目架构模式
- **策略模式**: 可扩展的消息解析机制
- **单例模式**: 统一的管理器实例
- **流式编程**: 响应式的事件处理
- **依赖注入**: 完整的服务注册和管理
- **生命周期感知**: 智能的后台处理

### 📊 性能考虑
- **内存使用**: 优化的消息处理和缓存策略
- **网络效率**: 智能的重连和心跳机制
- **电池优化**: 后台连接的智能管理
- **CPU使用**: 异步处理和合理的轮询间隔

## 使用示例

### 基本使用
```dart
// 获取通知管理器实例
final notificationManager = NotificationManager.instance;

// 启动通知系统
await notificationManager.start();

// 注册自定义处理器
notificationManager.registerHandler(MyCustomHandler());

// 监听消息流
notificationManager.dispatcher.messageStream.listen((message) {
  print('收到通知: ${message.title}');
});
```

### 自定义处理器
```dart
class MyCustomHandler extends BaseNotificationHandler {
  @override
  String get handlerId => 'my_custom_handler';

  @override
  List<String> getSupportedTypes() => ['task', 'alert'];

  @override
  Future<void> doHandle(NotificationMessageVO message) async {
    // 处理通知逻辑
    if (message.type == 'task') {
      // 处理任务通知
    } else if (message.type == 'alert') {
      // 处理警报通知
    }
  }
}
```

## 后续扩展建议

### 1. 消息类型扩展
- 添加更多消息解析器
- 支持二进制消息格式
- 添加消息加密支持

### 2. UI集成
- 通知栏显示
- 弹窗提醒
- 声音和震动反馈

### 3. 存储和缓存
- 消息持久化存储
- 离线消息缓存
- 消息历史查询

### 4. 高级功能
- 消息推送集成
- 用户偏好设置
- 消息过滤和分类

这个系统为智慧水务项目提供了完整的实时通知基础设施，具有良好的扩展性和维护性。