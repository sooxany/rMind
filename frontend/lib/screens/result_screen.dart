import 'package:flutter/material.dart';
import '../widgets/rmind_widgets.dart';

class ResultPage extends StatefulWidget {
  final String videoPath;
  ResultPage({required this.videoPath});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int selectedIndex = 1;

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    // 이미지 새로고침 - 현재는 특별한 동작 없음
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
              if (imageExists('${widget.videoPath}.png'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'assets/images/${widget.videoPath}.png',
                    fit: BoxFit.contain,
                  ),
                ),
              _buildResultCard("❤️ 심박수", Colors.redAccent),
              SizedBox(height: 20),
              _buildResultCard("👁 시선 흔들림", Colors.deepPurple),
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
          setState(() => selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildResultCard(String title, Color color) {
    // 제목에 따라 이미지 파일 결정
    String imagePath;
    if (title.contains('심박수')) {
      imagePath = 'assets/images/bpm_ex.png';
    } else if (title.contains('시선 흔들림')) {
      imagePath = 'assets/images/blink_ex.png';
    } else if (title.contains('몸의 움직임')) {
      imagePath = 'assets/images/motion_ex.png';
    } else {
      imagePath = 'assets/images/logo.png'; // 기본값
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            padding: EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain, // 비율 유지하면서 컨테이너에 맞춤
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool imageExists(String imageName) {
  // 실제 앱 빌드시 존재 여부는 따로 확인할 수 없으므로,
  // 일단 에셋 폴더에 있다고 가정하고 무조건 true 반환하거나,
  // 직접 존재 여부를 관리하는 List로 처리 가능
  return true; // 임시 처리
}
