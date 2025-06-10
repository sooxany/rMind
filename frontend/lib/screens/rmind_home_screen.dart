import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/rmind_widgets.dart';
import '../widgets/app_drawer.dart';
import 'result_screen.dart';
import 'upload_video_screen.dart';
import 'notice_screen.dart';

class RMindHomeScreen extends StatefulWidget {
  @override
  _RMindHomeScreenState createState() => _RMindHomeScreenState();
}

class _RMindHomeScreenState extends State<RMindHomeScreen> {
  int selectedIndex = 0;

  List<String> videos = [
    "1. 삼성 기출 면접",
    "2. 취약 질문 모음.zip",
    "3. test",
  ];

  void _deleteVideo(int index) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("정말 삭제하시겠습니까?"),
          content: Text("\n'${videos[index]}' 영상을 삭제하면 복구할 수 없습니다."),
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
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/logo.png', width: 80, height: 80),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // 검색 기능 없음 (요구사항에 따라)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // 공지사항 버튼을 전체 너비로 확장
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 24),
              child: ElevatedButton.icon(
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
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
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
      bottomNavigationBar: RMindBottomNavBar(
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
