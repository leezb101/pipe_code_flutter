import 'package:pipe_code_flutter/services/location_service.dart';
import 'lib/config/service_locator.dart';

void main() async {
  // 设置服务定位器（模拟环境用于测试）
  await setupMockEnvironment();

  print('Starting location address test...');

  try {
    // 测试获取当前地址
    final address = await LocationService.getCurrentAddress();
    print('Current address: $address');
  } catch (e) {
    print('Error getting address: $e');
  }
}
