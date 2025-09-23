import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('문의하기'),
        content: Text('admin@gmail.com으로 문의하세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('확인', style: TextStyle(color: Color(0xffbf2142))),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('비밀번호 변경'),
        content: Text('아직 구현되지 않았습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('확인', style: TextStyle(color: Color(0xffbf2142))),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/');
    Provider.of<Auth>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<Auth>(context, listen: false).email;

    return Scaffold(
      appBar: AppBar(
        title: Text("마이페이지", style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: IconButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      width: 12.25,
                      color: Color(0xffbf2142),
                    ),
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.person, size: 70, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '현재 접속 계정: ${userEmail ?? "알 수 없음"}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      width: 1.25,
                      color: Color(0xffbf2142),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _showContactDialog,
                  child: const Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffbf2142),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      width: 1.25,
                      color: Color(0xffbf2142),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _showPasswordChangeDialog,
                  child: const Text(
                    '비밀번호 변경',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffbf2142),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      width: 1.25,
                      color: Color(0xffbf2142),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  onPressed: _logout,
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xffbf2142),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
