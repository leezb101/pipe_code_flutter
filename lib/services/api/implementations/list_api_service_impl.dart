import 'package:dio/dio.dart';
import '../interfaces/list_api_service.dart';
import 'base_api_service.dart';

class ListApiServiceImpl extends BaseApiService implements ListApiService {
  ListApiServiceImpl(super.dio);

  @override
  Future<List<dynamic>> getListItems() async {
    try {
      final response = await dio.get('/items');
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createListItem({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final response = await dio.post('/items', data: {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
      });
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateListItem({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final response = await dio.put('/items/$id', data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  @override
  Future<void> deleteListItem({required String id}) async {
    try {
      await dio.delete('/items/$id');
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}