import '../interfaces/api_service_interface.dart';
import '../interfaces/auth_api_service.dart';
import '../interfaces/user_api_service.dart';
import '../interfaces/list_api_service.dart';
import 'mock_auth_api_service.dart';
import 'mock_user_api_service.dart';
import 'mock_list_api_service.dart';

class MockApiService implements ApiServiceInterface {
  AuthApiService? _authService;
  UserApiService? _userService;
  ListApiService? _listService;

  @override
  AuthApiService get auth => _authService ??= MockAuthApiService();

  @override
  UserApiService get user => _userService ??= MockUserApiService();

  @override
  ListApiService get list => _listService ??= MockListApiService();
}