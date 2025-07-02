import 'dart:math';
import '../models/user/user.dart';
import '../models/user/user_role.dart';
import '../models/user/user_project_role.dart';
import '../models/project/project.dart';
import '../models/list_item/list_item.dart';

class MockDataGenerator {
  static final Random _random = Random();

  static final List<String> _firstNames = [
    'John',
    'Jane',
    'Mike',
    'Sarah',
    'David',
    'Emma',
    'Chris',
    'Lisa',
    'Tom',
    'Anna',
    'James',
    'Maria',
    'Robert',
    'Linda',
    'Michael',
    'Patricia',
  ];

  static final List<String> _lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
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
    'Cross-Platform Development',
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
    'Build once, run everywhere with cross-platform solutions.',
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
        Duration(hours: _random.nextInt(24), minutes: _random.nextInt(60)),
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

  static Future<void> simulateNetworkDelay({Duration? delay}) async {
    final actualDelay =
        delay ??
        Duration(
          milliseconds: 500 + _random.nextInt(1500), // 0.5 - 2 seconds
        );
    await Future.delayed(actualDelay);
  }

  static bool shouldFail({double failureRate = 0.1}) {
    return _random.nextDouble() < failureRate;
  }

  // 新增的项目和角色相关数据生成方法

  static final List<String> _projectNames = [
    '高新区主干道路管网改造项目',
    '科技园给水管网升级改造',
    '东区供水管网新建工程',
    '西区排水管网维修项目',
    '南区智能水表改造工程',
    '北区二次供水设施建设',
    '中心区管网漏损修复项目',
    '工业园区统管网建设',
  ];

  static final List<String> _projectDescriptions = [
    '本项目旨在改善区域内的供水质量和稳定性',
    '提升城市供水系统的整体效率和服务水平',
    '建设现代化的智能供水网络系统',
    '解决现有管网老化和漏损问题',
    '实现水资源的科学配置和高效利用',
    '保障居民安全、可靠的用水需求',
  ];

  static Project generateProject({String? id}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _random.nextInt(180)));
    final duration = 180 + _random.nextInt(365); // 6个月到2年
    final endDate = startDate.add(Duration(days: duration));

    return Project(
      id: id ?? _randomId(),
      name: _randomString(_projectNames),
      description: _randomString(_projectDescriptions),
      status:
          ProjectStatus.values[_random.nextInt(ProjectStatus.values.length)],
      location: '广州市高新区${_random.nextInt(100)}号',
      startDate: startDate,
      endDate: endDate,
      budget: 1000000.0 + _random.nextDouble() * 9000000.0, // 100万到1000万
      contactPerson:
          '${_randomString(_firstNames)}${_randomString(_lastNames)}',
      contactPhone: '138${_random.nextInt(90000000) + 10000000}',
      createdAt: now.subtract(Duration(days: _random.nextInt(365))),
      remarks: _random.nextBool() ? '重点项目，需要优先处理' : null,
    );
  }

  static List<Project> generateProjects({int count = 5}) {
    return List.generate(count, (index) => generateProject());
  }

  static Map<String, dynamic> generateUserProjectRoleJson({
    required String userId,
    required String projectId,
    Project? project,
    UserRole? role,
  }) {
    final now = DateTime.now();
    final assignedAt = now.subtract(Duration(days: _random.nextInt(180)));
    final selectedRole =
        role ?? UserRole.values[_random.nextInt(UserRole.values.length)];

    final userProjectRole = UserProjectRole(
      id: _randomId(),
      userId: userId,
      projectId: projectId,
      role: selectedRole,
      assignedAt: assignedAt,
      assignedBy: 'admin_${_random.nextInt(1000)}',
      validFrom: assignedAt,
      validUntil: _random.nextBool()
          ? null
          : assignedAt.add(Duration(days: 365)),
      isActive: true,
      project: project,
    );

    // 将对象转换为JSON，确保project字段也是Map格式
    final json = userProjectRole.toJson();
    if (project != null) {
      json['project'] = project.toJson();
    }
    return json;
  }

  static UserProjectRole generateUserProjectRole({
    required String userId,
    required String projectId,
    Project? project,
    UserRole? role,
  }) {
    final now = DateTime.now();
    final assignedAt = now.subtract(Duration(days: _random.nextInt(180)));
    final selectedRole =
        role ?? UserRole.values[_random.nextInt(UserRole.values.length)];

    return UserProjectRole(
      id: _randomId(),
      userId: userId,
      projectId: projectId,
      role: selectedRole,
      assignedAt: assignedAt,
      assignedBy: 'admin_${_random.nextInt(1000)}',
      validFrom: assignedAt,
      validUntil: _random.nextBool()
          ? null
          : assignedAt.add(Duration(days: 365)),
      isActive: true,
      project: project,
    );
  }

  static List<Map<String, dynamic>> generateUserProjectRolesJson(
    String userId, {
    int count = 3,
  }) {
    final projects = generateProjects(count: count);
    return projects
        .map(
          (project) => generateUserProjectRoleJson(
            userId: userId,
            projectId: project.id,
            project: project,
            role: UserRole.values[_random.nextInt(UserRole.values.length)],
          ),
        )
        .toList();
  }

  static List<UserProjectRole> generateUserProjectRoles(
    String userId, {
    int count = 3,
  }) {
    final projects = generateProjects(count: count);
    return projects
        .map(
          (project) => generateUserProjectRole(
            userId: userId,
            projectId: project.id,
            project: project,
            role: UserRole.values[_random.nextInt(UserRole.values.length)],
          ),
        )
        .toList();
  }

  static UserProjectContext generateUserProjectContext(String userId) {
    final user = generateUser(id: userId);
    final projectRoles = generateUserProjectRoles(userId);
    final currentRole = projectRoles.first;
    final currentProject = currentRole.project!;

    return UserProjectContext(
      user: user,
      currentProject: currentProject,
      currentRole: currentRole,
      allProjectRoles: projectRoles,
    );
  }
}
