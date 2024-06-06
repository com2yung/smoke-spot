import 'package:flutter/material.dart';
import 'package:smoke_spot_dev/pages/pages.dart';
import 'place.dart';
import 'bookmark.dart';

class BookmarkPage extends StatefulWidget {
  final Bookmark? bookmark;

  const BookmarkPage({Key? key, this.bookmark}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('내 흡연구역 리스트'),
      ),
      body: widget.bookmark?.bookmarks.isEmpty ?? true
          ? Center(
              child: Text('아직 저장된 흡연구역이 없습니다.'),
            )
          : ListView.separated(
              itemCount: widget.bookmark!.bookmarks.length,
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(),
              itemBuilder: (BuildContext context, int index) {
                Place place = widget.bookmark!.bookmarks.elementAt(index);
                return ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: IconButton(
                    icon: Icon(Icons.star),
                    onPressed: () {
                      setState(() {
                        widget.bookmark!.removeBookmark(place);
                      });
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
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
            currentIndex: 1,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              switch (index) {
                case 0:
                  // 부스 등록 페이지로 이동
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                  break;
                case 3:
                  // community page
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
