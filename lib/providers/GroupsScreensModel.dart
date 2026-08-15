import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Groups.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/Utility.dart';
import 'dart:async';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/utils/ApiUrl.dart';

class GroupsScreensModel with ChangeNotifier {
  //List<Comments> _items = [];
  bool isError = false;
  List<Groups>? itemList = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String apiURL = "";
  int page = 0;

  GroupsScreensModel(String apiURL) {
    this.apiURL = apiURL;
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

  void setItems(List<Groups>? item) {
    itemList!.clear();
    itemList = item;
    refreshController.refreshCompleted();
    isError = false;
    notifyListeners();
  }

  void setMoreItems(List<Groups> item) {
    itemList!.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> fetchItems() async {
    Userdata? userdata = await SQLiteDbProvider.db.getUserData();
    try {
      final response = await Utility.getDio().post(
        apiURL,
        data: jsonEncode({
          "data": {
            "email": userdata == null ? "null" : userdata.email,
            "page": page.toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        List<Groups>? mediaList = parseSliderMedia(res);
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

  static List<Groups>? parseSliderMedia(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["groups"].cast<Map<String, dynamic>>();
    return parsed.map<Groups>((json) => Groups.fromJson(json)).toList();
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

  joingroup(BuildContext context, int groupid) async {
    Userdata? userdata = await SQLiteDbProvider.db.getUserData();
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      FormData formData = FormData.fromMap({
        "groupid": groupid,
        "email": userdata == null ? "null" : userdata.email,
      });
      var response =
          await Utility.getDio().post(ApiUrl.JOIN_GROUP, data: formData);
      Navigator.of(context).pop();
      print(response.data);
      Alerts.show(context, t.success, t.successjoinedgroup);
      loadItems();
    } on DioException catch (e) {
      Navigator.of(context).pop();
      Alerts.show(context, t.error, e.message);
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        //print(e.response.request);
      } else {
        //print(e.request.headers);
        print(e.message);
      }
    }
  }
}



