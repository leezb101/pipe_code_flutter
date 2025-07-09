import '../interfaces/list_api_service.dart';
import '../../../utils/mock_data_generator.dart';

class MockListApiService implements ListApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);

  @override
  Future<List<dynamic>> getListItems() async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to load items';
    }

    final items = MockDataGenerator.generateListItems(count: 15);
    return items.map((item) => item.toJson()).toList();
  }

  @override
  Future<Map<String, dynamic>> createListItem({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to create item';
    }

    final items = MockDataGenerator.generateListItems(count: 1);
    final item = items.first;
    return item.copyWith(
      title: title,
      description: description,
      imageUrl: imageUrl,
    ).toJson();
  }

  @override
  Future<Map<String, dynamic>> updateListItem({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to update item';
    }

    final items = MockDataGenerator.generateListItems(count: 1);
    final item = items.first;
    return item.copyWith(
      title: title ?? item.title,
      description: description ?? item.description,
      imageUrl: imageUrl ?? item.imageUrl,
      updatedAt: DateTime.now(),
    ).toJson();
  }

  @override
  Future<void> deleteListItem({required String id}) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      throw 'Failed to delete item';
    }
  }
}