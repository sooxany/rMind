import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  bool _isUploading = false; // 로딩 상태
  String _uploadStatus = ''; // 업로드 상태 메시지

  Future<void> _pickVideo() async {
    // 먼저 서버 연결 상태 확인
    setState(() {
      _isUploading = true;
      _uploadStatus = '서버 연결 확인 중...';
    });

    bool isServerConnected = await ApiService.checkServerConnection();
    if (!isServerConnected) {
      setState(() {
        _isUploading = false;
        _uploadStatus = '';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _uploadStatus = '영상 선택 중...');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov', 'mkv'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path!;
      await _uploadVideo(filePath);
    } else {
      setState(() {
        _isUploading = false;
        _uploadStatus = '';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동영상 선택이 취소되었습니다.")),
      );
    }
  }

  Future<void> _uploadVideo(String filePath) async {
    setState(() => _uploadStatus = '영상 업로드 및 분석 중...');

    try {
      final result = await ApiService.uploadVideo(filePath);

      setState(() {
        _isUploading = false;
        _uploadStatus = '';
      });

      if (result != null && mounted) {
        // 분석 완료 - 결과 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              videoPath: filePath,
              analysisResult: result,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("분석에 실패했습니다. 다시 시도해주세요."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadStatus = '';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("오류가 발생했습니다: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isUploading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _uploadStatus.isEmpty ? '업로드 중...' : _uploadStatus,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '분석에는 시간이 걸릴 수 있습니다.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              )
            : ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_file),
                label: const Text("업로드 동영상 선택"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'result_screen.dart';
//
// class UploadVideoPage extends StatelessWidget {
//   const UploadVideoPage({super.key});
//
//   Future<void> _pickVideo(BuildContext context) async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['mp4'],
//     );
//
//     if (result != null && result.files.isNotEmpty) {
//       final filePath = result.files.first.path!;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ResultPage(videoPath: filePath),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("동영상 선택이 취소되었습니다.")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Video'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // 뒤로가기
//           },
//         ),
//       ),
//       body: Center(
//         child: ElevatedButton.icon(
//           onPressed: () => _pickVideo(context),
//           icon: const Icon(Icons.video_file),
//           label: const Text("업로드 동영상 선택"),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//         ),
//       ),
//     );
//   }
// }
