# CutRecordsItemVO 时间字段格式化处理

## 修改概述
将 `CutRecordsItemVO` 模型中的 `cutTime` 字段从 `int?` 类型改为 `String?` 类型，并在反序列化时自动将13位时间戳转换为格式化的时间字符串 `YYYY-MM-DD HH:mm:ss`。

## 修改内容

### 1. 模型文件修改
**文件**: `lib/models/cut/cut_records_item_vo.dart`

#### 主要变更：

1. **导入 intl 包**：用于日期格式化
   ```dart
   import 'package:intl/intl.dart';
   ```

2. **cutTime 字段类型变更**：从 `int?` 改为 `String?`
   ```dart
   /// 截管时间，格式化为 YYYY-MM-DD HH:mm:ss
   @JsonKey(fromJson: _cutTimeFromJson, toJson: _cutTimeToJson)
   final String? cutTime;
   ```

3. **添加自定义转换方法**：

   **反序列化方法** (`_cutTimeFromJson`)：
   - 接收服务端返回的13位时间戳（int 或 String 类型）
   - 转换为 `DateTime` 对象
   - 格式化为 `yyyy-MM-dd HH:mm:ss` 字符串
   - 异常处理：转换失败返回 null

   ```dart
   static String? _cutTimeFromJson(dynamic timestamp) {
     if (timestamp == null) return null;
     
     try {
       int timeInMillis;
       if (timestamp is int) {
         timeInMillis = timestamp;
       } else if (timestamp is String) {
         timeInMillis = int.parse(timestamp);
       } else {
         return null;
       }
       
       final dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
       final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
       return formatter.format(dateTime);
     } catch (e) {
       return null;
     }
   }
   ```

   **序列化方法** (`_cutTimeToJson`)：
   - 接收格式化的时间字符串
   - 解析为 `DateTime` 对象
   - 转换回13位时间戳
   - 异常处理：转换失败返回 null

   ```dart
   static int? _cutTimeToJson(String? formattedTime) {
     if (formattedTime == null) return null;
     
     try {
       final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
       final dateTime = formatter.parse(formattedTime);
       return dateTime.millisecondsSinceEpoch;
     } catch (e) {
       return null;
     }
   }
   ```

### 2. 生成的序列化代码
**文件**: `lib/models/cut/cut_records_item_vo.g.dart`

更新了 `fromJson` 和 `toJson` 方法，使用自定义转换函数：

```dart
CutRecordsItemVO _$CutRecordsItemVOFromJson(Map<String, dynamic> json) =>
    CutRecordsItemVO(
      // ... 其他字段
      cutTime: CutRecordsItemVO._cutTimeFromJson(json['cutTime']),
    );

Map<String, dynamic> _$CutRecordsItemVOToJson(CutRecordsItemVO instance) =>
    <String, dynamic>{
      // ... 其他字段
      'cutTime': CutRecordsItemVO._cutTimeToJson(instance.cutTime),
    };
```

## 数据转换示例

### 服务端返回的 JSON
```json
{
  "projectId": 123,
  "name": "PE管",
  "cutTime": 1728633000000
}
```

### 转换后的模型对象
```dart
CutRecordsItemVO(
  projectId: 123,
  name: "PE管",
  cutTime: "2024-10-11 14:30:00"
)
```

### 序列化回 JSON
```json
{
  "projectId": 123,
  "name": "PE管",
  "cutTime": 1728633000000
}
```

## 使用方式

### UI 层直接使用
在 `CutRecordListItem` 组件中，可以直接使用已格式化的时间字符串：

```dart
if (record.cutTime != null) ...[
  Text('截管时间：${record.cutTime}'), // 直接显示 "2024-10-11 14:30:00"
]
```

无需在 UI 层进行额外的时间格式化处理。

## 优势

1. **关注点分离**：时间格式化逻辑集中在模型层，UI 层只负责展示
2. **类型安全**：cutTime 字段类型为 `String?`，避免在 UI 层进行类型转换
3. **易于维护**：如需修改时间格式，只需在模型层修改一处即可
4. **容错性强**：包含完善的异常处理，确保转换失败时返回 null
5. **双向转换**：支持 JSON 反序列化和序列化的完整流程

## 注意事项

1. **时间戳格式**：服务端必须返回13位毫秒级时间戳
2. **时区处理**：使用系统默认时区，如需特定时区需额外处理
3. **依赖要求**：需要 `intl` 包支持（`pubspec.yaml` 中已包含）

## 测试要点

1. 验证正常的13位时间戳能正确转换为格式化字符串
2. 验证 null 值的处理
3. 验证异常时间戳（如格式错误）的容错处理
4. 验证字符串类型的时间戳也能正确转换
5. 验证序列化时能正确转换回时间戳

## 相关文件

- 模型定义：`lib/models/cut/cut_records_item_vo.dart`
- 生成的序列化代码：`lib/models/cut/cut_records_item_vo.g.dart`
- UI 组件：`lib/widgets/cut_record_list_item.dart` （无需修改）

## 修改日期
2025年10月11日
