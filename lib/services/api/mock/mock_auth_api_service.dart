/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 21:19:13
 * @copyright: Copyright © 2025 高新供水.
 */
import '../interfaces/auth_api_service.dart';
import '../../../models/common/result.dart';
import '../../../models/user/wx_login_vo.dart';
import '../../../models/user/current_user_on_project_role_info.dart';
import '../../../models/auth/login_account_vo.dart';
import '../../../models/auth/rf.dart';
import '../../../models/project/project_info.dart';
import '../../../utils/mock_data_generator.dart';

/// Mock认证API服务
/// 完全匹配API文档结构的模拟实现
class MockAuthApiService implements AuthApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);
  static String? _currentToken;

  @override
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest,
  ) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.2)) {
      return const Result(code: 400, msg: '账号或密码错误', tc: 800, data: null);
    }

    if (loginRequest.password.length < 3) {
      return const Result(code: 400, msg: '密码长度不能少于3位', tc: 800, data: null);
    }

    final mockLoginData = _generateMockWxLoginVO(loginRequest.account);
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '登录成功', tc: 800, data: mockLoginData);
  }

  @override
  Future<Result<WxLoginVO>> loginWithSms(String phone, String code) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.15)) {
      return const Result(code: 400, msg: '验证码错误', tc: 800, data: null);
    }

    if (code != '1234') {
      return const Result(code: 400, msg: '验证码不正确', tc: 800, data: null);
    }

    final mockLoginData = _generateMockWxLoginVO(phone, isPhoneLogin: true);
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '登录成功', tc: 600, data: mockLoginData);
  }

  @override
  Future<Result<void>> requestSmsCode(String phone) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 500),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '发送失败，请重试', tc: 500, data: null);
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      return const Result(code: 400, msg: '手机号格式不正确', tc: 500, data: null);
    }

    return const Result(code: 0, msg: '验证码发送成功', tc: 500, data: null);
  }

  @override
  Future<Result<WxLoginVO>> checkToken({String? tk}) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    final tokenToCheck = tk ?? _currentToken;
    if (tokenToCheck == null || tokenToCheck.isEmpty) {
      return const Result(code: 401, msg: 'Token无效', tc: 300, data: null);
    }

    final mockLoginData = _generateMockWxLoginVO('testuser');
    return Result(code: 0, msg: '成功', tc: 300, data: mockLoginData);
  }

  @override
  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 400),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 401, msg: '刷新Token失败', tc: 400, data: null);
    }

    final mockLoginData = _generateMockWxLoginVO('testuser');
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '刷新成功', tc: 400, data: mockLoginData);
  }

  @override
  Future<ResultBoolean> logout() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    _currentToken = null;

    return const ResultBoolean(code: 0, msg: '退出成功', tc: 300, data: true);
  }

  @override
  Future<ResultBoolean> logoff() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 500),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const ResultBoolean(code: 400, msg: '注销失败', tc: 500, data: false);
    }

    _currentToken = null;

    return const ResultBoolean(code: 0, msg: '注销成功', tc: 500, data: true);
  }

  @override
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(
    int projectId,
  ) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 600),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '项目选择失败', tc: 600, data: null);
    }

    final mockRoleInfo = _generateMockCurrentUserRoleInfo(projectId);

    return Result(code: 0, msg: '项目选择成功', tc: 600, data: mockRoleInfo);
  }

  @override
  void setAuthToken(String token) {
    _currentToken = token;
  }

  @override
  void clearAuthToken() {
    _currentToken = null;
  }

  /// 生成模拟的WxLoginVO数据
  WxLoginVO _generateMockWxLoginVO(
    String identifier, {
    bool isPhoneLogin = false,
  }) {
    final now = DateTime.now();
    final projectInfos = [
      const ProjectInfo(
        projectRoleType: 'construction',
        projectCode: 'WM001',
        projectName: '智慧水务示例项目A',
        orgCode: 'ORG001',
        orgName: '高新供水有限公司',
      ),
      const ProjectInfo(
        projectRoleType: 'supervisor',
        projectCode: 'WM002',
        projectName: '智慧水务示例项目B',
        orgCode: 'ORG002',
        orgName: '市政建设监理公司',
      ),
      const ProjectInfo(
        projectRoleType: 'laborer',
        projectCode: 'WM003',
        projectName: '智慧水务示例项目C',
        orgCode: 'ORG001',
        orgName: '高新供水有限公司',
      ),
    ];

    return WxLoginVO(
      id: 'user_${identifier.hashCode}',
      tk: 'token_${now.millisecondsSinceEpoch}_${identifier.hashCode}',
      unionid: 'union_${identifier.hashCode}',
      account: isPhoneLogin ? '' : identifier,
      phone: isPhoneLogin ? identifier : '13800138000',
      name: '测试用户_$identifier',
      nick: '昵称_$identifier',
      birthday: '1990-01-01',
      avatar: 'https://example.com/avatar_${identifier.hashCode}.jpg',
      address: '测试地址_${identifier.substring(0, 2)}',
      sex: identifier.hashCode % 2 == 0 ? '男' : '女',
      lastLoginTime: now.toIso8601String(),
      complete: true,
      orgCode: 'ORG001',
      orgName: '高新供水有限公司',
      own: true,
      boss: identifier.hashCode % 3 == 0,
      admin: identifier.hashCode % 5 == 0,
      projectInfos: projectInfos,
      currentProject: projectInfos.first,
    );
  }

  /// 生成模拟的当前用户项目角色信息
  CurrentUserOnProjectRoleInfo _generateMockCurrentUserRoleInfo(int projectId) {
    // 模拟不同项目的不同角色
    final roles = ['builder', 'supervisor', 'laborer', 'construction'];
    final selectedRole = roles[projectId % roles.length];

    // 模拟劳务人员过期场景
    final isExpired = selectedRole == 'laborer' && projectId % 4 == 0;

    return CurrentUserOnProjectRoleInfo(
      currentProjectRoleType: selectedRole,
      currentProjectId: projectId,
      currentProjectCode: 'WM${projectId.toString().padLeft(3, '0')}',
      currentProjectName: '智慧水务项目_$projectId',
      currentOrgCode: 'ORG${(projectId % 3 + 1).toString().padLeft(3, '0')}',
      currentOrgName: '组织机构_${projectId % 3 + 1}',
      currentProjectSuperiorUserId: selectedRole.contains('builder')
          ? 12345
          : null,
      currentProjectAuthorUserId: selectedRole.contains('builder')
          ? 67890
          : null,
      expire: isExpired,
    );
  }
}
