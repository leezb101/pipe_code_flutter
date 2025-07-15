/*
 * @Author: LeeZB
 * @Date: 2025-07-10 00:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 19:17:36
 * @copyright: Copyright © 2025 高新供水.
 */
import 'dart:math';
import '../models/user/wx_login_vo.dart';
import '../models/user/current_user_on_project_role_info.dart';
import '../models/project/project_info.dart';
import '../models/list_item/list_item.dart';
import '../models/user/user_role.dart';

class MockDataGenerator {
  static final Random _random = Random();

  static final List<String> _chineseNames = [
    '张三',
    '李四',
    '王五',
    '赵六',
    '孙七',
    '周八',
    '吴九',
    '郑十',
    '陈明',
    '刘华',
    '黄建',
    '林伟',
    '何强',
    '马军',
    '邓磊',
    '梁杰',
  ];

  static final List<String> _orgNames = [
    '高新供水有限公司',
    '市政建设监理公司',
    '水务工程建设集团',
    '城市管网建设公司',
    '水利工程施工队',
    '质量检测中心',
    '水务管理局',
    '供水设备制造商',
  ];

  static final List<String> _projectNames = [
    '智慧水务示例项目A',
    '智慧水务示例项目B',
    '智慧水务示例项目C',
    '城市供水管网改造工程',
    '水务信息化建设项目',
    '供水安全保障工程',
    '管网监测系统建设',
    '水质监控平台项目',
  ];

  static final List<UserRole> _roleTypes = [
    UserRole.suppliers,
    UserRole.construction,
    UserRole.supervisor,
    UserRole.builder,
    UserRole.check,
    UserRole.builderSub,
    UserRole.laborer,
    UserRole.playgoer,
  ];

  /// 生成模拟网络延迟
  static Future<void> simulateNetworkDelay({
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
  }

  /// 判断是否应该失败（基于失败率）
  static bool shouldFail({double failureRate = 0.1}) {
    return _random.nextDouble() < failureRate;
  }

  /// 生成随机中文姓名
  static String generateChineseName() {
    return _chineseNames[_random.nextInt(_chineseNames.length)];
  }

  /// 生成随机组织名称
  static String generateOrgName() {
    return _orgNames[_random.nextInt(_orgNames.length)];
  }

  /// 生成随机项目名称
  static String generateProjectName() {
    return _projectNames[_random.nextInt(_projectNames.length)];
  }

  /// 生成随机角色类型
  static UserRole generateRoleType() {
    return _roleTypes[_random.nextInt(_roleTypes.length)];
  }

  /// 生成随机手机号
  static String generatePhoneNumber() {
    final prefixes = ['138', '139', '150', '151', '152', '188', '189'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    final suffix = _random.nextInt(100000000).toString().padLeft(8, '0');
    return '$prefix$suffix';
  }

  /// 生成随机邮箱
  static String generateEmail(String name) {
    final domains = ['example.com', 'test.com', 'demo.com'];
    final domain = domains[_random.nextInt(domains.length)];
    return '${name.toLowerCase()}@$domain';
  }

  /// 生成随机头像URL
  static String generateAvatarUrl() {
    final avatarId = _random.nextInt(1000);
    return 'https://example.com/avatar_$avatarId.jpg';
  }

  /// 生成随机地址
  static String generateAddress() {
    final cities = ['北京市', '上海市', '广州市', '深圳市', '杭州市', '成都市'];
    final districts = ['朝阳区', '海淀区', '西城区', '东城区', '丰台区', '石景山区'];
    final city = cities[_random.nextInt(cities.length)];
    final district = districts[_random.nextInt(districts.length)];
    final street = '${_random.nextInt(999) + 1}号';
    return '$city$district测试街道$street';
  }

  /// 生成ProjectInfo列表
  static List<ProjectInfo> generateProjectInfos({int count = 3}) {
    return List.generate(count, (index) {
      return ProjectInfo(
        projectId: index + 1,
        projectRoleType: generateRoleType(),
        projectCode: 'WM${(index + 1).toString().padLeft(3, '0')}',
        projectName: generateProjectName(),
        orgCode: 'ORG${(index + 1).toString().padLeft(3, '0')}',
        orgName: generateOrgName(),
      );
    });
  }

  /// 生成WxLoginVO
  static WxLoginVO generateWxLoginVO({
    String? customName,
    String? customPhone,
    bool isPhoneLogin = false,
  }) {
    final now = DateTime.now();
    final name = customName ?? generateChineseName();
    final phone = customPhone ?? generatePhoneNumber();
    final projectInfos = generateProjectInfos();

    return WxLoginVO(
      id: 'user_${now.millisecondsSinceEpoch}',
      tk: 'token_${now.millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      unionid: 'union_${now.millisecondsSinceEpoch}',
      account: isPhoneLogin ? '' : 'test_${name}_${_random.nextInt(999)}',
      phone: phone,
      name: name,
      nick: '$name的昵称',
      birthday: '1990-0${_random.nextInt(9) + 1}-${_random.nextInt(28) + 1}',
      avatar: generateAvatarUrl(),
      address: generateAddress(),
      sex: _random.nextBool() ? '男' : '女',
      lastLoginTime: now.toIso8601String(),
      complete: true,
      orgCode: 'ORG001',
      orgName: generateOrgName(),
      own: true,
      boss: _random.nextInt(5) == 0, // 20% 概率是管理层
      admin: _random.nextInt(10) == 0, // 10% 概率是管理员
      projectInfos: projectInfos,
      currentProject: projectInfos.isNotEmpty ? projectInfos.first : null,
    );
  }

  /// 生成CurrentUserOnProjectRoleInfo
  static CurrentUserOnProjectRoleInfo generateCurrentUserOnProjectRoleInfo({
    int? projectId,
    UserRole? roleType,
    bool forceExpired = false,
  }) {
    final id = projectId ?? _random.nextInt(1000) + 1;
    final role = roleType ?? generateRoleType();

    // 模拟劳务人员过期场景
    final isExpired =
        forceExpired || (role == UserRole.laborer && _random.nextInt(4) == 0);

    return CurrentUserOnProjectRoleInfo(
      projectRoleType: role,
      currentProjectId: id,
      currentProjectCode: 'WM${id.toString().padLeft(3, '0')}',
      currentProjectName: generateProjectName(),
      currentOrgCode: 'ORG${(id % 5 + 1).toString().padLeft(3, '0')}',
      currentOrgName: generateOrgName(),
      currentProjectSuperiorUserId:
          (role == UserRole.builder || role == UserRole.builderSub)
          ? 12345
          : null,
      currentProjectAuthorUserId:
          (role == UserRole.builder || role == UserRole.builderSub)
          ? 67890
          : null,
      expire: isExpired,
    );
  }

  /// 生成ListItem数据
  static List<ListItem> generateListItems({int count = 10, String? category}) {
    return List.generate(count, (index) {
      return ListItem(
        id: 'item_${index + 1}',
        title: '列表项目 ${index + 1}',
        description: '这是第${index + 1}个列表项目的描述',
        imageUrl: 'https://example.com/icon_${index + 1}.png',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now(),
      );
    });
  }

  /// 生成认证响应（向后兼容）
  static Map<String, dynamic> generateAuthResponse({
    required String username,
    String? email,
  }) {
    final wxLoginVO = generateWxLoginVO(customName: username);
    return {'token': wxLoginVO.tk, 'user': wxLoginVO.toJson()};
  }

  /// 生成随机布尔值
  static bool generateRandomBool() {
    return _random.nextBool();
  }

  /// 生成随机整数
  static int generateRandomInt({int min = 0, int max = 100}) {
    return min + _random.nextInt(max - min + 1);
  }

  /// 生成随机字符串
  static String generateRandomString({int length = 8}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }
}
