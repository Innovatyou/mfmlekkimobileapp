import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/models/Media.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchModel with ChangeNotifier {
  List<Media> _items = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  bool isError = false;
  bool isLoading = false;
  bool isIdle = true;
  String query = "";

  SearchModel();

  List<Media> get items {
    return _items;
  }

  void cancelSearch() {
    isError = false;
    isLoading = false;
    isIdle = true;
    notifyListeners();
  }

  void setSearchResult(List<Media> item) {
    _items = item;
    refreshController.refreshCompleted();
    isError = false;
    isLoading = false;
    notifyListeners();
  }

  void setMoreSearchResults(List<Media> item) {
    _items.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> searchArticles(String query) async {
    try {
      this.query = query;
      isIdle = false;
      isLoading = true;
      notifyListeners();
      final dio = await Utility.getAuthenticatedDio();
      final response = await dio.post(
        ApiUrl.SEARCH,
        data: jsonEncode({
          "data": {
            "offset": 0,
            "query": query,
          }
        }),
      );
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        String body = response.data is String ? response.data : jsonEncode(response.data);
        print(body);
        List<Media> articles = await compute(parseMedia, body);
        setSearchResult(articles);
      } else {
        setArticleFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setArticleFetchError();
    }
  }

  setArticleFetchError() {
    _items = [];
    refreshController.refreshFailed();
    isError = true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreSearch() async {
    try {
      final dio = await Utility.getAuthenticatedDio();
      final response = await dio.post(
        ApiUrl.SEARCH,
        data: jsonEncode({
          "data": {"query": query, "offset": items.length + 1}
        }),
      );
      if (response.statusCode == 200) {
        String body = response.data is String ? response.data : jsonEncode(response.data);
        List<Media> articles = await compute(parseMedia, body);
        setMoreSearchResults(articles);
      } else {
        refreshController.refreshFailed();
        notifyListeners();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      refreshController.loadFailed();
      notifyListeners();
    }
  }

  static List<Media> parseMedia(String responseBody) {
    final res = jsonDecode(responseBody);
    print(res);
    final parsed = res["search"].cast<Map<String, dynamic>>();
    return parsed.map<Media>((json) => Media.fromJson(json)).toList();
  }
}


