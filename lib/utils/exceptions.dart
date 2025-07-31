/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 19:01:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// 通用业务逻辑异常基类
class BusinessException implements Exception {
  final String message;

  BusinessException(this.message);

  @override
  String toString() => 'BusinessException: $message';
}

/// 获取退库详情失败时抛出的异常
class GetReturnDetailException extends BusinessException {
  GetReturnDetailException(super.message);
}

/// 执行退库操作失败时抛出的异常
class DoReturnException extends BusinessException {
  DoReturnException(super.message);
}

/// 获取切割提示失败时抛出的异常
class GetCutTipsException extends BusinessException {
  GetCutTipsException(super.message);
}

/// 执行切割操作失败时抛出的异常
class DoCutException extends BusinessException {
  DoCutException(super.message);
}