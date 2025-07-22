import 'package:json_annotation/json_annotation.dart';

enum RecordType {
  @JsonValue('todo')
  todo,
  
  @JsonValue('signin')
  signin,
  
  @JsonValue('accept')
  accept,
  
  @JsonValue('signout')
  signout,
  
  @JsonValue('install')
  install,
  
  @JsonValue('return')
  returnWarehouse,
  
  @JsonValue('dispatch')
  dispatch,
  
  @JsonValue('waste')
  waste,
  
  @JsonValue('inventory')
  inventory,
}

extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.todo:
        return '待办';
      case RecordType.signin:
        return '入库记录';
      case RecordType.accept:
        return '验收记录';
      case RecordType.signout:
        return '出库记录';
      case RecordType.install:
        return '安装记录';
      case RecordType.returnWarehouse:
        return '退库记录';
      case RecordType.dispatch:
        return '调拨记录';
      case RecordType.waste:
        return '报废记录';
      case RecordType.inventory:
        return '盘点记录';
    }
  }

  String get apiEndpoint {
    switch (this) {
      case RecordType.todo:
        return '/todo/list';
      case RecordType.signin:
        return '/signin/list';
      case RecordType.accept:
        return '/accept/list';
      case RecordType.signout:
        return '/signout/list';
      case RecordType.install:
        return '/install/list';
      case RecordType.returnWarehouse:
        return '/return/list';
      case RecordType.dispatch:
        return '/dispatch/list';
      case RecordType.waste:
        return '/waste/list';
      case RecordType.inventory:
        return '/inventory/list';
    }
  }

  bool get isMainTab {
    switch (this) {
      case RecordType.todo:
      case RecordType.signin:
      case RecordType.accept:
      case RecordType.signout:
      case RecordType.install:
        return true;
      default:
        return false;
    }
  }
}