import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  bool _isUploading = false; // 로딩 상태

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    // 동영상 선택
    if (result != null && result.files.isNotEmpty) {
      setState(() => _isUploading = true);
    } else {
      if (!mounted) return;
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isUploading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('업로드 중...'),
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
