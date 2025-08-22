import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // 로컬 서버 URL (개발용)
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// 영상 파일을 서버에 업로드하고 분석 결과를 받는다
  static Future<Map<String, dynamic>?> uploadVideo(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/upload_video');
      final request = http.MultipartRequest('POST', uri);

      // 파일 추가
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      // 요청 전송
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  /// 서버에서 이미지를 다운로드한다
  static Future<Uint8List?> downloadImage(
    String videoId,
    String imageType,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/download/$imageType/$videoId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  /// 서버 연결 상태를 확인한다
  static Future<bool> checkServerConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/docs');
      final response = await http.get(uri).timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
