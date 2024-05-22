import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 회원가입 폼의 상태를 관리하는 GlobalKey
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final TextEditingController _confirmPasswordController = TextEditingController(); // 비밀번호 확인 입력 컨트롤러
  bool _isAgreed = false; // 개인정보 활용 동의 여부 변수
  bool _isAgreedError = false; // 개인정보 활용 동의 에러 상태를 나타내는 변수 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              onChanged: () {
                _formKey.currentState!.validate();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),

                  // 이름 입력칸
                  SizedBox(height: 25),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '이름',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),

                  // 이메일 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '이메일 주소',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ), // 이메일 유효성 여부 판단하는 코드 있어야 함, 패키지 오류나서 보류

                  // 비밀번호 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    controller: _passwordController, // 비밀번호 입력 컨트롤러 연결
                    decoration: InputDecoration(
                      labelText: '비밀번호(영문, 숫자, 특수문자를 포함한 8자리 이상)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      } // 비밀번호를 입력하지 않을 때 에러 메시지
                      else if (value.length < 8) {
                        return '비밀번호는 8자리 이상이어야 합니다.';
                      } // 비밀번호가 8자리 미만일 때 에러 메시지
                      else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~])').hasMatch(value)) {
                        return '비밀번호는 영문과 숫자, 특수문자 조합이어야 합니다.';
                      } // 비밀번호가 영문과 숫자 조합이 아닐 시 에러 메시지 
                      return null;
                    },
                  ),
                  // 비밀번호 확인 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    controller: _confirmPasswordController, // 비밀번호 확인 컨트롤러 연결
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호 확인을 입력해주세요.'; 
                      } // 비밀번호 확인을 입력하지 않을 시 에러 메시지
                      else if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.'; 
                      } // 비밀번호가 일치하지 않으면 에러 메시지
                      return null; // 입력이 올바르면 null 반환
                    },
                  ),
                  // 생년월일 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '생년월일(YYYYMMDD)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일 8자리를 입력해주세요.';
                      } // 생년월일을 입력하지 않으면 에러 메시지 
                      else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                        return '생년월일은 YYYYMMDD 형식으로 8자리입니다.';
                      } // 생년월일을 8자리 숫자로 적지 않았을 때 에러 메시지 
                
                      return null;
                    },
                  ),
                  // 개인정보 활용 동의 체크 칸
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        }, // 개인정보 활용 동의 체크 이벤트 처리
                      ),
                      Text('개인정보 활용에 동의합니다.'),
                    ],
                  ),
                  if (!_isAgreed && _isAgreedError) // 개인정보 활용에 동의하지 않은 경우 에러 메시지
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        '*개인정보 활용에 동의해주세요.',
                        style: TextStyle(color: Colors.red),
                        ),
                        ),

                  // Sign up 버튼
                  SizedBox(height: 11),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (!_isAgreed) {
                          setState(() {
                            _isAgreedError = true; // 개인정보 활용 동의 여부 확인
                            }); 
                          return;
                      }
                      // 폼이 유효하면 회원가입 처리 
                      Navigator.pop(context);
                    }
                  },
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
