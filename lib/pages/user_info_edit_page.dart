import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart';
import 'user.dart';
import 'dart:convert';
import 'dart:io';


class UserInfoEditPage extends StatefulWidget {
  @override
  _UserInfoEditPageState createState() => _UserInfoEditPageState();
}

class _UserInfoEditPageState extends State<UserInfoEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 각 입력 칸의 값이 변경될 때마다 _onFieldChanged 함수를 호출하여 수정 여부를 감지
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      // 수정 여부를 감지하여 상태를 갱신
      _formKey.currentState!.validate();
    });
  }

  Future<void> saveUserToFile(User user) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/User.json');
      final userJson = jsonEncode(user.toJson());
      await file.writeAsString(userJson);
    } catch(e) {
      print('Error saving user to file: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('회원정보 수정'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      currentUser?.name ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: '새로운 비밀번호(영문, 숫자, 특수문자를 포함한 8자리 이상)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_passwordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                        return '비밀번호를 입력해주세요.';
                      } else if (_passwordController.text.isNotEmpty && (value!.length < 8)) {
                          return '비밀번호는 8자리 이상이어야 합니다.';
                      } else if (_passwordController.text.isNotEmpty && !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$&*~])').hasMatch(value!)) {
                          return '비밀번호는 영문과 숫자, 특수문자 조합이어야 합니다.';
                      } else if (_passwordController.text.isNotEmpty && value != _confirmPasswordController.text) {
                          return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 11),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: '새로운 비밀번호 확인',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_confirmPasswordController.text.isNotEmpty && value!.isEmpty) {
                        return '비밀번호 확인을 입력해주세요.';
                      } else if (_confirmPasswordController.text.isNotEmpty && value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (currentUser != null) {
                          final updatedUser = User(
                            name: currentUser.name,
                            email: currentUser.email,
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            birthdate: currentUser.birthdate,
                            isAgreed: true,
                          );
                          userProvider.saveUser(updatedUser);
                          saveUserToFile(updatedUser);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text('수정 완료'),
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
