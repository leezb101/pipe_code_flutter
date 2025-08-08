/*
 * @Author: LeeZB
 * @Date: 2025-08-07 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-07 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:convert';
import 'package:pipe_code_flutter/models/notification/sse_message_vo.dart';
import 'package:pipe_code_flutter/models/notification/notification_message_vo.dart';
import 'package:pipe_code_flutter/services/notification/event_type_converter.dart';
import 'package:pipe_code_flutter/models/notification/todo_subtype.dart';

/// 消息解析结果
class MessageParseResult {
  final bool isSuccess;
  final NotificationMessageVO? message;
  final String? error;

  MessageParseResult.success(this.message) : isSuccess = true, error = null;

  MessageParseResult.failure(this.error) : isSuccess = false, message = null;

  bool get isFailure => !isSuccess;
}

/// 消息解析器接口
/// 定义了不同类型消息的解析策略
abstract class MessageParser {
  /// 解析SSE消息
  MessageParseResult parse(SseMessageVO sseMessage);

  /// 检查是否支持该消息类型
  bool supports(String eventType);
}

/// JSON消息解析器
/// 用于解析JSON格式的通知消息
class JsonMessageParser implements MessageParser {
  @override
  MessageParseResult parse(SseMessageVO sseMessage) {
    try {
      // 统一将类型转换为字符串以便解析器处理
      final eventType = EventTypeConverter.convert(
        sseMessage.type,
        hint: sseMessage.name,
      );

      if (!supports(eventType)) {
        return MessageParseResult.failure(
          'Unsupported event type: ${sseMessage.type}',
        );
      }

      // 解析JSON数据
      final Map<String, dynamic> jsonData = _parseJsonData(sseMessage.name);

      // 验证必需字段
      if (!_validateRequiredFields(jsonData)) {
        return MessageParseResult.failure(
          'Missing required fields in message data',
        );
      }

      // 构建通知消息对象
      final message = NotificationMessageVO.fromJson(jsonData);

      // 设置默认值
      final messageWithDefaults = message.copyWith(
        id: message.id.isNotEmpty ? message.id : sseMessage.msgId,
        createdAt: message.createdAt ?? DateTime.now(),
      );

      return MessageParseResult.success(messageWithDefaults);
    } catch (e) {
      return MessageParseResult.failure(
        'Failed to parse message: ${e.toString()}',
      );
    }
  }

  @override
  bool supports(String eventType) {
    // 支持的事件类型
    const supportedTypes = {
      'notification',
      'message',
      'alert',
      'system',
      'task',
      'reminder',
    };
    return supportedTypes.contains(eventType.toLowerCase());
  }

  /// 解析JSON数据
  Map<String, dynamic> _parseJsonData(String data) {
    if (data.trim().isEmpty) {
      throw const FormatException('Empty message data');
    }

    try {
      if (data.startsWith('{')) {
        return jsonDecode(data) as Map<String, dynamic>;
      } else {
        // 尝试解析为键值对格式
        return _parseKeyValueFormat(data);
      }
    } catch (e) {
      // 尝试解析为键值对格式
      return _parseKeyValueFormat(data);
    }
  }

  /// 解析键值对格式数据
  Map<String, dynamic> _parseKeyValueFormat(String data) {
    final result = <String, dynamic>{};
    final lines = data.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final parts = trimmedLine.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim();

        // 尝试解析值类型
        result[key] = _parseValue(value);
      }
    }

    return result;
  }

  /// 解析值类型
  dynamic _parseValue(String value) {
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }

    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;

    if (value.startsWith('[') && value.endsWith(']')) {
      return value
          .substring(1, value.length - 1)
          .split(',')
          .map((e) => e.trim())
          .toList();
    }

    if (int.tryParse(value) != null) {
      return int.parse(value);
    }

    if (double.tryParse(value) != null) {
      return double.parse(value);
    }

    return value;
  }

  /// 验证必需字段
  bool _validateRequiredFields(Map<String, dynamic> jsonData) {
    const requiredFields = ['type', 'title', 'content'];

    for (final field in requiredFields) {
      if (!jsonData.containsKey(field) || jsonData[field] == null) {
        return false;
      }
    }

    return true;
  }
}

/// 文本消息解析器
/// 用于解析简单文本格式的通知消息
class TextMessageParser implements MessageParser {
  @override
  MessageParseResult parse(SseMessageVO sseMessage) {
    try {
      final eventType = EventTypeConverter.convert(
        sseMessage.type,
        hint: sseMessage.name,
      );
      if (!supports(eventType)) {
        return MessageParseResult.failure(
          'Unsupported event type: ${sseMessage.type}',
        );
      }

      // 创建简单的通知消息
      final message = NotificationMessageVO(
        id: sseMessage.msgId,
        type: 'text',
        title: '系统通知',
        content: sseMessage.name,
        createdAt: DateTime.now(),
      );

      return MessageParseResult.success(message);
    } catch (e) {
      return MessageParseResult.failure(
        'Failed to parse text message: ${e.toString()}',
      );
    }
  }

  @override
  bool supports(String eventType) {
    const supportedTypes = {'text', 'log', 'debug', 'info'};
    return supportedTypes.contains(eventType.toLowerCase());
  }
}

/// 消息解析器工厂
/// 用于创建和管理不同的消息解析器
class MessageParserFactory {
  static final List<MessageParser> _parsers = [
    JsonMessageParser(),
    TextMessageParser(),
    TodoMessageParser(),
  ];

  /// 获取支持指定事件类型的解析器
  static MessageParser? getParser(String eventType) {
    for (final parser in _parsers) {
      if (parser.supports(eventType)) {
        return parser;
      }
    }
    return null;
  }

  /// 注册新的解析器
  static void registerParser(MessageParser parser) {
    if (!_parsers.contains(parser)) {
      _parsers.add(parser);
    }
  }

  /// 获取所有注册的解析器
  static List<MessageParser> get allParsers => List.unmodifiable(_parsers);
}

/// 待办消息解析器
/// 匹配事件类型：'todo'（由事件类型转换器将1~6的整型code映射而来）
class TodoMessageParser implements MessageParser {
  @override
  MessageParseResult parse(SseMessageVO sseMessage) {
    try {
      final eventType = EventTypeConverter.convert(
        sseMessage.type,
        hint: sseMessage.name,
      );
      if (!supports(eventType)) {
        return MessageParseResult.failure(
          'Unsupported event type for todo: ${sseMessage.type}',
        );
      }

      // 细分子类型（基于后端事件码 int）
      final subtype = todoSubtypeFromCode(sseMessage.type);

      // 从extra提取关键数据
      final extra = sseMessage.extra ?? const <String, dynamic>{};
      final name = _asString(extra['name']);
      final id = _asInt(extra['id']);
      final todoType = _asInt(extra['todoType']);
      final todoName = _asString(extra['todoName']);
      final businessId = _asInt(extra['businessId']);
      final projectId = _asInt(extra['projectId']);
      final projectName = _asString(extra['projectName']);
      final projectCode = _asString(extra['projectCode']);
      final finishStatus = _asInt(extra['finishStatus']);
      final launchUser = _asString(extra['launchUser']);
      final launchName = _asString(extra['launchName']);
      final title = _asString(extra['title']) ?? subtype.displayName;
      final content = _asString(extra['content']) ?? sseMessage.name;

      // 构造消息，metadata携带路由所需参数
      final message = NotificationMessageVO(
        id: sseMessage.msgId,
        type: 'todo',
        title: title.isNotEmpty ? title : '待办提醒',
        content: content.isNotEmpty ? content : '您有新的待办事项',
        createdAt: sseMessage.timestamp ?? DateTime.now(),
        metadata: {
          'todoSubtype': subtype.name,
          if (name != null) 'name': name,
          if (id != null) 'id': id,
          if (todoType != null) 'todoType': todoType,
          if (todoName != null) 'todoName': todoName,
          if (finishStatus != null) 'finishStatus': finishStatus,
          if (launchUser != null) 'launchUser': launchUser,
          if (launchName != null) 'launchName': launchName,
          if (businessId != null) 'businessId': businessId,
          if (projectId != null) 'projectId': projectId,
          if (projectName != null) 'projectName': projectName,
          if (projectCode != null) 'projectCode': projectCode,
        },
      );

      return MessageParseResult.success(message);
    } catch (e) {
      return MessageParseResult.failure(
        'Failed to parse todo message: ${e.toString()}',
      );
    }
  }

  @override
  bool supports(String eventType) => eventType.toLowerCase() == 'todo';

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String? _asString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
