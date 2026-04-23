import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';

class BookmarksModel with ChangeNotifier {
  Userdata? userdata;
  List<Media> bookmarksList = [];

  BookmarksModel() {
    getBookmarks();
  }

  getBookmarks() async {
    bookmarksList = await SQLiteDbProvider.db.getAllMediaBookmarks();
    //bookmarksList.reversed.toList();
    notifyListeners();
    print(bookmarksList.length.toString());
  }

  bookmarkMedia(Media media) async {
    await SQLiteDbProvider.db.bookmarkMedia(media);
    getBookmarks();
  }

  unBookmarkMedia(Media media) async {
    await SQLiteDbProvider.db.deleteBookmarkedMedia(media.id);
    getBookmarks();
  }

  bool isMediaBookmarked(Media? media) {
    Media? itm = bookmarksList.firstWhereOrNull((itm) => itm.id == media!.id);
    return itm != null;
  }
}


