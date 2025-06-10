import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'result_screen.dart';

class UploadVideoPage extends StatelessWidget {
  const UploadVideoPage({super.key});

  Future<void> _pickVideo(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path!;
      // 동영상 선택 후 바로 ResultPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(videoPath: filePath),
        ),
      );
    } else {
      // 사용자가 취소했거나 아무것도 선택하지 않음
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동영상 선택이 취소되었습니다.")),
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
          onPressed: () {
            Navigator.pop(context); // 뒤로가기
          },
        ),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _pickVideo(context),
          icon: const Icon(Icons.video_file),
          label: const Text("업로드 동영상 선택"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
