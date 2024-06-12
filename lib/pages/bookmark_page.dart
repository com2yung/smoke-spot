import 'package:flutter/material.dart';
import 'package:smoke_spot_dev/pages/custom_bottom_navigation_bar.dart';
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
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1,),
    
      );
  }
}
