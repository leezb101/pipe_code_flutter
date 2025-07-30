import 'package:pipe_code_flutter/models/list_item/list_item.dart';

abstract class ListRepository {
  Future<List<ListItem>> getItems();
}
