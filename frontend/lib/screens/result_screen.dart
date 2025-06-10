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
    String imagePath;
    if (title.contains('심박수')) {
      imagePath = 'assets/images/bpm_ex.png';
    } else if (title.contains('시선 흔들림')) {
      imagePath = 'assets/images/blink_ex.png';
    } else if (title.contains('몸의 움직임')) {
      imagePath = 'assets/images/motion_ex.png';
    } else {
      imagePath = 'assets/images/logo.png';
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
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool imageExists(String imageName) {
  // 추후 리스트 추가용
  return true;
}
