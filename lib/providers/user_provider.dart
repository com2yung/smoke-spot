import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoke_spot_dev/pages/user.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 사용자가 로그인을 하면, 앱이 종료되어도 해당 상태를 유지하게 하는 패키지

class UserProvider with ChangeNotifier {
  List<User> _userList = []; // User 클래스로 리스트를 선언
  User? _currentUser; // 현재 로그인한 사용자를 저장하는 변수

  List<User> get userList => _userList;
  User? get currentUser => _currentUser; 

  UserProvider() {
    loadUserList();
    loadCurrentUser();
  }

  // 사용자가 입력한 데이터가 저장되는 경로 출력
  Future<void> printUserDataDirectoryPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      print('User data directory path: ${directory.path}');
    } catch (e) {
      print('Error printing user data directory path: $e');
    }
  }

  /*Future<void> copyUserDataToAssets() async {
  try {
    // assets/data/users.json 파일 경로
    final String assetFilePath = 'assets/data/users.json';

    // assets 폴더에서 읽기
    final byteData = await rootBundle.load(assetFilePath);
    final buffer = byteData.buffer.asUint8List();
    
    // 내부 저장소의 userdata.json 파일 경로
    final internalDirectory = await getApplicationDocumentsDirectory();
    final String internalFilePath = '${internalDirectory.path}/users.json';

    print('Copying user data from: $internalFilePath');
    print('Copying user data to: $assetFilePath');

    // 파일 쓰기
    final assetFile = File(internalFilePath);
    await assetFile.writeAsBytes(buffer);
    print('User data copied to: $assetFilePath');
  
  } catch (e) {
    print('Error copying user data to assets: $e');
  }
}*/

  Future<void> loadUserList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/userdata.json');
      
      if (await file.exists()) {
        String data = await file.readAsString();
        List<dynamic> jsonList = json.decode(data);
        _userList = jsonList.map((e) => User.fromJson(e)).toList(); // User 객체로 변환하여 저장
      } else {
        // 파일이 없으면 assets에서 초기 데이터 복사
        String data = await rootBundle.loadString('assets/data/users.json');
        List<dynamic> jsonList = json.decode(data);
        _userList = jsonList.map((e) => User.fromJson(e)).toList();
        await file.writeAsString(json.encode(jsonList));
      }

      notifyListeners();
    } catch (e) {
      print("Error loading user list: $e");
    }
  }

  // 현재 로그인한 사용자를 SharedPreferences에 저장
  Future<void> saveCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
      } else {
        await prefs.remove('currentUser');
      }
    } catch (e) {
      print("Error saving current user: $e");
    }
  }

  // SharedPreferences에서 로그인한 사용자 정보를 불러옴
  Future<void> loadCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userString = prefs.getString('currentUser');
      if (userString != null) {
        Map<String, dynamic> userData = json.decode(userString);
        _currentUser = User.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print("Error loading current user: $e");
    }
  }


  Future<void> saveUserList() async {
    try {
      List<dynamic> jsonList = _userList.map((e) => e.toJson()).toList(); // User 객체를 JSON으로 변환
      String jsonString = json.encode(jsonList);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/userdata.json');
      await file.writeAsString(jsonString);
      print('User list saved to ${file.path}');
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

  Future<void> saveUser(User newUser) async { 
    _userList.add(newUser);
    await saveUserList();
    print('User saved: ${newUser.toJson()}');
    await printUserDataDirectoryPath();
    //await copyUserDataToAssets();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
