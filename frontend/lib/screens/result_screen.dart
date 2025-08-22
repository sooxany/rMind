import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../widgets/rmind_widgets.dart';
import '../services/api_service.dart';
import 'my_page_screen.dart';

class ResultPage extends StatefulWidget {
  final String videoPath;
  final Map<String, dynamic>? analysisResult;

  ResultPage({required this.videoPath, this.analysisResult});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int selectedIndex = 1;
  Map<String, Uint8List?> _downloadedImages = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.analysisResult != null) {
      _downloadImages();
    }
  }

  Future<void> _downloadImages() async {
    if (widget.analysisResult == null) return;

    setState(() => _isLoading = true);

    final videoId = widget.analysisResult!['video_id'] as String;
    final imageTypes = ['bpm', 'blink', 'motion'];

    for (String imageType in imageTypes) {
      try {
        final imageData = await ApiService.downloadImage(videoId, imageType);
        if (imageData != null) {
          _downloadedImages[imageType] = imageData;
        }
      } catch (e) {
        print('Failed to download $imageType image: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleRefresh() async {
    if (widget.analysisResult != null) {
      await _downloadImages();
    } else {
      await Future.delayed(Duration(seconds: 1));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Result", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'rMind 분석 결과',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              SizedBox(height: 24),
              _buildResultCard("❤️ 심박수", Colors.redAccent),
              SizedBox(height: 20),
              _buildResultCard("👁 눈 깜빡임", Colors.deepPurple),
              SizedBox(height: 20),
              _buildResultCard("💃 몸의 움직임", Colors.teal[700]!),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RMindBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          if (index == 2) {
            // Settings 버튼 클릭 시 마이페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPageScreen()),
            );
          } else {
            setState(() => selectedIndex = index);
          }
        },
      ),
    );
  }

  Widget _buildResultCard(String title, Color color) {
    String imageType;
    String fallbackAssetPath;

    if (title.contains('심박수')) {
      imageType = 'bpm';
      fallbackAssetPath = 'assets/images/bpm_ex.png';
    } else if (title.contains('시선 흔들림')) {
      imageType = 'blink';
      fallbackAssetPath = 'assets/images/blink_ex.png';
    } else if (title.contains('몸의 움직임')) {
      imageType = 'motion';
      fallbackAssetPath = 'assets/images/motion_ex.png';
    } else {
      imageType = '';
      fallbackAssetPath = 'assets/images/logo.png';
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Spacer(),
              if (_isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageWidget(imageType, fallbackAssetPath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageType, String fallbackAssetPath) {
    // 서버에서 분석된 결과가 있고, 해당 이미지가 다운로드되었다면 서버 이미지 사용
    if (widget.analysisResult != null &&
        _downloadedImages.containsKey(imageType) &&
        _downloadedImages[imageType] != null) {
      return Image.memory(
        _downloadedImages[imageType]!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAssetPath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          );
        },
      );
    }

    // 기본 예시 이미지 사용
    return Image.asset(
      fallbackAssetPath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
    );
  }
}

bool imageExists(String imageName) {
  // 추후 리스트 추가용
  return true;
}
