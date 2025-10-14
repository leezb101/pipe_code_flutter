# 会话错误回退功能实现文档

## 概述

本次更新将会话错误页面的"重试"按钮改为"返回上一步"按钮，使用户能够在网络请求失败时回退到上一个需要用户交互的操作状态。

## 主要变更

### 1. SessionState 增强 (`lib/bloc/session/session_state.dart`)

为 `SessionError` 状态添加了更多上下文信息：

```dart
class SessionError extends SessionState {
  const SessionError({
    required this.error,
    this.previousStateType,          // 新增：上一个状态的类型
    this.wxLoginVO,                  // 新增：用户信息
    this.availableProjects,          // 新增：可用项目列表
    this.wasAutoSelectingProject,    // 新增：是否在自动选择项目时出错
  });
  
  // ... 字段定义
}
```

**字段说明：**
- `previousStateType`: 记录发生错误前的状态类型，用于回退时选择正确的目标状态
- `wxLoginVO`: 保存用户登录信息，回退时重建状态需要
- `availableProjects`: 保存可用项目列表，回退到项目选择页需要
- `wasAutoSelectingProject`: 标记是否在自动选择项目时出错，用于决定是否清除缓存

### 2. SessionEvent 新增事件 (`lib/bloc/session/session_event.dart`)

新增 `SessionGoBackFromError` 事件：

```dart
/// 从错误状态返回上一步
class SessionGoBackFromError extends SessionEvent {
  const SessionGoBackFromError();
}
```

### 3. SessionBloc 核心逻辑 (`lib/bloc/session/session_bloc.dart`)

#### 3.1 状态追踪

添加 `_previousState` 字段用于追踪上一个状态：

```dart
// 用于追踪上一个状态，以便从错误状态回退
SessionState? _previousState;
```

#### 3.2 状态转换时保存上一个状态

在所有可能产生错误的状态转换方法中，保存当前状态作为上一个状态：

```dart
final currentState = state;
_previousState = currentState is! SessionError ? currentState : _previousState;
```

#### 3.3 错误发生时携带上下文信息

在发生错误时，将上下文信息传递给 SessionError：

```dart
emit(SessionError(
  error: result.msg,
  previousStateType: _previousState?.runtimeType,
  wxLoginVO: _cachedWxLoginVO,
  availableProjects: _cachedWxLoginVO?.projectInfos ?? [],
  wasAutoSelectingProject: true,  // 标记为自动选择项目失败
));
```

#### 3.4 回退处理逻辑

新增 `_onGoBackFromError` 方法处理回退：

```dart
Future<void> _onGoBackFromError(
  SessionGoBackFromError event,
  Emitter<SessionState> emit,
) async {
  final currentState = state;
  if (currentState is! SessionError) return;

  // 1. 如果是自动选择项目失败，清除本地缓存
  if (currentState.wasAutoSelectingProject) {
    await _projectRepository.clearProjectData();
  }

  // 2. 根据上一个状态类型决定回退目标
  // 优先级：
  //   - SessionIdentitySelectionRequired -> 回到身份选择页
  //   - SessionProjectSelectionRequired -> 回到项目选择页
  //   - SessionLoading -> 智能判断回退目标
  //   - 其他 -> 默认回退逻辑
  
  // 3. 清除上一个状态记录
  _previousState = null;
}
```

### 4. SessionGuard UI 更新 (`lib/widgets/session_guard.dart`)

#### 4.1 更新错误视图

将 `_buildErrorView` 方法参数从 `String error` 改为 `SessionError errorState`，并优化 UI：

```dart
Widget _buildErrorView(BuildContext context, SessionError errorState) {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('操作失败', style: ...),
            const SizedBox(height: 12),
            Text(errorState.error, style: ...),
            const SizedBox(height: 32),
            // "返回上一步" 按钮
            ElevatedButton.icon(
              onPressed: () {
                context.read<SessionBloc>().add(
                  const SessionGoBackFromError(),
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回上一步'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

#### 4.2 更新错误状态分支

```dart
case SessionError():
  final state = sessionState;
  return _buildErrorView(context, state);  // 传递完整的 SessionError 对象
```

## 回退逻辑流程

```
错误发生
  ↓
用户点击"返回上一步"
  ↓
SessionGoBackFromError 事件触发
  ↓
判断是否为自动选择项目失败
  ↓ 是
清除项目缓存 (clearProjectData)
  ↓
根据 previousStateType 决定回退目标：
  ├─ SessionIdentitySelectionRequired → 身份选择页
  ├─ SessionProjectSelectionRequired → 项目选择页
  ├─ SessionLoading → 智能判断
  └─ 默认 → 优先项目选择页，次之身份选择页
  ↓
发射目标状态
  ↓
清除 _previousState
```

## 特殊处理

### 自动选择项目失败

当 `wasAutoSelectingProject = true` 时：
1. 清除本地缓存的项目选择信息
2. 防止下次登录时再次自动选择同一个失败的项目
3. 强制用户手动选择项目

### 默认回退策略

当无法确定上一个状态时：
1. 如果有可用项目 → 回到项目选择页
2. 如果用户是仓管员 → 回到身份选择页
3. 如果都没有 → 显示无项目可用页

## 用户体验改进

1. **明确的操作引导**: "返回上一步" 比 "重试" 更清楚
2. **避免重复错误**: 自动清除失败的项目缓存
3. **智能回退**: 根据上下文自动选择合适的回退目标
4. **保留用户信息**: 回退时不需要重新登录

## 测试场景

1. **场景1**: 自动选择项目失败
   - 预期：回到项目选择页，缓存已清除

2. **场景2**: 手动选择项目失败
   - 预期：回到项目选择页，可重新选择

3. **场景3**: 身份选择后网络错误
   - 预期：回到身份选择页

4. **场景4**: 仓管员切换项目参与方失败
   - 预期：回到身份选择页或项目选择页

## 注意事项

1. `_previousState` 仅在非 SessionError 状态时更新
2. 成功建立会话后会清除 `_previousState`
3. 回退后会清除 `_previousState` 防止重复使用
4. 项目缓存清除使用 `clearProjectData()` 方法
