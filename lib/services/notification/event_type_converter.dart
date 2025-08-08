/*
 * 事件类型转换器：将后端的int类型事件码转换为语义化的String类型事件名
 * 可扩展：支持按模块注册自定义映射策略；默认提供一套通用映射与回退策略。
 */
import 'package:pipe_code_flutter/utils/logger.dart';

/// 模块化事件映射接口
abstract class IntEventTypeMapper {
  /// 是否支持当前hint（模块线索）及code的处理
  bool supports(int code, {String? hint});

  /// 将事件码转换为事件名；返回null表示不处理，交由下一个映射器
  String? convert(int code, {String? hint});
}

/// 默认事件映射器：提供常见事件码到语义名的映射
class DefaultEventTypeMapper implements IntEventTypeMapper {
  const DefaultEventTypeMapper();

  static const Map<int, String> _map = {
    // 待办类：目前1~6统一归类为todo，后续可通过自定义映射器细化模块
    1: 'todo',
    2: 'todo',
    3: 'todo',
    4: 'todo',
    5: 'todo',
    6: 'todo',
    // 文本/日志类
    7: 'text',
    8: 'log',
    9: 'debug',
    10: 'info',
  };

  @override
  bool supports(int code, {String? hint}) => _map.containsKey(code);

  @override
  String? convert(int code, {String? hint}) => _map[code];
}

/// 事件类型转换器门面
class EventTypeConverter {
  EventTypeConverter._();

  static final List<IntEventTypeMapper> _mappers = [
    const DefaultEventTypeMapper(),
  ];

  /// 注册自定义映射器（按优先级追加，后注册的优先级更低）
  static void registerMapper(IntEventTypeMapper mapper) {
    if (!_mappers.contains(mapper)) {
      _mappers.add(mapper);
    }
  }

  /// 将后端事件类型转换为语义化字符串
  /// - 输入为int：按映射器转换；未知时按hint或占位符回退
  /// - 输入为String：直接归一化(lowercase trim)后返回
  /// - 其他/空：回退
  static String convert(dynamic raw, {String? hint}) {
    // 已经是字符串，做一次归一化
    if (raw is String) {
      final v = raw.trim();
      if (v.isNotEmpty) return v.toLowerCase();
    }

    // 数字事件码，走映射
    if (raw is int) {
      for (final mapper in _mappers) {
        if (mapper.supports(raw, hint: hint)) {
          final mapped = mapper.convert(raw, hint: hint);
          if (mapped != null && mapped.isNotEmpty) return mapped;
        }
      }
      // 未知码：尝试使用hint（通常是SSE的event名）作为回退
      if (hint != null && hint.trim().isNotEmpty) {
        return hint.trim().toLowerCase();
      }
      Logger.debug(
        'Unknown event type code: $raw, fallback to placeholder',
        tag: 'EventTypeConverter',
      );
      return 'unknown_$raw';
    }

    // 其他情况统一回退
    if (hint != null && hint.trim().isNotEmpty) {
      return hint.trim().toLowerCase();
    }
    return 'unknown';
  }
}
