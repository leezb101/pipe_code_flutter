# QR 扫码流程二次封装（Flow Service）

此文档描述新增的 QrScanFlowService 及配套模型，统一“初次 / 追加 / 移除”扫码模式。

## 核心组件
- enum QrScanOperation { initial, append, remove }
- QrScanFlowRequest / QrScanFlowResult
- QrScanFlowService.startScan -> 返回标准化结果
- QrScanConfig 提供 operation 字段（已彻底移除旧 isRemoveOperation）

## 迁移示例（已完成）
旧字段 isRemoveOperation 已移除，统一使用 operation。
示例：
```
final result = await flow.startScan(QrScanFlowRequest(
  operation: QrScanOperation.append,
  currentCodes: existingCodes,
  scanType: QrScanType.scrap,
  batch: true,
));
```
根据 result.operation 分支处理 addedCodes / removedCodes。

## Result 字段说明
| 字段         | initial/append                            | remove                           |
|--------------|-------------------------------------------|----------------------------------|
| addedCodes   | 新增的有效码                              | 空                               |
| removedCodes | 空                                        | 被识别为可移除的码               |
| duplicates   | 与 currentCodes 重复的（仅 initial/append） | 空                               |
| skipped      | 暂预留（如无效或 remove 时不在集合内）      | remove: 不在 currentCodes 内的码 |

当前状态：
- QrScanPage 已使用 operation 判定删除逻辑。
- isRemoveOperation 已移除。
- FlowService 通过 RepositoryProvider 注入。
- 后续可补充单元测试覆盖 append/remove。
