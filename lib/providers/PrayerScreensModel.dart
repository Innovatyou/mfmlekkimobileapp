import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/Utility.dart';
import 'dart:async';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/utils/ApiUrl.dart';

class PrayerScreensModel with ChangeNotifier {
  //List<Comments> _items = [];
  bool isError = false;
  List<Prayers>? itemList = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String apiURL = "";
  int page = 0;

  PrayerScreensModel() {
    this.itemList = [];
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

  void setItems(List<Prayers>? item) {
    itemList!.clear();
    itemList = item;
    refreshController.refreshCompleted();
    isError = false;
    notifyListeners();
  }

  void setMoreItems(List<Prayers> item) {
    itemList!.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> fetchItems() async {
    Userdata? user = await SQLiteDbProvider.db.getUserData();
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_PRAYERS,
        data: jsonEncode({
          "data": {
            "email": user == null ? "" : user.email,
            "page": page.toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        List<Prayers>? mediaList = parseSliderMedia(res);
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
      if (exception is DioError) {
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
      setFetchError();
    }
  }

  static List<Prayers>? parseSliderMedia(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["prayers"].cast<Map<String, dynamic>>();
    return parsed.map<Prayers>((json) => Prayers.fromJson(json)).toList();
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



