import 'package:pipe_code_flutter/models/business/download_stream.dart';

abstract class SpareqrApiService {
  // 一个下载备用码zip文件的接口，返回的是个文件流，文件流类型未知，地址是/qr/down，包含一个query参数num，int类型，表示下载的zip包里二维码的数量
  Future<DownloadStreamResponse> downloadSpareqrZip(int num);
}
