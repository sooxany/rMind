import 'package:flutter/material.dart';

// 추후: 여러 개 이미지 URL을 사용하고 싶다면 리스트로 바꾸기
class ResultPage extends StatelessWidget {
  final String videoPath; // plot 이미지 URL

  const ResultPage({required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("분석 결과"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침 로직 추가 가능 (현재는 대기)
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResultCard(title: "❤️ 심박수", imageUrl: videoPath),
              SizedBox(height: 20),
              ResultCard(title: "👁️ 시선 흔들림", imageUrl: videoPath),
              SizedBox(height: 20),
              ResultCard(title: "🕺 몸의 움직임", imageUrl: videoPath),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HoverBottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          // TODO: 필요 시 네비게이션 구현
        },
      ),
    );
  }
}

// ✅ 각 분석 결과를 보여주는 카드 위젯
class ResultCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ResultCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800])),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 160,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text('이미지를 불러올 수 없습니다'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ 하단 네비게이션 바 (main.dart와 동일)
class HoverBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const HoverBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<HoverBottomNavBar> createState() => _HoverBottomNavBarState();
}

class _HoverBottomNavBarState extends State<HoverBottomNavBar> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey[500],
      items: List.generate(3, (index) {
        final isHovered = hoveredIndex == index;
        final color = isHovered ? Colors.red : null;

        IconData icon;
        String label;

        switch (index) {
          case 0:
            icon = Icons.home;
            label = "Home";
            break;
          case 1:
            icon = Icons.list_alt;
            label = "List";
            break;
          case 2:
            icon = Icons.settings;
            label = "Settings";
            break;
          default:
            icon = Icons.circle;
            label = "";
        }

        return BottomNavigationBarItem(
          icon: MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = index),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: Icon(icon, color: color),
          ),
          label: label,
        );
      }),
    );
  }
}
