import 'place.dart';

class Bookmark {
  late Set<Place> bookmarks;

  Bookmark({Set<Place>? bookmarks}) : this.bookmarks = bookmarks ?? {};
  void addBookmark(Place place) {
    bookmarks.add(place);
  }

  void removeBookmark(Place place) {
    bookmarks.remove(place);
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
