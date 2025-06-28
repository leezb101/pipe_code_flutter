import '../models/user/user.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  UserRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<User> getCurrentUser() async {
    final response = await _apiService.user.getUserProfile();
    return User.fromJson(response);
  }

  String? get currentUserId => _storageService.getUserId();
  String? get currentUsername => _storageService.getUsername();
}