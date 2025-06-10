import 'dart:convert'; // JSON 인코딩/디코딩을 위한 패키지
import 'dart:async'; // 비동기 처리를 위한 패키지

import 'package:flutter/widgets.dart'; // Flutter 위젯 패키지
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences를 위한 패키지

import '../models/http_exception.dart'; // HttpException 모델 import

class Auth with ChangeNotifier {
  // Auth 클래스 정의, ChangeNotifier를 사용하여 상태 변경 알림
  String? _token; // 인증 토큰 저장
  DateTime? _expiryDate; // 토큰 만료 날짜 저장
  String? _userId; // 사용자 ID 저장
  Timer? _authTimer; // 자동 로그아웃을 위한 타이머
  String? _email; // 사용자 이메일 저장

  bool get isAuth {
    // 사용자가 인증되었는지 여부를 반환하는 getter
    return token != null;
  }

  String? get token {
    // 유효한 토큰을 반환하는 getter
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    // 사용자 ID를 반환하는 getter
    return _userId;
  }

  String? get email {
    // 사용자 이메일을 반환하는 getter
    return _email;
  }

  Future<void> _authenticate(
      // 사용자 인증을 위한 내부 메소드
      String email,
      String password,
      String urlSegment) async {
    final url = Uri.parse(// Firebase 인증 URL 생성
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBJkoT8Z1l57iWokSbRBebqae2uAEQZA4g');
    try {
      final response = await http.post(
        // HTTP POST 요청을 통해 사용자 인증
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body); // 응답 데이터 디코딩
      if (responseData['error'] != null) {
        // 에러가 있는 경우 예외 발생
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken']; // 토큰 저장
      _userId = responseData['localId']; // 사용자 ID 저장
      _expiryDate = DateTime.now().add(
        // 토큰 만료 날짜 설정
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _email = responseData['email']; // 이메일 저장
      _autoLogout(); // 자동 로그아웃 설정
      notifyListeners(); // 리스너들에게 상태 변경 알림
      final prefs =
          await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 생성
      final userData = json.encode(
        // 사용자 데이터를 JSON으로 인코딩
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
          'email': _email,
        },
      );
      prefs.setString('userData', userData); // SharedPreferences에 사용자 데이터 저장
    } catch (error) {
      throw error; // 에러 발생 시 예외 던짐
    }
  }

  Future<void> signup(String email, String password) async {
    // 회원가입 메소드
    return _authenticate(email, password, 'signUp'); // 인증 메소드 호출
  }

  Future<void> login(String email, String password) async {
    // 로그인 메소드
    return _authenticate(email, password, 'signInWithPassword'); // 인증 메소드 호출
  }

  Future<bool> tryAutoLogin() async {
    // 자동 로그인을 시도하는 메소드
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 생성

    if (!prefs.containsKey('userData')) {
      // 사용자 데이터가 없으면 false 반환
      return false;
    }

    final userDataString = prefs.getString('userData'); // 사용자 데이터 가져오기
    if (userDataString == null) {
      // 데이터가 null이면 false 반환
      return false;
    }

    final extractedUserData = // JSON 데이터 디코딩
        json.decode(userDataString) as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String); // 만료 날짜 파싱

    if (expiryDate.isBefore(DateTime.now())) {
      // 만료된 경우 false 반환
      return false;
    }
    _token = extractedUserData['token'] as String; // 토큰 설정
    _userId = extractedUserData['userId'] as String; // 사용자 ID 설정
    _expiryDate = expiryDate; // 만료 날짜 설정
    _email = extractedUserData['email'] as String; // 이메일 설정
    notifyListeners(); // 리스너들에게 상태 변경 알림
    _autoLogout(); // 자동 로그아웃 설정
    return true;
  }

  Future<void> logout() async {
    // 로그아웃 메소드
    _token = null; // 토큰 삭제
    _userId = null; // 사용자 ID 삭제
    _expiryDate = null; // 만료 날짜 삭제
    _email = null; // 이메일 삭제
    if (_authTimer != null) {
      // 타이머가 설정되어 있으면 취소
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners(); // 리스너들에게 상태 변경 알림
    final prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 생성
    prefs.clear(); // SharedPreferences 데이터 삭제
  }

  void _autoLogout() {
    // 자동 로그아웃 메소드
    if (_authTimer != null) {
      // 타이머가 설정되어 있으면 취소
      _authTimer!.cancel();
    }
    final timeToExpiry =
        _expiryDate!.difference(DateTime.now()).inSeconds; // 남은 시간 계산
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout); // 타이머 설정
  }
}
