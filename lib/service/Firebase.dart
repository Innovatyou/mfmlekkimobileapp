import 'dart:convert';
import 'dart:async';
import 'package:higherground/utils/Utility.dart';

import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/Inbox.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/models/ChatMessages.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/models/UserEvents.dart';
import 'dart:math';

var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  Firebase.myBackgroundMessageHandler(message.data);
}

/// Top-level handler required by flutter_local_notifications for background notification actions.
/// For normal notification taps from a terminated app, use getNotificationAppLaunchDetails() instead.
@pragma('vm:entry-point')
Future<void> onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) async {
  // Background isolate — cannot navigate. Navigation is handled via
  // getNotificationAppLaunchDetails() when the app restarts.
}

class Firebase {
  late Function navigateMedia;
  late Function navigateSocials;
  late Function navigateInbox;
  late Function navigateLivestreams;
  late Function navigateChat;
  late Function navigateItem;
  static String appState = "idle";

  static bool? inboxnotifications = true;
  static bool? eventnotifications = true;
  static bool? sermonnotifications = true;
  static bool? articlesnotifications = true;
  static bool? devotionalsnotifications = true;
  static final _inboxnotificationPreference = "inbox_notification_preference";
  static final _eventnotificationPreference = "event_notification_preference";
  static final _sermonnotificationPreference = "sermon_notification_preference";
  static final _articlenotificationPreference =
      "article_notification_preference";
  static final _devotionalnotificationPreference =
      "devotional_notification_preference";

  Firebase(
    Function navigateMedia,
    Function navigateSocials,
    Function navigateInbox,
    Function navigateLivestreams,
    Function navigateChat,
    Function navigateItem,
  ) {
    this.navigateMedia = navigateMedia;
    this.navigateSocials = navigateSocials;
    this.navigateLivestreams = navigateLivestreams;
    this.navigateInbox = navigateInbox;
    this.navigateChat = navigateChat;
    this.navigateItem = navigateItem;
  }

  //updated myBackgroundMessageHandler
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    handleNotificationMessages(message);
    return Future<void>.value();
  }

  void init() async {
    FirebaseMessaging.instance.requestPermission();
    final InitializationSettings _initSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/launcher_icon"),
        iOS: DarwinInitializationSettings());

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// on did receive notification response = for when app is opened via notification while in foreground on android
    await flutterLocalNotificationsPlugin.initialize(_initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse? response) {
      print("NotificationResponse = " + response!.payload.toString());
      if (response.payload == null) return;
      onSelect(response.payload);
    }, onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse);

    // Handle tap on a local notification when the app was launched from terminated state.
    final NotificationAppLaunchDetails? launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final String? payload = launchDetails!.notificationResponse?.payload;
      if (payload != null) {
        print("App launched from local notification: $payload");
        Future.delayed(const Duration(milliseconds: 1000), () {
          onSelect(payload);
        });
      }
    }

    // Handle tap on an FCM notification when the app was in background (not killed).
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.data}");
      if (message.data.isNotEmpty) {
        onSelect(json.encode(message.data));
      }
    });

    // Handle tap on an FCM notification when the app was terminated (killed).
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        print("getInitialMessage: ${message.data}");
        Future.delayed(const Duration(milliseconds: 1000), () {
          onSelect(json.encode(message.data));
        });
      }
    });

    // Note: requestPermission on Android plugin removed/changed in newer versions.
    // Keep platform permission handling to FirebaseMessaging.requestPermission() above.

    FirebaseMessaging.onMessage.listen((message) async {
      print("onMessage: $message");
      print("onMessage:" + message.data.toString());
      handleNotificationMessages(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.instance.getToken().then((token) async {
      print("Push Messaging token: $token");
      sendFirebaseTokenToServer(token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("firebase_token", token!);
    });

    /*final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    _firebaseMessaging.configure(
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onMessage: (message) async {
        print("onMessage: $message");
        handleNotificationMessages(message);
      },
      onLaunch: (message) async {
        print("onLaunch: $message");
      },
      onResume: (message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.getToken().then((String token) async {
      print("Push Messaging token: $token");
      sendFirebaseTokenToServer(token);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("firebase_token", token);
    });*/
    initEvents();
  }

  static initEvents() async {
    eventBus.on<OnAppStateChanged>().listen((event) {
      appState = event.state;
      print("OnAppStateChanged event called = " + appState);
    });
  }

  static handleNotificationMessages(Map<String, dynamic> message) async {
    print("myBackgroundMessageHandler message1: $message");
    var data = message;
    //['data'];
    /*if (data == null) {
      data = message;
    }*/
    print("myBackgroundMessageHandler message: $data");
    var action = data["action"];
    bool shouldRefreshInAppNotifications = false;
    String? title = "";
    String? msg = "";
    if (action == "Event") {
      shouldRefreshInAppNotifications = true;
      eventnotifications = true;
      await setEventNotifications();
      if (!eventnotifications!) {
        return;
      }
      title = data["title"];
      msg = "New " + action;
    }
    if (action == "Article") {
      shouldRefreshInAppNotifications = true;
      articlesnotifications = true;
      await setArticleNotifications();
      if (!articlesnotifications!) {
        return;
      }
      title = data["title"];
      msg = "New " + action;
    }
    if (action == "Devotional") {
      shouldRefreshInAppNotifications = true;
      devotionalsnotifications = true;
      await setDevotionalNotifications();
      if (!devotionalsnotifications!) {
        return;
      }
      title = data["title"];
      msg = "New " + action;
    }
    if (action == "newMedia") {
      shouldRefreshInAppNotifications = true;
      sermonnotifications = true;
      await setSermonNotifications();
      if (!sermonnotifications!) {
        return;
      }
      Map<String, dynamic> arts = json.decode(data['media']);
      Media articles = Media.fromJson(arts);
      title = articles.description;
      msg = articles.title;
    }

    if (action == "social_notify") {
      shouldRefreshInAppNotifications = true;
      title = data["title"];
      msg = data["message"] ?? title;
    }

    if (action == "inbox") {
      shouldRefreshInAppNotifications = true;
      inboxnotifications = true;
      await setInboxNotifications();
      if (!inboxnotifications!) {
        return;
      }
      Map<String, dynamic> arts = json.decode(data['inbox']);
      print("myinbox = " + arts.toString());
      Inbox inbox = Inbox.fromJson(arts);
      title = inbox.message;
      msg = inbox.title;
    }

    if (action == "livestream") {
      shouldRefreshInAppNotifications = true;
      Map<String, dynamic> livestream = json.decode(data['livestream']);
      LiveStreams liveStreams = LiveStreams.fromJson(livestream);
      title = liveStreams.description;
      msg = liveStreams.title;
    }

    if (shouldRefreshInAppNotifications) {
      eventBus.fire(
        OnNotificationReceived(action?.toString() ?? '', data),
      );
    }

    if (action == "read_conversation") {
      String? partner = data['email'];
      eventBus.fire(OnUserReadConversation(partner));
      return;
    }

    if (action == "user_typing") {
      String? partner = data['email'];
      eventBus.fire(OnUserTyping(partner));
      return;
    }

    if (action == "online_status") {
      String? partner = data['email'];
      int status = data['status'] is int ? data['status'] : int.tryParse(data['status'].toString()) ?? 0;
      int lastSeen = data['last_seen'] is int ? data['last_seen'] : int.tryParse(data['last_seen'].toString()) ?? 0;
      eventBus.fire(OnUserOnlineStatus(partner, status, lastSeen));
      return;
    }

    if (action == "chat") {
      Map<String, dynamic> _chat = json.decode(data['chat']);
      Map<String, dynamic> _user = json.decode(data['user']);
      ChatMessages chat = ChatMessages.fromJson(_chat);
      Userdata sender = Userdata.fromFCMJson(_user);
      title = sender.name;
      msg = chat.message;
      eventBus
          .fire(OnReceiveChatConversation(chat, sender, msg, message, true));
      if (msg == "") {
        msg = "Sent a Photo";
      }
      //print(title + " and " + msg);
      if (appState == "active") {
        return;
      }
      chatNotification(message, title, msg!);
      return;
    }

    if (title != "") {
      BigTextStyleInformation bigTextStyleInformation =
          BigTextStyleInformation(msg!, contentTitle: title);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'churchapp', 'churchapp',
          color: MyColors.primary,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigTextStyleInformation,
          ticker: title);
      //var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: true));

      flutterLocalNotificationsPlugin.show(
          100, title, msg, platformChannelSpecifics,
          payload: json.encode(message));
    }
  }

  static chatNotification(
      Map<String, dynamic> message, String? name, String title) {
    List<String> lines = <String>[
      title,
    ];
    InboxStyleInformation inboxStyleInformation =
        InboxStyleInformation(lines, contentTitle: name, summaryText: title);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'churchapp', 'churchapp',
        color: MyColors.primary,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: inboxStyleInformation,
        ticker: name);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
            presentSound: true, presentAlert: true, presentBadge: true));

    flutterLocalNotificationsPlugin.show(
        new Random().nextInt(100000), name, title, platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<String?> onSelect(String? itm) async {
    print("onSelectNotification $itm");
    Map<String, dynamic> message = json.decode(itm!);
    var data = message;
    //['data'];
    /*if (data == null) {
      data = message;
    }*/
    var action = data["action"];
    print("pushNotification = " + action);
    if (action == "Event" || action == "Article" || action == "Devotional") {
      navigateItem(data["id"].toString(), action);
    }
    if (action == "newMedia") {
      Map<String, dynamic> arts = json.decode(data['media']);
      Media media = Media.fromJson(arts);
      navigateMedia(media);
    }
    if (action == "social_notify") {
      navigateSocials();
    }

    if (action == "inbox") {
      Map<String, dynamic> arts = json.decode(data['inbox']);
      Inbox inbox = Inbox.fromJson(arts);
      navigateInbox(inbox);
    }

    if (action == "livestream") {
      Map<String, dynamic> livestream = json.decode(data['livestream']);
      LiveStreams liveStreams = LiveStreams.fromJson(livestream);
      navigateLivestreams(liveStreams);
    }

    if (action == "chat") {
      Map<String, dynamic> _user = json.decode(data['user']);
      Userdata sender = Userdata.fromFCMJson(_user);
      navigateChat(sender);
    }

    return null;
  }

  sendFirebaseTokenToServer(String? token) async {
    bool? status = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("token_sent_to_server") != null) {
      status = prefs.getBool("token_sent_to_server");
    }
    if (status == false) {
      print("Firebase token not yet sent to server");

      var data = {"token": token, "version": "v2"};
      print(data.toString());
      try {
        final response = await Utility.getDio()
            .post(ApiUrl.storeFcmToken, data: jsonEncode({"data": data}));
        if (response.statusCode == 200) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          print(response.data);
          Map<String, dynamic> res = json.decode(response.data);
          if (res["status"] == "ok") {
            prefs.setBool("token_sent_to_server", true);
          }
        }
      } catch (exception) {
        // I get no exception here
        print(exception);
      }
    } else {
      print("Firebase token sent to server");
    }
  }

  //set the preferences for notifications
  //inbox notification preference
  static setInboxNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_inboxnotificationPreference) != null) {
      inboxnotifications = prefs.getBool(_inboxnotificationPreference);
    }
  }

  //event notification preference
  static setEventNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    //prefs.setBool(_eventnotificationPreference);
    if (prefs.getBool(_inboxnotificationPreference) != null) {
      inboxnotifications = prefs.getBool(_inboxnotificationPreference);
    }
  }

  //sermon notification preference
  static setSermonNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    //prefs.setBool(_sermonnotificationPreference, checked);
    if (prefs.getBool(_sermonnotificationPreference) != null) {
      sermonnotifications = prefs.getBool(_sermonnotificationPreference);
    }
  }

  //sermon notification preference
  static setArticleNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_articlenotificationPreference) != null) {
      articlesnotifications = prefs.getBool(_articlenotificationPreference);
    }
    //prefs.setBool(_articlenotificationPreference, checked);
  }

  //devotionals notification preference
  static setDevotionalNotifications() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_devotionalnotificationPreference) != null) {
      devotionalsnotifications =
          prefs.getBool(_devotionalnotificationPreference);
    }
    //prefs.setBool(_devotionalnotificationPreference, checked);
  }
}



