import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/pages/custom_bottom_navigation_bar.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart';
import 'package:smoke_spot_dev/providers/bookmark_provider.dart';
import 'user_info_edit_page.dart';
import 'login_page.dart';
import 'place.dart';
import 'pages.dart';


// 마이페이지
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _buildUserInfoLabel = (String label, String value) {
    return Text(
      '$label $value',
      style: TextStyle(
        fontSize: 12,
        color: Colors.black87,
      ),
    );
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchReviews();
  }
   // Fetch reviews for the current user
  Future<void> _fetchReviews() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchReviewsForCurrentUser();
    setState(() {}); // Update the UI after fetching reviews
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final currentUser = userProvider.currentUser;
                        final reviews = currentUser?.reviews;

                        if (currentUser == null) {
                          return Center(
                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('아직 작성된 리뷰가 없습니다.'),
                                SizedBox(height: 8),
                              ],
                            ),
                          );
                        } else if (reviews == null || reviews.isEmpty) {
                          return Center(
                            child: Text('아직 작성된 리뷰가 없습니다.'),
                          );
                        } else {
                          return ListView.separated(
                            itemCount: reviews.length,
                            separatorBuilder: (BuildContext context, int index) => Divider(),
                            itemBuilder: (BuildContext context, int index) {
                              final review = reviews[index];
                              return ListTile(
                                title: Text('평점: ${review.score.toString()}'),
                                subtitle: Text(review.text),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(review.date),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showDialog(
                                          context: context, 
                                          builder: (BuildContext context) {
                                            String editedText = review.text;
                                            return AlertDialog(
                                              title: Text('리뷰 수정'),
                                              content: TextFormField(
                                                initialValue: review.text,
                                                onChanged: (value) {
                                                  editedText = value;
                                                },
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  }, 
                                                  child: Text('취소'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Provider.of<UserProvider>(context, listen: false).editReview(review, editedText);
                                                      Navigator.pop(context);
                                                    }, child: Text('저장'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context, 
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('리뷰 삭제'),
                                                content: Text('리뷰를 삭제하시겠습니까?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }, 
                                                    child: Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Provider.of<UserProvider>(context, listen: false).deleteReview(review);
                                                        Navigator.pop(context);
                                                      }, 
                                                      child: Text('삭제'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],


                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                    Consumer<BookmarkProvider>(
                      builder: (context, bookmarkProvider, child) {
                        return bookmarkProvider.bookmarks.isEmpty
                        ? Center(
                          child: Text('아직 저장된 흡연구역이 없습니다.'),
                        )
                        : ListView.separated(
                          itemCount: bookmarkProvider.bookmarks.length,
                          separatorBuilder: (BuildContext context, int index) => Divider(),
                          itemBuilder: (BuildContext context, int index) {
                            Place place = bookmarkProvider.bookmarks.elementAt(index);
                            return ListTile(
                              title: Text(place.name),
                              subtitle: Text(place.address),
                              trailing: IconButton(
                                icon: Icon(Icons.star), color: Colors.yellow,
                                onPressed: () {
                                  setState(() {
                                    bookmarkProvider.removeBookmark(place);
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
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