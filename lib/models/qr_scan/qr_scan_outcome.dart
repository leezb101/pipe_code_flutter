class QrScanProcessResult {
  const QrScanProcessResult({
    required this.success,
    this.errorMessage,
    this.data,
  });

  final bool success;
  final String? errorMessage;
  final List<dynamic>? data; // typically List<QrScanResult>
}
