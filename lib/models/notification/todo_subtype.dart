/// 待办子类型（由后端事件码1~6细分而来）
enum TodoSubtype {
  acceptConfirm, // 1 验收确认
  acceptAfterSignin, // 2 验收后入库
  outboundConfirm, // 3 出库确认
  outboundInstall, // 4 出库后安装
  transferConfirm, // 5 调拨确认
  transferAfterSignin, // 6 调拨后入库
  unknown,
}

extension TodoSubtypeX on TodoSubtype {
  String get displayName {
    switch (this) {
      case TodoSubtype.acceptConfirm:
        return '验收确认';
      case TodoSubtype.acceptAfterSignin:
        return '验收后入库';
      case TodoSubtype.outboundConfirm:
        return '出库确认';
      case TodoSubtype.outboundInstall:
        return '出库后安装';
      case TodoSubtype.transferConfirm:
        return '调拨确认';
      case TodoSubtype.transferAfterSignin:
        return '调拨后入库';
      case TodoSubtype.unknown:
        return '待办';
    }
  }
}

/// 从后端事件码推断子类型
TodoSubtype todoSubtypeFromCode(int code) {
  switch (code) {
    case 1:
      return TodoSubtype.acceptConfirm;
    case 2:
      return TodoSubtype.acceptAfterSignin;
    case 3:
      return TodoSubtype.outboundConfirm;
    case 4:
      return TodoSubtype.outboundInstall;
    case 5:
      return TodoSubtype.transferConfirm;
    case 6:
      return TodoSubtype.transferAfterSignin;
    default:
      return TodoSubtype.unknown;
  }
}
