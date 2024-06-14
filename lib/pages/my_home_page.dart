import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/pages/custom_bottom_navigation_bar.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart';
import 'user_info_edit_page.dart';
import 'login_page.dart';
import 'pages.dart';


// 마이페이지
class MyHomePage extends StatefulWidget {
  final Bookmark? bookmark;
  const MyHomePage({Key? key, this.bookmark}) : super(key: key);

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
  final _buildUserInfoLabel = (String label, String value) {
    return Text(
      '$label $value',
      style: TextStyle(
        fontSize: 12,
        color: Colors.black87,
      ),
    );
  };

  void _navigateToLoginOrEditPage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserInfoEditPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
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
                          if (currentUser != null) ...[
                            _buildUserInfoLabel('이름: ', currentUser.name),
                            _buildUserInfoLabel('이메일 주소: ', currentUser.email),
                            _buildUserInfoLabel('생년월일: ', currentUser.birthdate),
                          ] else ...[
                            Text('로그인이 필요합니다.', style: TextStyle(fontSize: 16, color: Colors.black)),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              child: Text('로그인'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _navigateToLoginOrEditPage,
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
                  Tab(text: '내 흡연구역 관리'),
                ],
              ),
              // 탭 바 뷰 섹션
              Container(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(child: Text('리뷰 관리 내용')),
                    Center(child: Text('내 흡연구역 관리 내용')),
                  ],
                ),
              ),
              // 로그아웃 버튼 섹션
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    userProvider.logout();
                    Navigator.push(
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
  bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4,)
    );
  }
}