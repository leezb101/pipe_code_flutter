abstract class ListApiService {
  Future<List<dynamic>> getListItems();

  Future<Map<String, dynamic>> createListItem({
    required String title,
    required String description,
    String? imageUrl,
  });

  Future<Map<String, dynamic>> updateListItem({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
  });

  Future<void> deleteListItem({required String id});
}