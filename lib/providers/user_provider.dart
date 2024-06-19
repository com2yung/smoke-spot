import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smoke_spot_dev/pages/user.dart'; 
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 사용자가 로그인을 하면, 앱이 종료되어도 해당 상태를 유지하게 하는 패키지
import 'package:smoke_spot_dev/pages/review.dart';

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
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/user.json');

    // 사용자 데이터를 JSON으로 변환하여 파일에 저장
    String jsonUser = jsonEncode(_currentUser!.toJson());
    await file.writeAsString(jsonUser);
    print('User data saved to file.');

    // SharedPreferences에 사용자 데이터 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
    } else {
      await prefs.remove('currentUser');
    }
    print('User data saved to SharedPreferences.');
  } catch (e) {
    print("Error saving current user: $e");
  }
    /*try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('currentUser', json.encode(_currentUser!.toJson()));
      } else {
        await prefs.remove('currentUser');
      }
    } catch (e) {
      print("Error saving current user: $e");
    }*/
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
      await fetchReviewsForCurrentUser();
      await saveCurrentUser();
      print('User logged in: ${_currentUser!.toJson()}');
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

  Future<void> fetchReviewsForCurrentUser() async {
    try {
      if (_currentUser != null) {
        // 1. assets 폴더에서 users.json 파일을 로드합니다.
        String data = await rootBundle.loadString('assets/data/users.json');
        List<dynamic> jsonList = json.decode(data);

        // 2. 현재 로그인한 사용자의 이메일로 리뷰 데이터를 찾습니다.
        var userData = jsonList.firstWhere((userJson) => userJson['email'] == _currentUser!.email, orElse: () => null);
        if (userData != null) {
          // 3. 사용자 데이터에서 리뷰 데이터를 가져옵니다.
          List<dynamic> reviewsList = userData['reviews'];
          List<Review> reviews = reviewsList.map((reviewJson) => Review.fromJson(reviewJson)).toList();

          // 4. 현재 사용자 객체에 리뷰 데이터를 설정합니다.
          _currentUser!.reviews = reviews;

          // 5. 변경 사항을 저장하고 리스너에 알립니다.
          notifyListeners();
        } else {
          print('User not found in users.json');
        }
      }
    } catch (e) {
      print('Error fetching reviews for current user: $e');
    }
  }
// 리뷰 수정 메소드
  void editReview(Review originalReview, String editedText) {
    if (_currentUser != null) {
      // 해당 리뷰 찾기
      int index = _currentUser!.reviews.indexWhere((review) => review == originalReview);
      if (index != -1) {
        _currentUser!.reviews[index].text = editedText;
        _currentUser!.reviews[index].date = DateTime.now().toString(); // 수정된 날짜 설정 (선택적)
        saveCurrentUser(); // 사용자 데이터 저장 메소드 호출 (필요 시 구현)
        notifyListeners(); // 변경 사항을 리스너에 알림
      }
    }
  }

  // 리뷰 삭제 메소드
  void deleteReview(Review review) {
    if (_currentUser != null) {
      _currentUser!.reviews.remove(review);
      saveCurrentUser(); // 사용자 데이터 저장 메소드 호출 (필요 시 구현)
      notifyListeners(); // 변경 사항을 리스너에 알림
    }
  }

}
