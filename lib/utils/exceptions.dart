/*
 * @Author: LeeZB
 * @Date: 2025-07-30 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 16:00:00
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
