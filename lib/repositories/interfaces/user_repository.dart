/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:57:49
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/models/user/wx_login_vo.dart';

abstract class UserRepository {
  Future<WxLoginVO?> loadUserFromStorage();
  Future<void> saveUserData(WxLoginVO wxLoginVO);
  Future<WxLoginVO?> updateUserProfile({
    String? name,
    String? nick,
    String? avatar,
    String? address,
    String? phone,
  });
  Future<void> clearUserData();
  String? getUserId();
  String? getUserName();
  String? getUserToken();
  void refreshCache();
}
