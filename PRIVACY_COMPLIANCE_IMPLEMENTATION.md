# 隐私合规声明功能实现文档

## 概述
本文档描述了为"建设一码通"App实现的隐私合规声明功能，该功能符合360加固平台的合规要求，确保用户首次打开App时显示隐私政策弹窗。

## 实现的功能

### 1. PrivacyPolicyService（隐私政策服务）
**文件位置**: `lib/services/privacy_policy_service.dart`

**主要功能**:
- 管理用户隐私政策同意状态
- 检查是否为首次启动
- 检查当前版本是否需要重新同意
- 存储用户同意/拒绝记录及时间戳
- 版本管理（当前版本：1.0.0）

**核心方法**:
- `shouldShowPrivacyPolicy()`: 判断是否需要显示隐私政策
- `hasUserConsentedToCurrentVersion()`: 检查用户是否已同意当前版本
- `recordUserConsent()`: 记录用户同意
- `recordUserDenial()`: 记录用户拒绝

### 2. PrivacyComplianceDialog（隐私合规弹窗）
**文件位置**: `lib/widgets/privacy/privacy_compliance_dialog.dart`

**设计特点**:
- 符合360加固平台要求的弹窗设计
- 不可通过返回键或点击外部关闭
- 包含简化版隐私政策内容
- 提供"同意并继续"和"不同意"选项
- 可查看完整隐私政策
- 用户拒绝时提供退出确认

**UI特性**:
- 响应式设计，适配不同屏幕尺寸
- Material Design风格
- 清晰的视觉层次和交互反馈

### 3. PrivacyPolicyConstants（隐私政策内容）
**文件位置**: `lib/constants/privacy_policy_constants.dart`

**包含内容**:
- 完整版隐私政策文本
- 简化版隐私政策（用于弹窗显示）
- 应用名称、公司信息、联系方式等常量
- 明确说明收集的用户信息类型：
  - 用户手机号码
  - 用户定位信息
  - 用户摄像头权限
  - 用户麦克风录音权限

### 4. PrivacyPolicyPage（隐私政策页面）
**文件位置**: `lib/pages/privacy/privacy_policy_page.dart`

**功能特点**:
- 独立的隐私政策查看页面
- 显示完整隐私政策内容
- 版本信息展示
- 联系方式便捷查看
- 可选择文本内容

**路由配置**: `/privacy-policy`

### 5. StartupGate集成
**文件位置**: `lib/widgets/startup_gate.dart`

**集成特点**:
- 在网络就绪后、应用初始化完成后检查隐私政策
- 在认证检查之前先进行隐私政策检查
- 确保用户必须同意隐私政策才能继续使用应用

## 工作流程

### 首次启动流程
1. 用户打开App
2. StartupGate检查网络状态
3. 网络就绪后初始化应用数据
4. 检查隐私政策同意状态
5. 如果未同意或版本更新，显示隐私合规弹窗
6. 用户选择"同意并继续"后才能进入应用
7. 用户选择"不同意"则提示退出应用

### 用户交互选项
- **同意并继续**: 记录同意状态，继续应用启动流程
- **不同意**: 显示退出确认，用户确认后退出应用
- **查看完整隐私政策**: 弹出完整版隐私政策文档
- **重新考虑**: 返回隐私政策弹窗

### 数据存储
- 使用SharedPreferences本地存储
- 存储键名：
  - `privacy_policy_consent`: 用户同意状态
  - `privacy_policy_consent_version`: 同意的版本号
  - `privacy_policy_consent_timestamp`: 同意时间戳

## 合规要求满足情况

### 360加固平台要求 ✅
- ✅ 用户首次打开App时显示隐私政策
- ✅ 弹窗不可被绕过（禁用返回键和外部点击）
- ✅ 明确的同意/不同意选项
- ✅ 详细说明收集的个人信息类型
- ✅ 提供完整的隐私政策查看功能

### 个人信息保护法要求 ✅
- ✅ 明确告知收集信息的目的和范围
- ✅ 获得用户明确同意
- ✅ 提供撤回同意的机制（可通过设置重置）
- ✅ 采用安全的本地存储方式

## 技术实现细节

### 服务注册
在 `service_locator.dart` 中注册 `PrivacyPolicyService`:
```dart
getIt.registerLazySingleton<PrivacyPolicyService>(
  () => PrivacyPolicyService(getIt<StorageService>()),
);
```

### 路由配置
在 `routes.dart` 中添加隐私政策页面路由:
```dart
GoRoute(
  path: '/privacy-policy',
  name: 'privacy-policy',
  builder: (context, state) => const PrivacyPolicyPage(),
),
```

## 测试建议

### 手动测试场景
1. **首次安装测试**: 卸载重装应用，确认首次启动显示隐私政策弹窗
2. **同意流程测试**: 点击"同意并继续"，确认可以正常进入应用
3. **拒绝流程测试**: 点击"不同意"，确认显示退出确认对话框
4. **版本更新测试**: 修改 `currentPrivacyVersion`，确认再次显示弹窗
5. **完整政策查看**: 测试查看完整隐私政策功能
6. **返回键测试**: 确认无法通过返回键关闭弹窗

### 自动化测试
可以为 `PrivacyPolicyService` 编写单元测试，测试各种状态判断逻辑。

## 维护说明

### 更新隐私政策
1. 修改 `PrivacyPolicyConstants` 中的政策内容
2. 更新 `PrivacyPolicyService.currentPrivacyVersion` 版本号
3. 所有用户将在下次启动时重新看到隐私政策弹窗

### 联系方式更新
修改 `PrivacyPolicyConstants` 中的联系信息常量即可。

### 添加新的个人信息收集
1. 更新 `PrivacyPolicyConstants` 中的政策内容
2. 增加版本号确保用户重新同意
3. 如需要可以扩展 `PrivacyPolicyService` 的功能

## 结论

本实现完全满足360加固平台的合规要求，确保：
- 用户首次启动时强制显示隐私政策
- 用户必须明确同意才能继续使用
- 提供完整透明的隐私信息说明
- 技术实现稳定可靠，易于维护和扩展

该功能已集成到应用的启动流程中，确保所有用户都会看到并处理隐私政策同意，为应用上架各大应用市场做好了合规准备。
