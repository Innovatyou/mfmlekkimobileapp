import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/models/Books.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/models/Items.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/HomePage.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/StringsUtils.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class DashboardModel with ChangeNotifier {
  var data = {
    "features": "",
    "app_login": true,
    "allow_downloads": false,
    "join_groups": true,
    "post_prayer": true,
    "post_testimony": true,
    "facebook": "",
    "twitter": "",
    "instagram": "",
    "youtube": "",
    "website": "",
    "donations_link": "",
  };

  bool isError = false;
  bool isLoading = true;
  List<Items> listone = [];
  List<Items> listtwo = [];
  List<Items> listthree = [];
  List<Items> listfour = [];
  List<Media> recentmedia = [];
  List<Articles> recentarticles = [];
  List<Books> recentbooks = [];
  List<Events> upcomingevents = [];
  List<Userdata> recentmembers = [];
  BuildContext? context;

  DashboardModel() {
    registerEvents();
  }

  registerEvents() {
    //logged in event
    eventBus.on<OnLanguageChange>().listen((event) {
      setListItems();
    });
  }

  setContext(BuildContext context) {
    this.context = context;
  }

  loadItems() {
    isError = false;
    isLoading = true;
    notifyListeners();
    fetchItems();
  }

  Future<void> fetchItems() async {
  try {
    print("[DashboardModel] Starting fetchItems...");
    
    Userdata? userdata = await SQLiteDbProvider.db.getUserData();
    print("[DashboardModel] User email: ${userdata?.email ?? 'not logged in'}");
    
    print("[DashboardModel] Making POST request to ${ApiUrl.INIT_APP}");
    
    final requestData = {
      "data": {"email": userdata == null ? "" : userdata.email}
    };
    print("[DashboardModel] Request payload: $requestData");
    
    // Try POST first, if it fails, fallback to GET
    Response response;
    try {
      response = await Utility.getDio().post(
        ApiUrl.INIT_APP,
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      );
    } catch (e) {
      print("[DashboardModel] POST request failed, trying GET as fallback...");
      print("[DashboardModel] POST Error: $e");
      final getUrl = "${ApiUrl.INIT_APP}?_p=${StringsUtils.API_TOKEN}";
      response = await Utility.getDio().get(
        getUrl,
        options: Options(responseType: ResponseType.plain),
      );
    }

    print("[DashboardModel] Response received - Status: ${response.statusCode}");
    print("[DashboardModel] Response data type: ${response.data.runtimeType}");
    print("[DashboardModel] Raw response: ${response.data}");

    if (response.statusCode == 200) {
      dynamic res;
      
      try {
        // Handle both String and Map responses
        if (response.data is String) {
          res = jsonDecode(response.data);
        } else {
          res = response.data;
        }
      } catch (parseError) {
        print("[DashboardModel] ERROR: Failed to parse response as JSON");
        print("[DashboardModel] Parse Error: $parseError");
        print("[DashboardModel] Raw response was: ${response.data}");
        print("[DashboardModel] DIAGNOSIS: Backend /initapp endpoint is not returning valid JSON");
        print("[DashboardModel] Using default configuration to proceed...");
        
        // Use a default configuration if backend is not properly implemented
        res = {
          "errors": false,
          "message": "Using default config",
          "settings": {
            "features": "hymns|notes|photos|radio|livestreams|prayer|testimony|books|articles|events|members",
            "app_login": "1",
            "allow_downloads": "1",
            "join_groups": "1",
            "post_prayer": "1",
            "post_testimony": "1",
            "facebook": "",
            "twitter": "",
            "instagram": "",
            "youtube": "",
            "website": "",
            "donations_link": ""
          }
        };
      }

      // -----------------------
      // ❗ CHECK FOR LOGIN ERROR
      // -----------------------
      if (res is Map && res["errors"] == true &&
          (res["message"]?.toString().toLowerCase() ?? "")
              .contains("no api token")) {
        print("[DashboardModel] API Token validation failed");
        Navigator.of(context!).pushReplacementNamed(AuthPage.routeName);
        return;
      }

      // -------------------------
      // ❗ CHECK settings is valid
      // -------------------------
      if (res is! Map || res["settings"] == null) {
        print("[DashboardModel] ERROR: Settings object is null in response");
        if (res is Map) {
          print("[DashboardModel] Response keys: ${res.keys.toList()}");
          print("[DashboardModel] Full response: $res");
        }
        setFetchError();
        return;
      }

      print("[DashboardModel] Settings found, parsing data...");

      isLoading = false;
      isError = false;

      var settings = res["settings"];

      data['features'] = settings['features'] ?? "";
      data['app_login'] = settings['app_login'] == "0";
      data['allow_downloads'] = settings['allow_downloads'] == "0";
      data['join_groups'] = settings['join_groups'] == "0";
      data['post_prayer'] = settings['post_prayer'] == "0";
      data['post_testimony'] = settings['post_testimony'] == "0";

      data['facebook'] = settings['facebook'] ?? "";
      data['twitter'] = settings['twitter'] ?? "";
      data['instagram'] = settings['instagram'] ?? "";
      data['youtube'] = settings['youtube'] ?? "";
      data['website'] = settings['website'] ?? "";
      data['donations_link'] = settings['donations_link'] ?? "";

      print("[DashboardModel] Features available: ${data['features']}");

      // Parse all lists safely
      recentmedia = settings.containsKey("latest_media")
          ? parseMedia(res)
          : [];
      recentarticles = settings.containsKey("latest_articles")
          ? parseArticles(res)
          : [];
      recentbooks = settings.containsKey("latest_books")
          ? parseBooks(res)
          : [];
      upcomingevents =
          settings.containsKey("upcoming_events") ? parseEvents(res) : [];
      recentmembers =
          settings.containsKey("members") ? parseMembers(res) : [];

      print("[DashboardModel] Data parsed successfully");
      print("[DashboardModel] Media: ${recentmedia.length}, Articles: ${recentarticles.length}, Books: ${recentbooks.length}");

      setListItems();
      notifyListeners();

      Userdata? u = await SQLiteDbProvider.db.getUserData();
      if (u == null && data['app_login'] == true) {
        print("[DashboardModel] Navigating to AuthPage (login required)");
        Navigator.of(context!).pushReplacementNamed(AuthPage.routeName);
      } else {
        print("[DashboardModel] Navigating to HomePage");
        Navigator.of(context!).pushReplacementNamed(HomePage.routeName);
      }
    } else {
      print("[DashboardModel] ERROR: HTTP Status ${response.statusCode}");
      setFetchError();
    }
  } on DioException catch (e) {
    print("[DashboardModel] ===== DioException Caught =====");
    print("[DashboardModel] Error type: ${e.type}");
    print("[DashboardModel] Message: ${e.message}");
    print("[DashboardModel] Response Status: ${e.response?.statusCode}");
    
    // Capture the full backend error response
    if (e.response != null) {
      print("[DashboardModel] Backend Response Body: ${e.response?.data}");
      print("[DashboardModel] Response Content-Type: ${e.response?.headers['content-type']}");
    }

    final String dioType = e.type.toString().toLowerCase();
    final String errorText = [
      e.message,
      e.error?.toString(),
      e.toString(),
    ].whereType<String>().join(' ').toLowerCase();

    if (errorText.contains('failed host lookup') ||
        errorText.contains('no address associated with hostname') ||
        errorText.contains('name or service not known')) {
      print("[DashboardModel] CAUSE: DNS lookup failed - hostname could not be resolved");
      print("[DashboardModel] CHECK: Does the device/emulator have working DNS and internet access?");
      print("[DashboardModel] CHECK: Host configured in ApiUrl.BASEURL = ${ApiUrl.BASEURL}");
    } else if (dioType.contains('connect') && !dioType.contains('connectionerror')) {
      print("[DashboardModel] CAUSE: Connection timeout - backend server took too long to respond");
      print("[DashboardModel] CHECK: Is the backend server accessible?");
    } else if (dioType.contains('receive')) {
      print("[DashboardModel] CAUSE: Receive timeout - response took too long");
    } else if (dioType.contains('send')) {
      print("[DashboardModel] CAUSE: Send timeout - took too long to send request");
    } else if (errorText.contains('certificate') || errorText.contains('ssl')) {
      print("[DashboardModel] CAUSE: SSL certificate validation failed");
      print("[DashboardModel] CHECK: Server certificate may be invalid, expired, or rejected by the device");
    } else if (dioType.contains('connectionerror') ||
        dioType.contains('other') ||
        dioType.contains('error') ||
        errorText.contains('socketexception')) {
      print("[DashboardModel] CAUSE: Network error or socket error");
      print("[DashboardModel] CHECK: Internet connection available?");
      if (e.error != null) {
        print("[DashboardModel] Inner error: ${e.error}");
        if (e.error.toString().contains("CERTIFICATE") || e.error.toString().contains("certificate")) {
          print("[DashboardModel] SSL Certificate validation error detected");
          print("[DashboardModel] SOLUTION: Server may have self-signed certificate or expired certificate");
        }
      }
    } else {
      print("[DashboardModel] CAUSE: Unclassified Dio network failure");
    }

    print("[DashboardModel] Full error: $e");
    setFetchError();
  } on Exception catch (e) {
    print("[DashboardModel] ===== Exception Caught =====");
    print("[DashboardModel] Exception: $e");
    print("[DashboardModel] Type: ${e.runtimeType}");
    
    // Check if it's SSL-related
    if (e.toString().contains("CERTIFICATE") || e.toString().contains("certificate") || e.toString().contains("SSL")) {
      print("[DashboardModel] SSL/Certificate error detected");
    }
    
    setFetchError();
  }
}

  setFetchError() {
    isError = true;
    isLoading = false;
    notifyListeners();
  }

  setListItems() {
    listone = [];
    listtwo = [];
    listthree = [];
    listfour = [];
    //list one

    /* if (isFeatureAvailable("devotionals")) {
      listone.add(Items(1,
          title: t.devotionals,
          photo: "devotionals.jpg",
          description: t.devotionals,
          icon: LineAwesomeIcons.television));
    }*/

    if (isFeatureAvailable("hymns")) {
      listone.add(Items(2,
          title: t.hymns,
          description: t.hymns,
          photo: "hymns.jpg",
          icon: FontAwesomeIcons.bookBible));
    }
    if (isFeatureAvailable("notes")) {
      listone.add(Items(3,
          title: t.notes,
          description: t.notes,
          photo: "notes.jpg",
          icon: FontAwesomeIcons.list));
    }

    //list three
    /*if (isFeatureAvailable("videomessages")) {
      listthree.add(Items(1,
          title: t.videos,
          description: t.videoshint,
          photo: "",
          icon: LineAwesomeIcons.video_1));
    }
    if (isFeatureAvailable("audiomessages")) {
      listthree.add(Items(2,
          title: t.audios,
          description: t.audioshint,
          photo: "",
          icon: LineAwesomeIcons.audio_file));
    }*/
    if (isFeatureAvailable("photos")) {
      listthree.add(Items(3,
          title: t.photos,
          description: t.photoshint,
          photo: "",
          icon: LineAwesomeIcons.photo_video));
    }
    if (isFeatureAvailable("radio")) {
      listthree.add(Items(4,
          title: t.radiostreams,
          description: t.radiohint,
          icon: FontAwesomeIcons.radio));
    }
    if (isFeatureAvailable("livestreams")) {
      listthree.add(Items(5,
          title: t.livestreams,
          description: t.livestreamshint,
          icon: LineAwesomeIcons.television));
    }
    if (isFeatureAvailable("media")) {
      listthree.add(Items(6,
          title: t.bookmarks,
          description: t.bookmarkshint,
          icon: LineAwesomeIcons.bookmark));
      listthree.add(Items(7,
          title: t.playlists,
          description: t.playlistshint,
          icon: LineAwesomeIcons.play));
      if (isDownloadsAllowed()) {
        listthree.add(Items(8,
            title: t.downloads,
            description: t.downloadershint,
            icon: LineAwesomeIcons.download));
      }
    }

    //list four
    /* if (isFeatureAvailable("groups")) {
      listfour.add(
        Items(
          1,
          title: t.groups,
          description: t.groupshint,
          icon: FontAwesomeIcons.peopleGroup,
        ),
      );
    }*/
    if (isFeatureAvailable("prayer")) {
      listfour.add(
        Items(
          2,
          title: t.Prayerrequests,
          description: t.prayerhint,
          icon: LineAwesomeIcons.praying_hands,
        ),
      );
    }
    if (isFeatureAvailable("testimony")) {
      listfour.add(
        Items(
          3,
          title: t.testimonies,
          description: t.testimonyhint,
          icon: LineAwesomeIcons.quote_left,
        ),
      );
    }
    /*listfour.add(
      Items(
        4,
        title: t.churchlocation,
        description: t.churchlocationhint,
        icon: LineAwesomeIcons.location_arrow,
      ),
    );*/

    if (data['facebook'] != "") {
      listfour.add(
        Items(
          5,
          title: t.facebookpage,
          description: t.facebookpagehint,
          icon: LineAwesomeIcons.facebook,
        ),
      );
    }
    if (data['twitter'] != "") {
      listfour.add(
        Items(
          6,
          title: t.twitterpage,
          description: t.twitterpagehint,
          icon: LineAwesomeIcons.twitter,
        ),
      );
    }
    if (data['instagram'] != "") {
      listfour.add(
        Items(
          7,
          title: t.instagrampage,
          description: t.instagrampagehint,
          icon: LineAwesomeIcons.instagram,
        ),
      );
    }
    if (data['youtube'] != "") {
      listfour.add(
        Items(
          8,
          title: t.youtubepage,
          description: t.youtubepagehint,
          icon: LineAwesomeIcons.youtube,
        ),
      );
    }
    notifyListeners();
  }

  bool isFeatureAvailable(String type) {
    final features = data['features'];
    if (features == null) return true;
    
    // Convert to String safely
    String featureStr = (features is String ? features : features.toString())
        .toLowerCase();
    
    if (type == "media") {
      return (featureStr.contains("media") ||
          featureStr.contains("audiomessages") ||
          featureStr.contains("videomessages") ||
          featureStr.contains("audio") ||
          featureStr.contains("video"));
    }
    if (type == "audiomessages") {
      return (featureStr.contains("audiomessages") ||
          featureStr.contains("audio"));
    }
    if (type == "videomessages") {
      return (featureStr.contains("videomessages") ||
          featureStr.contains("video"));
    }
    if (type == "publications") {
      return (featureStr.contains("articles") || featureStr.contains("books"));
    }
    if (type != "") {
      return featureStr.contains(type);
    }
    return true;
  }

  bool isDownloadsAllowed() {
    return (data['allow_downloads'] as bool);
  }

  static List<Media> parseMedia(dynamic res) {
    final parsed = res["latest_media"].cast<Map<String, dynamic>>();
    return parsed.map<Media>((json) => Media.fromJson(json)).toList();
  }

  static List<Articles> parseArticles(dynamic res) {
    final parsed = res["latest_articles"].cast<Map<String, dynamic>>();
    return parsed.map<Articles>((json) => Articles.fromJson(json)).toList();
  }

  static List<Books> parseBooks(dynamic res) {
    final parsed = res["latest_books"].cast<Map<String, dynamic>>();
    return parsed.map<Books>((json) => Books.fromJson(json)).toList();
  }

  static List<Events> parseEvents(dynamic res) {
    final parsed = res["upcoming_events"].cast<Map<String, dynamic>>();
    return parsed.map<Events>((json) => Events.fromJson(json)).toList();
  }

  static List<Userdata> parseMembers(dynamic res) {
    //final res = jsonDecode(responseBody);
    final parsed = res["members"].cast<Map<String, dynamic>>();
    return parsed
        .map<Userdata>((json) => Userdata.fromMembersJson(json))
        .toList();
  }
}



