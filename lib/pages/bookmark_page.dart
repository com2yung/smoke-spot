import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/pages/custom_bottom_navigation_bar.dart';
import 'package:smoke_spot_dev/providers/user_provider.dart';
import 'package:smoke_spot_dev/providers/bookmark_provider.dart';
import 'login_page.dart';
import 'pages.dart';
import 'place.dart';

class BookmarkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 사용자 로그인 상태 확인
        if (userProvider.currentUser != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('내 흡연구역 리스트'),
            ),
            body: Consumer<BookmarkProvider>(
              builder: (context, bookmarkProvider, child) {
                // 북마크 리스트가 비어 있는 경우
                if (bookmarkProvider.bookmarks.isEmpty) {
                  return Center(
                    child: Text('아직 저장된 흡연구역이 없습니다.'),
                  );
                }
                // 북마크 리스트가 있는 경우
                return ListView.separated(
                  itemCount: bookmarkProvider.bookmarks.length,
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    Place place = bookmarkProvider.bookmarks.elementAt(index);
                    return ListTile(
                      leading: place.image != null
                        ? Image.asset(
                          place.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                        : Icon(Icons.image, size: 50),
                      title: Text(place.name),
                      subtitle: Text(place.address),
                      trailing: IconButton(
                        icon: Icon(Icons.star), color: Colors.yellow,
                        onPressed: () {
                          bookmarkProvider.removeBookmark(place);
                        },
                      ),
                    );
                  },
                );
              },
            ),
            bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
          );
        } else {
          // 비로그인 상태에서는 로그인 페이지로 이동
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('내 흡연구역 리스트'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '로그인이 필요합니다.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
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
              ),
            ),
          );
        }
      },
    );
  }
}
