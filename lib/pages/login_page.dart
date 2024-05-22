import 'package:flutter/material.dart';
import 'sign_up_page.dart';
import 'Home_page.dart';

// 로그인 페이지 
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SmokingSpot',
                style: TextStyle(
                  fontSize:30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                ),
              SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  labelText: '이메일 주소',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Log In', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 15),
              ElevatedButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              }, 
              child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}