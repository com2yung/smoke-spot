import 'package:flutter/material.dart';
import 'package:mypage/user_info_edit_page.dart';
import 'package:mypage/Home_page.dart';
import 'login_page.dart';

// 마이페이지
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: 
          Column(
            children: [
              // 사용자 프로필 사진과 정보 섹션 
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, size: 40, color: Colors.white), // 사용자 아이콘으로 대체
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('사용자 이름', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('이메일 주소', style: TextStyle(color: Colors.black)),
                          Text('생년월일', style: TextStyle(color: Colors.black)),
                          Text('집 주소', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserInfoEditPage()),
                          );
                      },
                    ),
                  ],
                ),
              ),
              // 탭 바 섹션
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: '리뷰 관리'),
                  Tab(text: '내 장소 관리'),
                ],
              ),
              // 탭 바 뷰 섹션
              Container(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(child: Text('리뷰 관리 내용')),
                    Center(child: Text('내 장소 관리 내용')),
                  ],
                ),
              ),
              // 로그아웃 버튼 섹션
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                  },
                  child: Text('Log Out'),
                  ),
            ),
            ],
      ),
    ),
    // 바텀 네비게이션 바 섹션 
  bottomNavigationBar: BottomNavigationBar(
  backgroundColor: Colors.white,
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt),
      label: '부스 등록',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: '저장',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.forum),
      label: '커뮤니티',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '마이페이지',
    ),
  ],
  selectedItemColor: Colors.black26,
  unselectedItemColor: Colors.black,
  currentIndex: 4,
  type: BottomNavigationBarType.fixed,
  onTap: (int index) {
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  },
),

    );
  }
}