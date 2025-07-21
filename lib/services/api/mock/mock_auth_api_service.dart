/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 19:17:05
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/user/user_role.dart';

import '../interfaces/auth_api_service.dart';
import '../../../models/common/result.dart';
import '../../../models/user/wx_login_vo.dart';
import '../../../models/user/current_user_on_project_role_info.dart';
import '../../../models/auth/login_account_vo.dart';
import '../../../models/auth/rf.dart';
import '../../../models/auth/captcha_result.dart';
import '../../../models/auth/sms_code_result.dart';
import '../../../models/project/project_info.dart';
import '../../../utils/mock_data_generator.dart';

/// Mock认证API服务
/// 完全匹配API文档结构的模拟实现
class MockAuthApiService implements AuthApiService {
  static const Duration _defaultDelay = Duration(milliseconds: 800);
  static String? _currentToken;

  @override
  Future<Result<WxLoginVO>> loginWithPassword(
    LoginAccountVO loginRequest, {
    String? imgCode,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    // 模拟验证码验证失败
    if (loginRequest.code.isEmpty) {
      return const Result(code: 400, msg: '请输入验证码', data: null);
    }

    if (loginRequest.code.length < 4) {
      return const Result(code: 400, msg: '验证码长度不正确', data: null);
    }

    // 模拟imgCode验证（在mock环境中不严格要求）
    if (imgCode == null || imgCode.isEmpty) {
      // 在mock环境中只记录警告，不阻断流程
      print('Mock Warning: imgCode未提供，实际环境中可能导致验证失败');
    }

    if (MockDataGenerator.shouldFail(failureRate: 0.2)) {
      return const Result(code: 400, msg: '账号、密码或验证码错误', data: null);
    }

    // 检查密码是否为RSA加密格式（Base64编码，长度通常较长）
    final password = loginRequest.password;
    final isEncrypted =
        password.length > 100 &&
        RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(password);

    if (isEncrypted) {
      // RSA加密密码验证 - 在mock环境中简化验证逻辑
      print('Mock Info: 检测到RSA加密密码，长度: ${password.length}');
      // 在实际环境中，这里应该解密并验证密码
      // Mock环境中，只要是有效的Base64格式就认为通过
    } else {
      // 未加密的明文密码（用于向后兼容）
      if (password.length < 3) {
        return const Result(code: 400, msg: '密码长度不能少于3位', data: null);
      }
      print('Mock Warning: 检测到明文密码，建议使用RSA加密');
    }

    final mockLoginData = _generateMockWxLoginVO(loginRequest.account);
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '登录成功', data: mockLoginData);
  }

  @override
  Future<Result<WxLoginVO>> loginWithSms(
    String phone,
    String code, {
    String? smsCode,
  }) async {
    await MockDataGenerator.simulateNetworkDelay(delay: _defaultDelay);

    if (MockDataGenerator.shouldFail(failureRate: 0.15)) {
      return const Result(code: 400, msg: '验证码错误', data: null);
    }

    // 模拟smsCode验证（在mock环境中不严格要求）
    if (smsCode == null || smsCode.isEmpty) {
      // 在mock环境中只记录警告，不阻断流程
      print('Mock Warning: smsCode未提供，实际环境中可能导致验证失败');
    } else {
      print(
        'Mock Info: 检测到smsCode，标识符: ${smsCode.length > 8 ? '${smsCode.substring(0, 8)}...' : smsCode}',
      );
    }

    if (code != '1234') {
      return const Result(code: 400, msg: '验证码不正确', data: null);
    }

    final mockLoginData = _generateMockWxLoginVO(phone, isPhoneLogin: true);
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '登录成功', data: mockLoginData);
  }

  @override
  Future<Result<SmsCodeResult>> requestSmsCode(String phone) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 500),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '发送失败，请重试', data: null);
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      return const Result(code: 400, msg: '手机号格式不正确', data: null);
    }

    // 生成模拟的smsCode
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final mockSmsCode = 'MOCK_SMS_${timestamp % 10000}';

    final smsCodeResult = SmsCodeResult.create(
      phone: phone,
      smsCode: mockSmsCode,
      message: '验证码发送成功',
    );

    return Result(code: 0, msg: '验证码发送成功', data: smsCodeResult);
  }

  @override
  Future<Result<CaptchaResult>> requestCaptcha() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const Result(code: 500, msg: '验证码生成失败', data: null);
    }

    // 返回模拟的base64图片数据（一个简单的透明PNG的base64）
    const mockCaptchaBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';

    // 生成模拟的imgCode
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final mockImgCode = 'MOCK_IMG_${timestamp % 10000}';

    final captchaResult = CaptchaResult(
      base64Data: mockCaptchaBase64,
      imgCode: mockImgCode,
    );

    return Result(code: 0, msg: '验证码获取成功', data: captchaResult);
  }

  @override
  Future<Result<WxLoginVO>> checkToken({String? tk}) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    final tokenToCheck = tk ?? _currentToken;
    if (tokenToCheck == null || tokenToCheck.isEmpty) {
      return const Result(code: 401, msg: 'Token无效', data: null);
    }

    final mockLoginData = _generateMockWxLoginVO('testuser');
    return Result(code: 0, msg: '成功', data: mockLoginData);
  }

  @override
  Future<Result<WxLoginVO>> refreshToken(RF refreshRequest) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 400),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 401, msg: '刷新Token失败', data: null);
    }

    final mockLoginData = _generateMockWxLoginVO('testuser');
    _currentToken = mockLoginData.tk;

    return Result(code: 0, msg: '刷新成功', data: mockLoginData);
  }

  @override
  Future<ResultBoolean> logout() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 300),
    );

    _currentToken = null;

    return const ResultBoolean(code: 0, msg: '退出成功', data: true);
  }

  @override
  Future<ResultBoolean> logoff() async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 500),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.05)) {
      return const ResultBoolean(code: 400, msg: '注销失败', data: false);
    }

    _currentToken = null;

    return const ResultBoolean(code: 0, msg: '注销成功', data: true);
  }

  @override
  Future<Result<CurrentUserOnProjectRoleInfo>> selectProject(
    int projectId,
  ) async {
    await MockDataGenerator.simulateNetworkDelay(
      delay: Duration(milliseconds: 600),
    );

    if (MockDataGenerator.shouldFail(failureRate: 0.1)) {
      return const Result(code: 400, msg: '项目选择失败', data: null);
    }

    final mockRoleInfo = _generateMockCurrentUserRoleInfo(projectId);

    return Result(code: 0, msg: '项目选择成功', data: mockRoleInfo);
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
      ProjectInfo(
        projectId: 77,
        projectRoleType: UserRole.supervisor,
        projectCode: 'WM001',
        projectName: '智慧水务示例项目A',
        orgCode: 'ORG001',
        orgName: '高新供水有限公司',
        startTime: now.subtract(Duration(days: 30)),
        endTime: now.add(Duration(days: 365)),
      ),
      ProjectInfo(
        projectId: 88,
        projectRoleType: UserRole.builder,
        projectCode: 'WM002',
        projectName: '智慧水务示例项目B',
        orgCode: 'ORG002',
        orgName: '市政建设监理公司',
        startTime: now.subtract(Duration(days: 15)),
        endTime: now.add(Duration(days: 180)),
      ),
      ProjectInfo(
        projectId: 99,
        projectRoleType: UserRole.laborer,
        projectCode: 'WM003',
        projectName: '智慧水务示例项目C',
        orgCode: 'ORG001',
        orgName: '高新供水有限公司',
        startTime: now.subtract(Duration(days: 7)),
        endTime: now.add(Duration(days: 90)),
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
      storekeeper: identifier.hashCode % 7 == 0,
      projectInfos: projectInfos,
      currentProject: projectInfos.first,
    );
  }

  /// 生成模拟的当前用户项目角色信息
  CurrentUserOnProjectRoleInfo _generateMockCurrentUserRoleInfo(int projectId) {
    // 模拟不同项目的不同角色
    final roles = [
      UserRole.builder,
      UserRole.construction,
      UserRole.supervisor,
      UserRole.playgoer,
    ];
    final selectedRole = roles[projectId % roles.length];

    // 模拟劳务人员过期场景
    final isExpired = selectedRole == UserRole.laborer && projectId % 4 == 0;

    return CurrentUserOnProjectRoleInfo(
      // currentProjectRoleType: selectedRole,
      projectRoleType: selectedRole,
      currentProjectId: projectId,
      currentProjectCode: 'WM${projectId.toString().padLeft(3, '0')}',
      currentProjectName: '智慧水务项目_$projectId',
      currentOrgCode: 'ORG${(projectId % 3 + 1).toString().padLeft(3, '0')}',
      currentOrgName: '组织机构_${projectId % 3 + 1}',
      currentProjectSuperiorUserId: 12345,
      currentProjectAuthorUserId: 67890,
      expire: isExpired,
    );
  }
}
