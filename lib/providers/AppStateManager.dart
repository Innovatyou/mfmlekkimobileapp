import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/UserEvents.dart';
import 'events.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:higherground/utils/langs.dart';
import 'package:higherground/i18n/strings.g.dart';

class AppStateManager with ChangeNotifier {
  Userdata? userdata;
  bool? isUserSeenOnboardingPage = false;
  Timer? _pollTimer;
  int DEFAULT_LANGUAGE = 0;
  int preferredLanguage = 0;
  bool inboxnotifications = true;
  bool eventnotifications = true;
  bool sermonnotifications = true;
  bool articlesnotifications = true;
  bool devotionalsnotifications = true;
  bool youversionbible = false;
  final _langPreference = "language_preference";
  final _inboxnotificationPreference = "inbox_notification_preference";
  final _eventnotificationPreference = "event_notification_preference";
  final _sermonnotificationPreference = "sermon_notification_preference";
  final _articlenotificationPreference = "article_notification_preference";
  final _devotionalnotificationPreference =
      "devotional_notification_preference";
  final _youversionbiblePreference = "you_version_preference";
  String version = "";

  String notificationcount = "";
  String chatnotificationcount = "";

  AppStateManager() {
    _loadAppSettings();
    getUserData();
    getPackageInfo();
    registerEvents();
  }


  registerEvents() {
    //logged in event
    eventBus.on<OnShowChatConversationCount>().listen((event) {
      print(event);
      if (chatnotificationcount == "") {
        chatnotificationcount = "1";
      } else {
        int _chatnotificationcount = int.parse(chatnotificationcount);
        chatnotificationcount = (_chatnotificationcount + 1).toString();
      }
      notifyListeners();
    });

    /*eventBus.on<OnAppStateChanged>().listen((event) {
      if (event.state != "idle") {
        Timer(Duration(seconds: 1), () {
          getunseennotificationcount();
        });
      }
    });*/
  }

  getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }

  //app theme manager
  void _loadAppSettings() {
    SharedPreferences.getInstance().then((prefs) {
      //bible
      if (prefs.getBool(_youversionbiblePreference) != null) {
        youversionbible = prefs.getBool(_youversionbiblePreference)!;
      }
      //inbox
      if (prefs.getBool(_inboxnotificationPreference) != null) {
        inboxnotifications = prefs.getBool(_inboxnotificationPreference)!;
      }
      //events
      if (prefs.getBool(_eventnotificationPreference) != null) {
        eventnotifications = prefs.getBool(_eventnotificationPreference)!;
      }
      //sermons
      if (prefs.getBool(_sermonnotificationPreference) != null) {
        sermonnotifications = prefs.getBool(_sermonnotificationPreference)!;
      }
      //articles
      if (prefs.getBool(_articlenotificationPreference) != null) {
        articlesnotifications = prefs.getBool(_articlenotificationPreference)!;
      }
      //devotionals
      if (prefs.getBool(_devotionalnotificationPreference) != null) {
        devotionalsnotifications =
            prefs.getBool(_devotionalnotificationPreference)!;
      }
      try {
        //load app language
        preferredLanguage = prefs.getInt(_langPreference) ?? DEFAULT_LANGUAGE;
      } catch (e) {
        // quietly pass
      }
      switch (
          appLanguageData[AppLanguage.values[preferredLanguage]]!['value']) {
        case "en":
          LocaleSettings.setLocale(AppLocale.en);
          break;
        case "fr":
          LocaleSettings.setLocale(AppLocale.fr);
          break;
        case "es":
          LocaleSettings.setLocale(AppLocale.es);
          break;
        case "pt":
          LocaleSettings.setLocale(AppLocale.pt);
          break;

        case "de":
          LocaleSettings.setLocale(AppLocale.en);
          break;
        case "it":
          LocaleSettings.setLocale(AppLocale.en);
          break;
        case "ar":
          LocaleSettings.setLocale(AppLocale.en);
          break;
      }
      notifyListeners();
    });
  }

  //app language setting
  setAppLanguage(int index) async {
    //AppLanguage _preferredLanguage = AppLanguage.values[index];
    preferredLanguage = index;
    switch (appLanguageData[AppLanguage.values[preferredLanguage]]!['value']) {
      case "en":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "fr":
        LocaleSettings.setLocale(AppLocale.fr);
        break;
      case "es":
        LocaleSettings.setLocale(AppLocale.es);
        break;
      case "pt":
        LocaleSettings.setLocale(AppLocale.pt);
        break;

      case "de":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "it":
        LocaleSettings.setLocale(AppLocale.en);
        break;
      case "ar":
        LocaleSettings.setLocale(AppLocale.en);
        break;
    }
    // Here we notify listeners that theme changed
    // so UI have to be rebuild
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(_langPreference, preferredLanguage);
    eventBus.fire(OnLanguageChange());
  }

  //Youversion bible preference
  setYouVersionBiblePreference(bool checked) async {
    youversionbible = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_youversionbiblePreference, checked);
  }

  //inbox notification preference
  setInboxNotifications(bool checked) async {
    inboxnotifications = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_inboxnotificationPreference, checked);
  }

  //event notification preference
  setEventNotifications(bool checked) async {
    eventnotifications = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_eventnotificationPreference, checked);
  }

  //sermon notification preference
  setSermonNotifications(bool checked) async {
    sermonnotifications = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_sermonnotificationPreference, checked);
  }

  //sermon notification preference
  setArticleNotifications(bool checked) async {
    articlesnotifications = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_articlenotificationPreference, checked);
  }

  //devotionals notification preference
  setDevotionalNotifications(bool checked) async {
    devotionalsnotifications = checked;
    notifyListeners();
    // Save selected theme into SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(_devotionalnotificationPreference, checked);
  }

  getUserSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("user_seen_onboarding_page") != null) {
      isUserSeenOnboardingPage = prefs.getBool("user_seen_onboarding_page");
    }
  }

  setUserSeenOnboardingPage(bool seen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("user_seen_onboarding_page", seen);
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      getunseennotificationcount();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  getUserData() async {
    userdata = await SQLiteDbProvider.db.getUserData();
    print("userdata " + userdata.toString());
    getunseennotificationcount();
    notifyListeners();
    if (userdata == null) return;
    _startPolling();
    eventBus.fire(UserLoggedInEvent(userdata));
    updateUserToken();
  }

  setUserData(Userdata _userdata) async {
    await SQLiteDbProvider.db.deleteUserData();
    await SQLiteDbProvider.db.insertUser(_userdata);
    this.userdata = _userdata;
    _startPolling();
    eventBus.fire(UserLoggedInEvent(userdata));
    updateUserToken();
    getunseennotificationcount();
    notifyListeners();
  }

  unsetUserData() async {
    await SQLiteDbProvider.db.deleteUserData();
    this.userdata = null;
    _stopPolling();
    eventBus.fire(AppEvents.LOGOUT);
    unsetNotificationcount();
    unsetChatNotificationcount();
    notifyListeners();
  }

  Future<void> updateUserToken() async {
    if (userdata == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("firebase_token");
    if (token == null || token.isEmpty) return;
    final dio = await Utility.getAuthenticatedDio();
    // Send to both endpoints as required after every login
    final calls = [
      dio.post(
        ApiUrl.storeFcmToken,
        data: jsonEncode({"data": {"token": token, "version": "v2"}}),
      ),
      dio.post(
        ApiUrl.updateUserSocialFcmToken,
        data: jsonEncode({"data": {"email": userdata!.email, "token": token}}),
      ),
    ];
    try {
      await Future.wait(calls);
    } catch (e) {
      print("[AppStateManager] FCM token update failed: $e");
    }
  }

  Future<void> getunseennotificationcount() async {
    int? lastid = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt("last_inbox_message_id") != null) {
      lastid = prefs.getInt(
        "last_inbox_message_id",
      );
    }
    var data = {
      "lastid": lastid.toString(),
      "email": userdata == null ? "" : userdata!.email!
    };
    print("getunseennotificationcount" + data.toString());
    try {
      final response = await Utility.getDio().post(
        ApiUrl.UNSEEN_MESSAGES,
        data: jsonEncode({"data": data}),
      );

      if (response.statusCode == 200) {
        print(response.data);
        dynamic res = Utility.decodeResponse(response.data);
        int _notificationcount =
            int.parse(res['notification_count'].toString());
        if (_notificationcount == 0) {
          notificationcount = "";
        } else if (_notificationcount <= 9) {
          notificationcount = (_notificationcount - 1).toString();
        } else {
          notificationcount = "9+";
        }
        //chat
        int _unseenchatcount = int.parse(res['unseen_chat_count'].toString());
        if (_unseenchatcount == 0) {
          chatnotificationcount = "";
        } else if (_unseenchatcount <= 9) {
          chatnotificationcount = _unseenchatcount.toString();
        } else {
          chatnotificationcount = "9+";
        }
        notifyListeners();
      }
    } catch (exception) {
      print(exception);
      if (exception is DioException) {
        print(exception.stackTrace);
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
    }
  }

  unsetNotificationcount() {
    notificationcount = "";
    notifyListeners();
  }

  unsetChatNotificationcount() {
    chatnotificationcount = "";
    notifyListeners();
  }
}


