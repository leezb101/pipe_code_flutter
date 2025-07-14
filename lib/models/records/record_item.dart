import 'business_record.dart';
import 'project_record.dart';

abstract class RecordItem {
  int get id;
  String get projectName;
  String get projectCode;
  String get userName;
  String get doTime;
  String get businessTypeDescription;
}

class BusinessRecordItem implements RecordItem {
  final BusinessRecord _record;

  BusinessRecordItem(this._record);

  @override
  int get id => _record.id;

  @override
  String get projectName => _record.projectName;

  @override
  String get projectCode => _record.projectCode;

  @override
  String get userName => _record.userName;

  @override
  String get doTime => _record.doTime;

  @override
  String get businessTypeDescription => _record.businessTypeDescription;

  BusinessRecord get record => _record;
}

class ProjectRecordItem implements RecordItem {
  final ProjectRecord _record;

  ProjectRecordItem(this._record);

  @override
  int get id => _record.id;

  @override
  String get projectName => _record.projectName;

  @override
  String get projectCode => _record.projectCode;

  @override
  String get userName => _record.userName;

  @override
  String get doTime => _record.doTime;

  @override
  String get businessTypeDescription => _record.businessTypeDescription;

  ProjectRecord get record => _record;
}