import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  final List<String> notices = [
    "✅ rMIND v1.0 출시!",
    "📈 면접 분석 정확도가 15% 향상되었습니다.",
    "🔐 개인정보 보호정책이 업데이트되었습니다.",
    "🧠 AI 피드백에 감정 분석 기능이 추가되었습니다.",
    "💬 문의는 help@rmind.app 으로 부탁드립니다.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공지사항", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Text(
              notices[index],
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          );
        },
      ),
    );
  }
}
