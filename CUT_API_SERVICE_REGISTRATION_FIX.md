# 截管记录详情页 GetIt 注册问题修复

## 问题描述

在点击截管记录列表项进入详情页时，应用崩溃并报错：

```
Bad state: GetIt: Object/factory with type CutApiService is not registered inside GetIt. 
(Did you accidentally do GetIt sl=GetIt.instance(); instead of GetIt sl=GetIt.instance;
Did you forget to register it?)
```

## 问题原因

在重构 `PipeCuttingRecordPage` 时，我们创建了 `PipeCuttingRecordBloc`，它依赖 `CutApiService`：

```dart
getIt.registerFactory<PipeCuttingRecordBloc>(
  () => PipeCuttingRecordBloc(
    cutApiService: getIt<CutApiService>(),  // ❌ CutApiService 未注册
  ),
);
```

但是 `CutApiService` 并没有在 `service_locator.dart` 中注册。

### 之前的情况

`CutApiService` 之前只在 `RepositoryFactory` 中被动态创建：

```dart
// lib/repositories/repository_factory.dart
static MaterialDetailRepository createMaterialDetailRepository() {
  final cutApiService = ApiServiceFactory.createCutService();  // 动态创建
  final identificationApiService = ApiServiceFactory.createIdentificationService();
  return MaterialDetailRepositoryImpl(
    identificationApiService,
    cutApiService,
  );
}
```

这种方式下，每次创建 `MaterialDetailRepository` 时都会创建一个新的 `CutApiService` 实例，而不是通过 GetIt 的依赖注入。

## 解决方案

在 `service_locator.dart` 中注册 `CutApiService` 为 lazy singleton：

```dart
getIt.registerLazySingleton<CutApiService>(
  () => ApiServiceFactory.createCutService(),
);
```

### 注册位置

在 `service_locator.dart` 中，API 服务注册部分：

```dart
getIt.registerLazySingleton<ProfileApiService>(
  () => ApiServiceFactory.createProfileService(),
);
getIt.registerLazySingleton<CutRecordsApiService>(
  () => ApiServiceFactory.createCutRecordsService(),
);
getIt.registerLazySingleton<CutApiService>(  // ✅ 新增
  () => ApiServiceFactory.createCutService(),
);
```

## 技术说明

### 为什么使用 registerLazySingleton

1. **延迟初始化** - 只有在首次使用时才创建实例
2. **单例模式** - 整个应用生命周期中只有一个实例，避免重复创建
3. **统一管理** - 所有依赖通过 GetIt 统一管理，便于测试和维护

### CutApiService 的使用场景

现在 `CutApiService` 被以下组件使用：

1. **MaterialDetailRepository** - 通过 RepositoryFactory 创建时需要
2. **PipeCuttingRecordBloc** - 通过 GetIt 注入获取

### 相关服务对比

| 服务                   | 注册方式                  | 用途                       |
|------------------------|---------------------------|----------------------------|
| `CutRecordsApiService` | `registerLazySingleton`   | 获取截管记录列表和统计数据 |
| `CutApiService`        | `registerLazySingleton` ✅ | 获取截管树（历史记录）       |

这两个服务虽然都与"截管"相关，但提供的数据不同：
- `CutRecordsApiService` - 提供项目级别的截管记录列表
- `CutApiService` - 提供材料级别的截管树结构

## 修复后的依赖关系

```
PipeCuttingRecordBloc
  └── CutApiService (通过 GetIt 注入)
        └── ApiServiceFactory.createCutService()
              ├── CutApiServiceImpl (生产环境)
              └── MockCutApiService (Mock 模式)
```

## 验证

修复后，点击截管记录列表项应该能正常进入详情页，不再出现 GetIt 注册错误。

## 相关文件

- `lib/config/service_locator.dart` - 添加 CutApiService 注册
- `lib/bloc/pipe_cutting_record/pipe_cutting_record_bloc.dart` - 使用 CutApiService
- `lib/services/api_service_factory.dart` - 提供 createCutService 方法

## 经验教训

在使用依赖注入时，需要确保：
1. 所有被注入的服务都已在 service locator 中注册
2. 避免混用"工厂模式动态创建"和"依赖注入"两种方式
3. 保持服务注册的一致性，便于追踪和维护
