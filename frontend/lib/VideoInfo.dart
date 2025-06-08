class VideoInfo {
  final String title;
  final String filePath;
  final bool isAnalyzed;
  final DateTime uploadedAt; // ← 이 줄 추가

  VideoInfo({
    required this.title,
    required this.filePath,
    this.isAnalyzed = false,
    required this.uploadedAt, // ← 이 줄도 추가
  });
}
