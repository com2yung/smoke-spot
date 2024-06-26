import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/pages/login_page.dart';
import 'package:smoke_spot_dev/pages/user.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart';

// 회원가입 페이지

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // 회원가입 폼의 상태를 관리하는 GlobalKey
  final TextEditingController _nameController = TextEditingController(); // 이름 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 컨트롤러 
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final TextEditingController _confirmPasswordController = TextEditingController(); // 비밀번호 확인 입력 컨트롤러
  final TextEditingController _birthdateController = TextEditingController(); // 생년월일 입력 컨트롤러
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
                    controller: _nameController,
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: '이메일 주소',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ), 
                  // 비밀번호 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    controller: _passwordController, 
                    decoration: InputDecoration(
                      labelText: '비밀번호(영문, 숫자, 특수문자를 포함한 8자리 이상)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      } 
                      else if (value.length < 8) {
                        return '비밀번호는 8자리 이상이어야 합니다.';
                      } 
                      else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~])').hasMatch(value)) {
                        return '비밀번호는 영문과 숫자, 특수문자 조합이어야 합니다.';
                      } 
                      return null;
                    },
                  ),
                  // 비밀번호 확인 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    controller: _confirmPasswordController, 
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호 확인을 입력해주세요.'; 
                      } 
                      else if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.'; 
                      } 
                      return null; 
                    },
                  ),
                  // 생년월일 입력칸
                  SizedBox(height: 11),
                  TextFormField(
                    controller: _birthdateController,
                    decoration: InputDecoration(
                      labelText: '생년월일(YYYYMMDD)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일 8자리를 입력해주세요.';
                      }  
                      else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                        return '생년월일은 YYYYMMDD 형식으로 8자리입니다.';
                      }  
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
                        },
                      ),
                      Text('개인정보 활용에 동의합니다.'),
                    ],
                  ),
                  if (!_isAgreed && _isAgreedError) 
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!_isAgreed) {
                          setState(() {
                            _isAgreedError = true; 
                            }); 
                          return;
                      }
                      final user = User(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        confirmPassword: _confirmPasswordController.text,
                        birthdate: _birthdateController.text,
                        isAgreed: _isAgreed,
                      );       

                      try {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.saveUser(user);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("회원가입 성공"),
                              content: Text("회원가입에 성공했습니다"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));

                                  },
                                  child: Text("확인"),
                                ),
                              ],
                            );
                          },
                        );
                    } catch(e) {
                      // 데이터 저장 실패
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("오류"),
                            content: Text("failed to save data"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("confirm"),
                              ),
                            ],
                          );
                        },
                      );
                    }
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
