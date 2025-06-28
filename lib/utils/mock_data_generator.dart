import 'dart:math';
import '../models/user/user.dart';
import '../models/list_item/list_item.dart';

class MockDataGenerator {
  static final Random _random = Random();

  static final List<String> _firstNames = [
    'John', 'Jane', 'Mike', 'Sarah', 'David', 'Emma', 'Chris', 'Lisa',
    'Tom', 'Anna', 'James', 'Maria', 'Robert', 'Linda', 'Michael', 'Patricia'
  ];

  static final List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
    'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez'
  ];

  static final List<String> _titles = [
    'Flutter Development Best Practices',
    'Building Scalable Mobile Apps',
    'State Management in Flutter',
    'Clean Architecture Principles',
    'API Integration Strategies',
    'User Experience Design',
    'Performance Optimization Tips',
    'Testing Flutter Applications',
    'Publishing to App Stores',
    'Cross-Platform Development'
  ];

  static final List<String> _descriptions = [
    'Learn the essential concepts and best practices for modern mobile development.',
    'Discover how to build applications that scale with your business needs.',
    'Master the art of managing application state effectively and efficiently.',
    'Implement clean architecture patterns for maintainable code.',
    'Integrate with external APIs and handle data synchronization.',
    'Create intuitive and engaging user interfaces that delight users.',
    'Optimize your application performance for better user experience.',
    'Write comprehensive tests to ensure code quality and reliability.',
    'Deploy your applications to app stores successfully.',
    'Build once, run everywhere with cross-platform solutions.'
  ];

  static String _randomString(List<String> options) {
    return options[_random.nextInt(options.length)];
  }

  static String _randomId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _random.nextInt(1000).toString();
  }

  static User generateUser({String? id}) {
    final firstName = _randomString(_firstNames);
    final lastName = _randomString(_lastNames);
    final username = '${firstName.toLowerCase()}_${lastName.toLowerCase()}';
    
    return User(
      id: id ?? _randomId(),
      username: username,
      email: '$username@example.com',
      firstName: firstName,
      lastName: lastName,
      avatar: null,
    );
  }

  static ListItem generateListItem({String? id}) {
    return ListItem(
      id: id ?? _randomId(),
      title: _randomString(_titles),
      description: _randomString(_descriptions),
      imageUrl: null,
      createdAt: DateTime.now().subtract(
        Duration(
          days: _random.nextInt(30),
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ),
      ),
      updatedAt: DateTime.now().subtract(
        Duration(
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        ),
      ),
    );
  }

  static List<ListItem> generateListItems(int count) {
    return List.generate(count, (index) => generateListItem());
  }

  static Map<String, dynamic> generateAuthResponse({
    required String username,
    String? email,
  }) {
    final user = User(
      id: _randomId(),
      username: username,
      email: email ?? '$username@example.com',
      firstName: _randomString(_firstNames),
      lastName: _randomString(_lastNames),
      avatar: null,
    );

    return {
      'token': 'mock_jwt_token_${_randomId()}',
      'user': user.toJson(),
      'expires_in': 3600,
    };
  }

  static Future<void> simulateNetworkDelay({
    Duration? delay,
  }) async {
    final actualDelay = delay ?? Duration(
      milliseconds: 500 + _random.nextInt(1500), // 0.5 - 2 seconds
    );
    await Future.delayed(actualDelay);
  }

  static bool shouldFail({double failureRate = 0.1}) {
    return _random.nextDouble() < failureRate;
  }
}