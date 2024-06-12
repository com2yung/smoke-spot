import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoke_spot_dev/pages/user.dart'; 
import 'package:path_provider/path_provider.dart';

class UserProvider with ChangeNotifier {
  List<User> _userList = []; // User 클래스로 리스트를 선언
  User? _currentUser; // 현재 로그인한 사용자를 저장하는 변수

  List<User> get userList => _userList;
  User? get currentUser => _currentUser; 

  UserProvider() {
    loadUserList();
  }

  Future<void> loadUserList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      
      if (await file.exists()) {
        String data = await file.readAsString();
        List<dynamic> jsonList = json.decode(data);
        _userList = jsonList.map((e) => User.fromJson(e)).toList(); // User 객체로 변환하여 저장
      } else {
        // 파일이 없으면 assets에서 복사
        String data = await rootBundle.loadString('assets/data/user.json');
        List<dynamic> jsonList = json.decode(data);
        _userList = jsonList.map((e) => User.fromJson(e)).toList();
        await file.writeAsString(json.encode(jsonList));
      }

      notifyListeners();
    } catch (e) {
      print("Error loading user list: $e");
    }
  }

  Future<void> saveUserList() async {
    try {
      List<dynamic> jsonList = _userList.map((e) => e.toJson()).toList(); // User 객체를 JSON으로 변환
      String jsonString = json.encode(jsonList);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user.json');
      await file.writeAsString(jsonString);
      notifyListeners();
    } catch(e) {
      print("Error saving user list: $e");
    }
  }

  Future<bool> loginUser(String email, String password) async {
   for (var user in _userList) {
    if (user.email == email && user.password == password) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
   }
   return false;
  }

  Future<void> saveUser(User newUser) async { // 사용자 정보를 User 클래스로 받음
    _userList.add(newUser);
    await saveUserList();
    print('User saved: ${newUser.toJson()}');
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
