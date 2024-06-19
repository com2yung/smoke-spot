import 'package:flutter/foundation.dart';
import 'package:smoke_spot_dev/pages/place.dart';

class BookmarkProvider extends ChangeNotifier {
  late Set<Place> bookmarks;

  BookmarkProvider({Set<Place>? bookmarks}) : this.bookmarks = bookmarks ?? {};

  void addBookmark(Place place) {
    bookmarks.add(place);
    notifyListeners(); // 변경 사항을 리스너들에게 알립니다.
  }

  void removeBookmark(Place place) {
    bookmarks.remove(place);
    notifyListeners(); // 변경 사항을 리스너들에게 알립니다.
  }

  bool isBookmarked(Place place) {
    return bookmarks.contains(place);
  }

  void toggleBookmark(Place place) {
    if (isBookmarked(place)) {
      removeBookmark(place);
    } else {
      addBookmark(place);
    }
  }
}
