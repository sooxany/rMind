import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'result_page.dart';
import 'upload_video_page.dart';
import 'VideoInfo.dart';
import 'notice_page.dart';
import 'usage_detail_page.dart';

void main() {
  runApp(rMindApp());
}

class rMindApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rMIND',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'pretendard',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  List<String> videos = [
    "1. 삼성 기출 면접",
    "2. 취약 질문 모음.zip",
    "3",
  ];

  void _deleteVideo(int index) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("정말 삭제하시겠습니까?"),
          content: Text("\n'\${videos[index]}' 영상을 삭제하면 복구할 수 없습니다."),
          actions: [
            CupertinoDialogAction(
              child: Text("아니오", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text("예"),
              onPressed: () {
                setState(() {
                  videos.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoRow(int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            videos[index],
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          )),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResultPage(videoPath: videos[index]),
                    ),
                  );
                },
                child: Text("Play", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => _deleteVideo(index),
                child:
                    Text("Delete", style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('rMIND', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Image.asset('assets/images/logo.png', width: 70, height: 70),
            SizedBox(height: 6),
            Text("rMIND",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticePage()),
                );
              },
              icon: Icon(Icons.campaign),
              label: Text("공지사항 보기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200.withOpacity(0.25),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📺 last video feedback",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900])),
                  SizedBox(height: 14),
                  for (int i = 0; i < videos.length; i++) _buildVideoRow(i),
                ],
              ),
            ),
            SizedBox(height: 28),
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📘 rMIND 사용방법",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900])),
                  SizedBox(height: 16),
                  HoverBox(
                    title: "1. 동영상 업로드 방법",
                    detail: "홈화면 오른쪽 아래 + 버튼을 누르면 업로드 페이지로 이동합니다."
                        " 거기서 파일을 선택 후 분석을 시작할 수 있습니다.",
                  ),
                  SizedBox(height: 8),
                  HoverBox(
                    title: "2. 결과 분석 확인 방법",
                    detail: "업로드 완료 후 자동으로 분석 결과 화면으로 이동됩니다."
                        "그 화면에서 음성 및 표정 분석 결과를 확인할 수 있습니다.",
                  ),
                  SizedBox(height: 8),
                  HoverBox(
                    title: "3. 추가 기능 사용법",
                    detail: "설정 페이지에서 고급 분석 기능이나 AI 보조 기능을 켜고 끌 수 있습니다."
                        " 버전별 기능 차이를 확인하세요.",
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadVideoPage()),
          );
          if (result != null && result is String) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(videoPath: result),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: HoverBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HoverBox extends StatefulWidget {
  final String title;
  final String detail;

  const HoverBox({required this.title, required this.detail});

  @override
  _HoverBoxState createState() => _HoverBoxState();
}

class _HoverBoxState extends State<HoverBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsageDetailPage(
                title: widget.title,
                detail: widget.detail,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _hovering ? Colors.red[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.arrow_right_circle_fill,
                  color: Colors.red[300], size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
