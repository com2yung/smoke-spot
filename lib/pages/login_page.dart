import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart'; 
import 'pages.dart';
import 'sign_up_page.dart';

// 로그인 페이지 
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
                child: Text(
                  'Smoking Spot',
                  style: TextStyle(
                    fontSize:30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일 주소',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  // 사용자가 입력한 이메일과 비밀번호 가져오기
                  String email = emailController.text;
                  String password = passwordController.text;

                  // 저장된 사용자 정보 가져오기
                  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                  bool loggedIn = await userProvider.loginUser(email, password);

                  // 저장된 사용자 정보와 입력한 정보 비교
                  if (loggedIn) {
                    // 일치하는 경우 홈 화면으로 이동
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                } else {
                  // 일치하지 않는 경우 경고 표시
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('경고'),
                          content: Text('잘못된 이메일 주소 또는 비밀번호입니다.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('확인'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('로그인', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 15),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              }, 
              child: Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}