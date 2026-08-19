import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class DashboardModel with ChangeNotifier {
  var data = {
    "features": "",
    "app_login": true,
    "mobile_app_enabled": true,
    "mobile_app_name": "",
    "mobile_primary_color": "#6366F1",
    "mobile_accent_color": "#F59E0B",
    "mobile_background_color": "#F0F2F5",
    "mobile_icon_color": "#FFFFFF",
    "mobile_tagline": "Towards global evangelism",
    "mobile_header_color": "#4F46E5",
    "mobile_chat_background_color": "#F8F5F8",
    "mobile_logo_url": "",
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
  List<Map<String, dynamic>> mobileAdverts = [];
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

  Future<void> loadBranding() async {
    try {
      final response = await Utility.getDio().get(
        ApiUrl.INIT_APP,
        options: Options(responseType: ResponseType.plain),
      );
      final decoded = response.data is String
          ? Utility.decodeResponse(response.data)
          : response.data;
      if (decoded is! Map || decoded['settings'] is! Map) return;
      final settings = decoded['settings'] as Map;
      data['mobile_app_name'] = settings['mobile_app_name'] ?? '';
      data['mobile_primary_color'] =
          settings['mobile_primary_color'] ?? '#6366F1';
      data['mobile_accent_color'] =
          settings['mobile_accent_color'] ?? '#F59E0B';
      data['mobile_background_color'] =
          settings['mobile_background_color'] ?? '#F0F2F5';
      data['mobile_icon_color'] = settings['mobile_icon_color'] ?? '#FFFFFF';
      data['mobile_tagline'] =
          settings['mobile_tagline'] ?? 'Towards global evangelism';
      data['mobile_header_color'] =
          settings['mobile_header_color'] ?? '#4F46E5';
      data['mobile_chat_background_color'] =
          settings['mobile_chat_background_color'] ?? '#F8F5F8';
      data['mobile_logo_url'] = settings['mobile_logo_url'] ?? '';
      notifyListeners();
    } catch (error) {
      debugPrint('[DashboardModel] Branding load failed: $error');
    }
    await loadMobileAdverts();
  }

  Future<void> loadMobileAdverts() async {
    try {
      final response = await Utility.getDio().get(ApiUrl.MOBILE_ADVERTS);
      final decoded = response.data is String
          ? Utility.decodeResponse(response.data)
          : response.data;
      if (decoded is Map && decoded['adverts'] is List) {
        mobileAdverts = (decoded['adverts'] as List)
            .whereType<Map>()
            .map((advert) => Map<String, dynamic>.from(advert))
            .toList();
        notifyListeners();
      }
    } catch (error) {
      debugPrint('[DashboardModel] Mobile adverts load failed: $error');
    }
  }

  Color brandingColor(String key, Color fallback) {
    final hex = data[key]?.toString().replaceFirst('#', '');
    if (hex == null || !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(hex))
      return fallback;
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> fetchItems() async {
    try {
      print("[DashboardModel] Starting fetchItems...");

      Userdata? userdata =
          kIsWeb ? null : await SQLiteDbProvider.db.getUserData();
      print(
          "[DashboardModel] User email: ${userdata?.email ?? 'not logged in'}");

      print("[DashboardModel] Making POST request to ${ApiUrl.INIT_APP}");

      final requestData = {
        "data": {"email": userdata == null ? "" : userdata.email}
      };
      print("[DashboardModel] Request payload: $requestData");

      // Shared-hosting security blocks empty browser POST requests to initapp.
      // Web does not need the optional member email during initial startup.
      Response response;
      if (kIsWeb) {
        response = await Utility.getDio().get(
          ApiUrl.INIT_APP,
          options: Options(responseType: ResponseType.plain),
        );
      } else {
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
          print(
              "[DashboardModel] POST request failed, trying GET as fallback...");
          print("[DashboardModel] POST Error: $e");
          response = await Utility.getDio().get(
            ApiUrl.INIT_APP,
            options: Options(responseType: ResponseType.plain),
          );
        }
      }

      print(
          "[DashboardModel] Response received - Status: ${response.statusCode}");
      print(
          "[DashboardModel] Response data type: ${response.data.runtimeType}");
      print("[DashboardModel] Raw response: ${response.data}");

      if (response.statusCode == 200) {
        dynamic res;

        try {
          // Handle both String and Map responses
          if (response.data is String) {
            res = Utility.decodeResponse(response.data);
          } else {
            res = response.data;
          }
        } catch (parseError) {
          // The backend /initapp endpoint is returning plain text or HTML
          // instead of JSON.  This is almost always caused by one of:
          //   1. The CodeIgniter debugbar is ON (application/config/config.php:
          //      $config['show_error_detail'] = TRUE, or ENVIRONMENT = 'development').
          //      FIX: set ENVIRONMENT to 'production' in index.php, or disable
          //      the debug bar via spark/debugbar config.
          //   2. The initapp controller is not yet implemented — it's echoing a
          //      placeholder string.  FIX: implement the controller to return a
          //      JSON response with a 'settings' key.
          // The app will continue with a built-in default feature set.
          print(
              "[DashboardModel] ERROR: Failed to parse /initapp response as JSON");
          print("[DashboardModel] Parse Error: $parseError");
          print("[DashboardModel] Raw response was: ${response.data}");
          print(
              "[DashboardModel] DIAGNOSIS: Backend /initapp endpoint is not returning valid JSON");
          print("[DashboardModel] Using default configuration to proceed...");

          // Use a default configuration if backend is not properly implemented
          res = {
            "errors": false,
            "message": "Using default config",
            "settings": {
              "features":
                  "hymns|notes|photos|radio|livestreams|prayer|testimony|books|articles|events|members",
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
        if (res is Map &&
            res["errors"] == true &&
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
        // "1" = feature enabled/required, "0" = disabled
        data['app_login'] = settings['app_login'] == "1";
        data['mobile_app_enabled'] =
            settings['mobile_app_enabled']?.toString() != "0";
        data['mobile_app_name'] = settings['mobile_app_name'] ?? "";
        data['mobile_primary_color'] =
            settings['mobile_primary_color'] ?? "#6366F1";
        data['mobile_accent_color'] =
            settings['mobile_accent_color'] ?? "#F59E0B";
        data['mobile_background_color'] =
            settings['mobile_background_color'] ?? "#F0F2F5";
        data['mobile_icon_color'] = settings['mobile_icon_color'] ?? "#FFFFFF";
        data['mobile_tagline'] =
            settings['mobile_tagline'] ?? "Towards global evangelism";
        data['mobile_header_color'] =
            settings['mobile_header_color'] ?? "#4F46E5";
        data['mobile_chat_background_color'] =
            settings['mobile_chat_background_color'] ?? "#F8F5F8";
        data['mobile_logo_url'] = settings['mobile_logo_url'] ?? "";
        data['allow_downloads'] = settings['allow_downloads'] == "1";
        data['join_groups'] = settings['join_groups'] == "1";
        data['post_prayer'] = settings['post_prayer'] == "1";
        data['post_testimony'] = settings['post_testimony'] == "1";

        data['facebook'] = settings['facebook'] ?? "";
        data['twitter'] = settings['twitter'] ?? "";
        data['instagram'] = settings['instagram'] ?? "";
        data['youtube'] = settings['youtube'] ?? "";
        data['website'] = settings['website'] ?? "";
        data['donations_link'] = settings['donations_link'] ?? "";

        print("[DashboardModel] Features available: ${data['features']}");

        // Parse all lists safely
        recentmedia = res.containsKey("latest_media") ? parseMedia(res) : [];
        recentarticles =
            res.containsKey("latest_articles") ? parseArticles(res) : [];
        recentbooks = res.containsKey("latest_books") ? parseBooks(res) : [];
        upcomingevents =
            res.containsKey("upcoming_events") ? parseEvents(res) : [];
        recentmembers = res.containsKey("members") ? parseMembers(res) : [];

        print("[DashboardModel] Data parsed successfully");
        print(
            "[DashboardModel] Media: ${recentmedia.length}, Articles: ${recentarticles.length}, Books: ${recentbooks.length}");

        setListItems();
        notifyListeners();

        Userdata? u = kIsWeb ? null : await SQLiteDbProvider.db.getUserData();
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
        print(
            "[DashboardModel] Response Content-Type: ${e.response?.headers['content-type']}");
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
        print(
            "[DashboardModel] CAUSE: DNS lookup failed - hostname could not be resolved");
        print(
            "[DashboardModel] CHECK: Does the device/emulator have working DNS and internet access?");
        print(
            "[DashboardModel] CHECK: Host configured in ApiUrl.BASEURL = ${ApiUrl.BASEURL}");
      } else if (dioType.contains('connect') &&
          !dioType.contains('connectionerror')) {
        print(
            "[DashboardModel] CAUSE: Connection timeout - backend server took too long to respond");
        print("[DashboardModel] CHECK: Is the backend server accessible?");
      } else if (dioType.contains('receive')) {
        print(
            "[DashboardModel] CAUSE: Receive timeout - response took too long");
      } else if (dioType.contains('send')) {
        print(
            "[DashboardModel] CAUSE: Send timeout - took too long to send request");
      } else if (errorText.contains('certificate') ||
          errorText.contains('ssl')) {
        print("[DashboardModel] CAUSE: SSL certificate validation failed");
        print(
            "[DashboardModel] CHECK: Server certificate may be invalid, expired, or rejected by the device");
      } else if (dioType.contains('connectionerror') ||
          dioType.contains('other') ||
          dioType.contains('error') ||
          errorText.contains('socketexception')) {
        print("[DashboardModel] CAUSE: Network error or socket error");
        print("[DashboardModel] CHECK: Internet connection available?");
        if (e.error != null) {
          print("[DashboardModel] Inner error: ${e.error}");
          if (e.error.toString().contains("CERTIFICATE") ||
              e.error.toString().contains("certificate")) {
            print("[DashboardModel] SSL Certificate validation error detected");
            print(
                "[DashboardModel] SOLUTION: Server may have self-signed certificate or expired certificate");
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
      if (e.toString().contains("CERTIFICATE") ||
          e.toString().contains("certificate") ||
          e.toString().contains("SSL")) {
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
          icon: FontAwesomeIcons.bookBible.data));
    }
    if (isFeatureAvailable("notes")) {
      listone.add(Items(3,
          title: t.notes,
          description: t.notes,
          photo: "notes.jpg",
          icon: FontAwesomeIcons.list.data));
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
          icon: FontAwesomeIcons.radio.data));
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
    String featureStr =
        (features is String ? features : features.toString()).toLowerCase();

    // Empty features string means not yet configured — show everything
    if (featureStr.isEmpty) return true;

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
