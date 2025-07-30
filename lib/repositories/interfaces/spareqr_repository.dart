/*
 * @Author: LeeZB
 * @Date: 2025-07-16 10:30:21
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 14:05:12
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_state.dart';

abstract class SpareqrRepository {
  Stream<SpareQrState> downloadSpareqrZipFile(int num);
  Future<bool> deleteFile(String filePath);
}
