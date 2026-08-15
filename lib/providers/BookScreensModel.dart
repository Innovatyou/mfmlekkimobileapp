import 'package:flutter/foundation.dart';
import 'package:higherground/models/Books.dart';
import 'package:higherground/utils/Utility.dart';
import 'dart:async';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/utils/ApiUrl.dart';

class BookScreensModel with ChangeNotifier {
  //List<Comments> _items = [];
  bool isError = false;
  List<Books>? mediaList = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String apiURL = "";
  int page = 0;

  BookScreensModel() {
    this.mediaList = [];
  }

  loadItems() {
    refreshController.requestRefresh();
    page = 0;
    notifyListeners();
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Books>? item) {
    mediaList!.clear();
    mediaList = item;
    refreshController.refreshCompleted();
    isError = false;
    notifyListeners();
  }

  void setMoreItems(List<Books> item) {
    mediaList!.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> fetchItems() async {
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_BOOKS,
        data: jsonEncode({
          "data": {
            "page": page.toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        List<Books>? mediaList = parseSliderMedia(res);
        if (page == 0) {
          setItems(mediaList);
        } else {
          setMoreItems(mediaList!);
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setFetchError();
    }
  }

  static List<Books>? parseSliderMedia(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["books"].cast<Map<String, dynamic>>();
    return parsed.map<Books>((json) => Books.fromJson(json)).toList();
  }

  setFetchError() {
    if (page == 0) {
      isError = true;
      refreshController.refreshFailed();
      notifyListeners();
    } else {
      refreshController.loadFailed();
      notifyListeners();
    }
  }
}



