import '../models/user/user.dart';
import '../services/api/interfaces/api_service_interface.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiServiceInterface _apiService;
  final StorageService _storageService;

  UserRepository({
    required ApiServiceInterface apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  Future<User?> loadUserFromStorage() async {
    try {
      final userId = _storageService.getUserId();
      final username = _storageService.getUsername();
      final role = _storageService.getRole();
      if (userId == null || username == null || role == null) {
        return null;
      }

      final userDataString = _storageService.getString('user_data');
      if (userDataString != null) {
        final userData = Map<String, dynamic>.from(
          _storageService.decodeJsonString(userDataString),
        );
        return User.fromJson(userData);
      }

      return User(id: userId, username: username, email: '', role: role);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserToStorage(User user) async {
    await _storageService.saveUserId(user.id);
    await _storageService.saveUsername(user.username);
    await _storageService.setString(
      'user_data',
      _storageService.encodeJsonString(user.toJson()),
    );
  }

  Future<User> getCurrentUser() async {
    final response = await _apiService.user.getUserProfile();
    final user = User.fromJson(response);
    await saveUserToStorage(user);
    return user;
  }

  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
  }) async {
    final updateData = <String, dynamic>{};
    if (firstName != null) updateData['firstName'] = firstName;
    if (lastName != null) updateData['lastName'] = lastName;
    if (email != null) updateData['email'] = email;
    if (avatar != null) updateData['avatar'] = avatar;

    final response = await _apiService.user.updateUserProfile(data: updateData);
    final user = User.fromJson(response);
    await saveUserToStorage(user);
    return user;
  }

  Future<void> clearUserData() async {
    await _storageService.remove('user_data');
  }

  String? get currentUserId => _storageService.getUserId();
  String? get currentUsername => _storageService.getUsername();
}
