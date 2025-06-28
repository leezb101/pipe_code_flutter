import 'auth_api_service.dart';
import 'user_api_service.dart';
import 'list_api_service.dart';

abstract class ApiServiceInterface {
  AuthApiService get auth;
  UserApiService get user;
  ListApiService get list;
}