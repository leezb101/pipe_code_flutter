/*
 * @Author: LeeZB
 * @Date: 2025-07-16 13:30:24
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 13:30:52
 * @copyright: Copyright © 2025 高新供水.
 */
class DownloadStreamResponse {
  final Stream<List<int>> stream;
  final int totalBytes;

  DownloadStreamResponse({required this.stream, required this.totalBytes});
}
