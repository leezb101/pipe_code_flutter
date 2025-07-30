import 'package:pipe_code_flutter/models/list_item/list_item.dart';
import 'package:pipe_code_flutter/services/api/interfaces/api_service_interface.dart';
import 'package:pipe_code_flutter/repositories/interfaces/list_repository.dart';

class ListRepositoryImpl implements ListRepository {
  final ApiServiceInterface _apiService;

  ListRepositoryImpl({required ApiServiceInterface apiService}) : _apiService = apiService;

  @override
  Future<List<ListItem>> getItems() async {
    final response = await _apiService.list.getListItems();
    return response.map((item) => ListItem.fromJson(item)).toList();
  }
}
