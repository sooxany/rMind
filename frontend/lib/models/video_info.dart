class VideoInfo {
  final String title;
  final String filePath;
  final bool isAnalyzed;
  final DateTime uploadedAt;

  VideoInfo({
    required this.title,
    required this.filePath,
    this.isAnalyzed = false,
    required this.uploadedAt,
  });
}
