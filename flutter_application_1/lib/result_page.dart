import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatefulWidget {
  final String videoPath;
  ResultPage({required this.videoPath});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int selectedIndex = 1;

  List<FlSpot> heartRateData = [
    FlSpot(0, 70),
    FlSpot(1, 75),
    FlSpot(2, 90),
    FlSpot(3, 85),
    FlSpot(4, 95),
    FlSpot(5, 80),
  ];

  List<FlSpot> eyeData = [
    FlSpot(0, 10),
    FlSpot(1, 30),
    FlSpot(2, 20),
    FlSpot(3, 25),
    FlSpot(4, 40),
    FlSpot(5, 15),
  ];

  List<FlSpot> bodyData = [
    FlSpot(0, 5),
    FlSpot(1, 10),
    FlSpot(2, 7),
    FlSpot(3, 13),
    FlSpot(4, 9),
    FlSpot(5, 6),
  ];

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      heartRateData = heartRateData.reversed.toList();
      eyeData = eyeData.reversed.toList();
      bodyData = bodyData.reversed.toList();
    });
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
              _buildResultCard("❤️ 심박수", Colors.redAccent, heartRateData),
              SizedBox(height: 20),
              _buildResultCard("👁 시선 흔들림", Colors.deepPurple, eyeData),
              SizedBox(height: 20),
              _buildResultCard("💃 몸의 움직임", Colors.teal[700]!, bodyData),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HoverBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() => selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildResultCard(String title, Color color, List<FlSpot> data) {
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
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: false,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Hover Bottom Navigation Bar
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
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
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

bool imageExists(String imageName) {
  // 실제 앱 빌드시 존재 여부는 따로 확인할 수 없으므로,
  // 일단 에셋 폴더에 있다고 가정하고 무조건 true 반환하거나,
  // 직접 존재 여부를 관리하는 List로 처리 가능
  return true; // 임시 처리
}
