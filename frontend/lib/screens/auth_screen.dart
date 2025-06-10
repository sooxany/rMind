import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { Signup, Login }

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode =
          _authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = '이미 사용 중인 이메일입니다.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = '유효하지 않은 이메일 형식입니다.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = '비밀번호가 너무 약합니다.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = '등록되지 않은 이메일입니다.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = '잘못된 비밀번호입니다.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      _showErrorDialog('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _authMode == AuthMode.Login ? Colors.white : Colors.grey[50],
      appBar: AppBar(
        backgroundColor:
            _authMode == AuthMode.Login ? Colors.white : Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _authMode == AuthMode.Signup
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _switchAuthMode,
              )
            : null,
        title: _authMode == AuthMode.Signup
            ? Text(
                '로그인 화면으로 돌아가기',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              )
            : null,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _authMode == AuthMode.Login
                          ? Colors.red[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 제목과 설명
                Text(
                  _authMode == AuthMode.Login ? 'rMIND 로그인' : 'rMIND 회원가입',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _authMode == AuthMode.Login
                        ? Colors.red[800]
                        : Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _authMode == AuthMode.Login
                      ? "긴장도부터 제스처까지, 비언어 완전 분석\nLet's face your interview!"
                      : "면접 준비의 새로운 시작\n지금 가입하고 AI 면접 분석을 경험해보세요",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                // 회원가입 화면에만 추가 안내
                if (_authMode == AuthMode.Signup) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[700], size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '안전한 계정 생성을 위해 정확한 정보를 입력해주세요.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일을 입력해주세요.',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[400]!, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[400]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _authMode == AuthMode.Login
                            ? Colors.red
                            : Colors.blue,
                        width: 2,
                      ),
                    ),
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return '올바른 이메일을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호를 입력해주세요.',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[400]!, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey[400]!, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _authMode == AuthMode.Login
                            ? Colors.red
                            : Colors.blue,
                        width: 2,
                      ),
                    ),
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return '비밀번호는 5자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),

                // 회원가입 시 비밀번호 확인 필드
                if (_authMode == AuthMode.Signup) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPwController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '비밀번호를 다시 입력해주세요.',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey[400]!, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey[400]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      prefixIcon:
                          Icon(Icons.lock_outline, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (_authMode == AuthMode.Signup &&
                          value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 30),

                // 로그인/회원가입 버튼
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _authMode == AuthMode.Login
                            ? const Color(0xffbf2142)
                            : Colors.blue[600],
                        surfaceTintColor: _authMode == AuthMode.Login
                            ? const Color(0xffbf2142)
                            : Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? '로그인' : '회원가입',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // 화면 전환 링크
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: _authMode == AuthMode.Login
                          ? '아직 회원이 아니신가요?\n'
                          : '이미 회원이신가요?\n',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              _authMode == AuthMode.Login ? '회원가입하기' : '로그인하기',
                          style: TextStyle(
                            color: _authMode == AuthMode.Login
                                ? const Color(0xffbf2142)
                                : Colors.blue[600],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _switchAuthMode,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
