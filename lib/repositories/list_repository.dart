import '../models/list_item/list_item.dart';
import '../services/api/interfaces/api_service_interface.dart';

class ListRepository {
  final ApiServiceInterface _apiService;

  ListRepository({required ApiServiceInterface apiService}) : _apiService = apiService;

  Future<List<ListItem>> getItems() async {
    final response = await _apiService.list.getListItems();
    return response.map((item) => ListItem.fromJson(item)).toList();
  }
}