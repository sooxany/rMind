import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'result_page.dart'; // 분석 결과 페이지

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
        fontFamily: 'SFProDisplay',
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

// ✅ Splash 화면
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
        child:
            Icon(CupertinoIcons.heart_fill, color: Colors.redAccent, size: 100),
      ),
    );
  }
}

// ✅ 홈 화면
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  List<String> videos = [
    "1. 삼성 기출 면접",
    "2. 취약 질문 모음.zip",
    "3. 엘지 면접 연습",
  ];

  Future<String?> uploadVideoAndGetImageUrl(File videoFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/upload_video'), // 서버 주소 변경 필요 시 여기 수정
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', videoFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);
      return result['image_url'];
    } else {
      return null;
    }
  }

  void _goToResultPage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      File video = File(result.files.single.path!);

      String? imageUrl = await uploadVideoAndGetImageUrl(video);

      if (imageUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(videoPath: imageUrl),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('분석 실패. 다시 시도해주세요.')),
        );
      }
    }
  }

  void _deleteVideo(int index) {
    setState(() {
      videos.removeAt(index);
    });
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
                onPressed: () {},
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
            Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 70),
            SizedBox(height: 6),
            Text("rMIND",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            SizedBox(height: 24),
            // 영상 카드
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
            // 사용방법 카드
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
                  Text("📘 rMIND 사용방법",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900])),
                  SizedBox(height: 14),
                  HoverBox(title: "1. 동영상 업로드 방법"),
                  HoverBox(title: "2. 결과 분석 확인 방법"),
                  HoverBox(title: "3. 추가 기능 사용법"),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToResultPage,
        backgroundColor: Colors.redAccent,
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

// ✅ HoverBox
class HoverBox extends StatefulWidget {
  final String title;
  const HoverBox({required this.title});

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
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _hovering ? Colors.red[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(widget.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ✅ HoverBottomNavBar
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
