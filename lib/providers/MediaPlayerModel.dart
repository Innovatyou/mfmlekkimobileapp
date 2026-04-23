import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/models/Media.dart';

class MediaPlayerModel with ChangeNotifier {
  int? commentsCount = 0;
  int? likesCount = 0;
  bool? isLiked = false;
  Media? currentMedia;
  Userdata? userdata;

  MediaPlayerModel(Userdata? userdata, Media? media) {
    this.userdata = userdata;
    if (media != null) {
      setMediaLikesCommentsCount(media);
    }
  }

  setMediaLikesCommentsCount(Media media) {
    currentMedia = media;
    print("currentmedia = " + currentMedia!.id.toString());
    commentsCount = media.commentsCount;
    likesCount = media.likesCount;
    isLiked = media.userLiked == null ? false : media.userLiked;
    //notifyListeners();
    updateViewsCount();
    getMediaLikesCommentsCount();
  }

  Future<void> getMediaLikesCommentsCount() async {}

  Future<void> updateViewsCount() async {
    var data = {"media": currentMedia!.id};
    print(data.toString());
    try {
      final response = await http.post(
          Uri.parse(ApiUrl.update_media_total_views),
          body: jsonEncode({"data": data}));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.body);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  Future<void> likePost(String action) async {}

  navigatetoCommentsScreen(BuildContext context) async {
    
  }
}


