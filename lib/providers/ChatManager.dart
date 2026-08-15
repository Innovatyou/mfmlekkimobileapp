import 'package:dio/dio.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/Chats.dart';
import 'package:higherground/models/ChatMessages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'events.dart';
import 'dart:async';
import 'dart:convert';
import 'package:higherground/utils/ApiUrl.dart';
import 'dart:math';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/service/Firebase.dart';
import 'package:clipboard/clipboard.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';

//on new message, fetch message details and append to top
//on user chat, sort messages to show the last chat friend on top
//only show notification if user is logged in
class ChatManager with ChangeNotifier {
  Userdata? userdata;
  String? useremail = "";
  bool isChatEnabled = false;
  List<Chats?> userChatsList = [];
  List<int?> selectedChatMessages = [];
  Chats? selectedChat;
  bool fetchingSelectedChatDetails = false;
  bool partnerChatFetchError = false;
  Random random = new Random();
  bool isError = false;
  bool isLoadingMoreChats = false;
  bool isErrorLoadingMoreChats = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  String apiURL = "";
  int page = 0;
  int lastConversationDate = 0;

  init() async {
    registerEvents();
  }

  registerEvents() {
    //logged in event
    eventBus.on<UserLoggedInEvent>().listen((event) {
      this.userdata = event.user;
      if (event.user == null) return;
      useremail = this.userdata!.email;
      isChatEnabled = true;
      fetchUserChats(0);
      notifyUserOnlinePresence(0);
      print("user login event called");
    });
    //when user initiates a new chat
    eventBus.on<StartPartnerChatEvent>().listen((event) {
      getUserChatDetails(event.user!);
      onSeenUserConversation(event.user!.email);
      eventBus.fire(OnChatOpen(true));
      print("start chat event called" + event.user!.name!);
    });
    eventBus.on<OnNewChatConversation>().listen((event) {
      makeConversation(event.chatMessages);
      lastConversationDate = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      print("uploadFile = " + event.chatMessages.uploadFile!);
      print("OnNewChatConversation event called");
    });
    eventBus.on<OnReceiveChatConversation>().listen((event) {
      print("OnReceiveChatConversation event called");
      if (userdata == null) return;
      lastConversationDate = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      if (selectedChat != null && selectedChat!.isTyping)
        selectedChat!.isTyping = false;
      setRecievedConversation(event.chatMessages, event.sender, event.message,
          event.items, event.notify);
    });
    eventBus.on<OnAppStateChanged>().listen((event) {
      if (event.state != "idle") {
        //print("saved messages = " + storedOfflineConversations.toString());
        //
        //user was idles
        //so we check for messages
        //and append to list
        Timer(Duration(seconds: 1), () {
          checkfornewmessages();
        });
        notifyUserOnlinePresence(0);
      } else {
        notifyUserOnlinePresence(1);
      }
    });

    eventBus.on<OnUserReadConversation>().listen((event) {
      String? partner = event.partner;
      //Chats? _chats = userChatsList.firstWhere(
      //    (element) => element!.partner!.email == partner,
      //    orElse: () => null);

      userChatsList.forEach((_chats) {
        if (_chats!.partner!.email == partner) {
          //if (_chats != null) {
          _chats.unseen = 0;
          List<ChatMessages> _chatMessages = List.from(_chats.chatMessages!);
          _chatMessages.forEach((element) {
            int indx = _chatMessages.indexOf(element);
            _chats.chatMessages![indx].seen = 0;
          });
          userChatsList[userChatsList.indexOf(_chats)] = _chats;
          notifyListeners();
          sortMessages();
          // }
        }
      });
    });

    eventBus.on<OnUserOnlineStatus>().listen((event) {
      String? partner = event.partner;
      if (selectedChat != null && selectedChat!.partner!.email == partner) {
        selectedChat!.lastSeenDate = event.lastSeen;
        selectedChat!.isOnline = event.status;
      }
      //Chats? _chats = userChatsList.firstWhere(
      //    (element) => element!.partner!.email == partner,
      //    orElse: () => null);
      userChatsList.forEach((_chats) {
        if (_chats!.partner!.email == partner) {
          _chats.isOnline = event.status;
          _chats.lastSeenDate = event.lastSeen;
          userChatsList[userChatsList.indexOf(_chats)] = _chats;
          notifyListeners();
        }
      });
      /*if (_chats != null) {
        _chats.isOnline = event.status;
        _chats.lastSeenDate = event.lastSeen;
        userChatsList[userChatsList.indexOf(_chats)] = _chats;
        notifyListeners();
      }*/
    });

    eventBus.on<OnUserTyping>().listen((event) {
      String? partner = event.partner;
      if (selectedChat != null && selectedChat!.partner!.email == partner) {
        selectedChat!.isTyping = true;
        notifyListeners();
        //cancel after 20 seconds
        Timer(Duration(seconds: 10), () {
          selectedChat!.isTyping = false;
          notifyListeners();
        });

        //Chats? _chats = userChatsList.firstWhere(
        //    (element) => element!.partner!.email == partner,
        //    orElse: () => null);
        userChatsList.forEach((_chats) {
          if (_chats!.partner!.email == partner) {
            _chats.isTyping = true;
            userChatsList[userChatsList.indexOf(_chats)] = _chats;
            notifyListeners();
            Timer(Duration(seconds: 5), () {
              _chats.isTyping = false;
              userChatsList[userChatsList.indexOf(_chats)] = _chats;
              notifyListeners();
            });
          }
        });
        /*if (_chats != null) {
          _chats.isTyping = true;
          userChatsList[userChatsList.indexOf(_chats)] = _chats;
          notifyListeners();
          Timer(Duration(seconds: 5), () {
            _chats.isTyping = false;
            userChatsList[userChatsList.indexOf(_chats)] = _chats;
            notifyListeners();
          });
        }*/
      }
    });

    eventBus.on().listen((event) {
      switch (event) {
        case AppEvents.LOGOUT:
          this.userdata = null;
          isChatEnabled = false;
          notifyUserOnlinePresence(1);
          print("user logout event called");
          break;
        case AppEvents.ONCHATCONVERSATIONCLOSED:
          print("on Close Conversation callled");
          eventBus.fire(OnChatOpen(false));
          selectedChat = null;
          selectedChatMessages = [];
          break;
      }
    });
  }

  loadItems() {
    refreshController.requestRefresh();
    page = 0;
    notifyListeners();
    fetchUserChats(userChatsList.length);
  }

  refreshItems() {
    page = 0;
    notifyListeners();
    fetchUserChats(0);
  }

  loadMoreItems() {
    page = page + 1;
    fetchUserChats(userChatsList.length);
  }

  void setItems(List<Chats?> item) {
    if (item.length != 0) {
      userChatsList.clear();
      userChatsList = item;
    }
    refreshController.refreshCompleted();
    isError = false;
    if (selectedChat != null) {
      userChatsList.forEach((element) {
        if (element!.partner!.email == selectedChat!.partner!.email) {
          selectedChat = element;
        }
      });
    }
    sortMessages();
    notifyListeners();
  }

  void setMoreItems(List<Chats?> item) {
    userChatsList.addAll(item);
    refreshController.loadComplete();
    notifyListeners();
  }

  Future<void> fetchUserChats(int count) async {
    if (userdata == null) return;
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_USER_CHATS,
        data: jsonEncode({
          "data": {
            "email": userdata!.email,
            "count": count,
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print("userchatssss = " + response.toString());
        dynamic res = Utility.decodeResponse(response.data);
        List<Chats?>? chatsList = parseUserChatsList(res);
        //print(chatsList!.length);
        if (page == 0) {
          setItems(chatsList!);
          lastConversationDate =
              (DateTime.now().millisecondsSinceEpoch ~/ 1000);
        } else {
          setMoreItems(chatsList!);
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      if (exception is DioException) {
        print(exception.stackTrace);
        print("userchatssss = " + exception.error.toString());
        print("userchatssss = " + exception.message.toString());
        print("userchatssss = " + exception.response.toString());
      }
      setFetchError();
    }
  }

  static List<Chats?>? parseUserChatsList(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["chatsList"].cast<Map<String, dynamic>>();
    return parsed.map<Chats>((json) => Chats.fromJson(json)).toList();
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

  getUserChatDetails(Userdata partner) {
    fetchingSelectedChatDetails = true;
    partnerChatFetchError = false;
    selectedChat = new Chats(
        id: 0,
        partner: partner,
        email1: userdata!.email,
        email2: partner.email,
        unseen: 0,
        isOnline: 1,
        lastSeenDate: 0,
        chatMessages: []);
    notifyListeners();
    // print(checkIfUserIsInChatList(partner.email));
    //return;
    if (!checkIfUserIsInChatList(partner.email)) {
      print("hello worldddd");
      //if current partner is not in list, we check our server if user have a chat history with this partner
      fetchPartnerChatData(partner.email);
    }
  }

  bool checkIfUserIsInChatList(String? partner) {
    if (userChatsList.length == 0) return false;
    print(userChatsList.length);
    bool status = false;
    for (var i = 0; i < userChatsList.length; i++) {
      var _chats = userChatsList[i];
      if (_chats != null && _chats.partner!.email! == partner) {
        selectedChat = _chats;
        fetchingSelectedChatDetails = false;
        _chats.unseen = 0;
        userChatsList[userChatsList.indexOf(_chats)] = _chats;
        notifyListeners();
        status = true;
      }
    }
    return status;
    // Chats? _chats = userChatsList.firstWhere(
    //     (element) => element!.partner!.email == partner,
    //     orElse: () => null);
  }

  Future<void> fetchPartnerChatData(String? partner) async {
    try {
      var data = {
        "data": {
          "email": userdata!.email,
          "partner": partner,
        }
      };
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_PARTNER_CHATS,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
        if (res['status'] == "ok") {
          //if user have a chat history and is current chat opened, we set as current chat,
          // we then add to chat lists if there was a previous conversation
          Chats _chat = Chats.fromJson(res['chat']);
          print(_chat.partner);
          if (selectedChat != null &&
              _chat.partner!.email == selectedChat!.partner!.email) {
            selectedChat = _chat;
            _chat.unseen = 0;
          }
          if (_chat.chatMessages!.length != 0) {
            userChatsList.add(_chat);
            sortMessages();
          }
          partnerChatFetchError = false;
          fetchingSelectedChatDetails = false;
          notifyListeners();
        } else {
          //if there is no chat history, we start a new chat here
          //we do not make changes till user sends first chat
          fetchingSelectedChatDetails = false;
          partnerChatFetchError = false;
          notifyListeners();
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setPartnerChatFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      if (exception is DioException) {
        print(exception.stackTrace);
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
      setPartnerChatFetchError();
    }
  }

  setPartnerChatFetchError() {
    fetchingSelectedChatDetails = false;
    partnerChatFetchError = true;
    notifyListeners();
  }

  //when user recieves a new message
  setRecievedConversation(ChatMessages chatMessages, Userdata sender,
      String? msg, Map<String, dynamic> items, bool notify) {
    if (selectedChat != null &&
        selectedChat!.partner!.email == chatMessages.sender) {
      selectedChat!.chatMessages!.insert(0, chatMessages);
      selectedChat!.lastMessageTime = chatMessages.date;
      //set this message to list
      setCurrentChatBody(selectedChat);
      sortMessages();
      notifyListeners();
      onSeenUserConversation(sender.email);
    } else {
      //set this message to list
      if (userChatsList.length == 0) {
        print("check 1111");
        fetchPartnerChatData(chatMessages.sender);
      } else {
        print("check22222");
        bool status = false;
        Chats? currentchats;
        int index = -1;
        userChatsList.forEach((_chats) {
          if (_chats!.partner!.email == chatMessages.sender) {
            currentchats = _chats;
            index = userChatsList.indexOf(_chats);
            status = true;
          }
        });
        if (currentchats != null) {
          currentchats!.chatMessages!.insert(0, chatMessages);
          currentchats!.unseen = currentchats!.unseen! + 1;
          currentchats!.lastMessageTime = chatMessages.date;
          userChatsList[index] = currentchats;
          notifyListeners();
          sortMessages();
          status = true;
        }
        if (status == false) {
          fetchPartnerChatData(chatMessages.sender);
        }
      }
      //notify user of new message
      if (notify) {
        sendNotification(sender.name, msg!, items);
        eventBus.fire(OnShowChatConversationCount());
      }
    }

    notifyListeners();
  }

  sendNotification(String? title, String msg, Map<String, dynamic> items) {
    Firebase.chatNotification(items, title, msg);
  }

  //make conversation
  makeConversation(ChatMessages chatMessages) {
    selectedChat!.chatMessages!.insert(0, chatMessages);
    selectedChat!.lastMessageTime = chatMessages.date;
    setCurrentChatBody(selectedChat);
    notifyListeners();
    saveUserConversation(chatMessages);
  }

  setCurrentChatBody(Chats? _selectedChat) {
    if (userChatsList.length == 0) {
      userChatsList.add(_selectedChat);
    } else {
      int pos = -1;
      userChatsList.forEach((_chats) {
        if (_chats != null &&
            _chats.partner!.email == _selectedChat!.partner!.email) {
          //userChatsList[userChatsList.indexOf(_chats)] = _selectedChat;
          pos = userChatsList.indexOf(_chats);
        } /*else {
          userChatsList.add(_selectedChat);
        }*/
      });
      if (pos != -1) {
        userChatsList[pos] = _selectedChat;
      } else {
        userChatsList.add(_selectedChat);
      }
    }

    //sort messages according to last recieved
    sortMessages();
  }

  //sort messages
  sortMessages() {
    Comparator<Chats?> sortByDate =
        (a, b) => a!.lastMessageTime!.compareTo(b!.lastMessageTime!);
    userChatsList.sort(sortByDate);
    userChatsList = userChatsList.reversed.toList();
    notifyListeners();
  }

  saveUserConversation(ChatMessages chatMessages) async {
    var map = {
      "chat_id": selectedChat!.id.toString(),
      "recipient": selectedChat!.partner!.email,
      "sender": userdata!.email,
      "msg_reciept": chatMessages.msgReciept.toString(),
      "msg_owner": chatMessages.msgOwner,
      "content": chatMessages.message == ""
          ? ""
          : Utility.getBase64EncodedString(chatMessages.message!),
    };
    print(map);
    FormData formData = FormData.fromMap(map);
    if (chatMessages.uploadFile != "") {
      formData.files.add(MapEntry(
          "photo", MultipartFile.fromFileSync(chatMessages.uploadFile!)));
    }
    try {
      var response = await Utility.getDio().post(ApiUrl.SAVE_CHAT_CONVERSATION,
          data: formData, onSendProgress: (int send, int total) {
        print((send / total) * 100);
      });
      print(response.data);
    } on DioException catch (e) {
      print(e.message);
    }
  }

//send event when user have seen
  Future<void> onSeenUserConversation(String? partner) async {
    print("Onseen User Conversation called");

    try {
      var data = {
        "data": {
          "email": userdata!.email,
          "partner": partner,
        }
      };
      final response = await Utility.getDio().post(
        ApiUrl.ONSEEN_USER_CONVERSATION,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      if (exception is DioException) {
        print(exception.stackTrace);
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
    }
  }

  //send event when user is typing
  Future<void> notifyUserTyping() async {
    if (selectedChat == null) return;
    try {
      var data = {
        "data": {
          "email": userdata!.email,
          "partner": selectedChat!.partner!.email,
        }
      };
      final response = await Utility.getDio().post(
        ApiUrl.ON_USER_TYPING,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  //send event when user is online/offline
  Future<void> notifyUserOnlinePresence(int status) async {
    if (useremail == "") return;
    try {
      var data = {
        "data": {
          "email": useremail,
          "status": status.toString(),
        }
      };
      final response = await Utility.getDio().post(
        ApiUrl.UPDATE_ONLINE_PRESENCE,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  bool isChatMessageSelected(int? reciept) {
    int? _chatMessages; // = selectedChatMessages
    //.firstWhere((element) => element == reciept, orElse: () => null);
    selectedChatMessages.forEach((element) {
      if (element == reciept) {
        _chatMessages = element;
      }
    });
    return _chatMessages != null;
  }

  selectChatMessage(int? _chatMessagesRcpt) {
    selectedChatMessages.add(_chatMessagesRcpt);
    notifyListeners();
  }

  unSelectChatMessage(int? reciept) {
    // int? _chatMessages = selectedChatMessages
    //     .firstWhere((element) => element == reciept, orElse: () => null);
    //if (_chatMessages == null) return;
    // selectedChatMessages.removeAt(selectedChatMessages.indexOf(_chatMessages));
    selectedChatMessages.forEach((element) {
      if (element == reciept) {
        selectedChatMessages.removeAt(selectedChatMessages.indexOf(element));
      }
    });
    notifyListeners();
  }

  resetSelectedChatMessages() {
    selectedChatMessages = [];
    notifyListeners();
  }

  removeSelectedChatMessages() {
    selectedChatMessages.forEach((itm) {
      //print(itm);
      //ChatMessages? _chatMessages = selectedChat!.chatMessages!
      //    .firstWhereOrNull((element) => element.msgReciept == itm);
      List<int> _itms = [];
      //if (_itms.length > 0) {
      selectedChat!.chatMessages!.forEach((element) {
        print(element.msgReciept);
        print(element.message);
        if (element.msgReciept == itm) {
          print(element.message);
          print(itm);
          _itms.add(selectedChat!.chatMessages!.indexOf(element));
          //selectedChat!.chatMessages!
          //    .removeAt(selectedChat!.chatMessages!.indexOf(element));
        }
      });
      //}
      _itms.forEach((element) {
        selectedChat!.chatMessages!.removeAt(element);
      });

      /*if (_chatMessages != null) {
        selectedChat!.chatMessages!
            .removeAt(selectedChat!.chatMessages!.indexOf(_chatMessages));
      }*/
    });
    //Chats? _chats = userChatsList.firstWhere(
    //   (element) => element!.partner!.email == selectedChat!.partner!.email,
    //   orElse: () => null);
    userChatsList.forEach((element) {
      if (element!.partner!.email == selectedChat!.partner!.email) {
        userChatsList[userChatsList.indexOf(element)] = selectedChat;
      }
    });
    //if (_chats != null) {
    //  userChatsList[userChatsList.indexOf(_chats)] = selectedChat;
    //}
    selectedChatMessages = [];
    notifyListeners();
  }

  Future<void> deleteSelectedChatMessagesOnline() async {
    if (selectedChat == null || userdata == null) return;
    List<int> _selected = List.from(selectedChatMessages);
    removeSelectedChatMessages();

    try {
      var data = {
        "data": {
          "partner": selectedChat!.partner!.email,
          "email": userdata!.email,
          "msgReciepts": _selected,
          "chatid": selectedChat!.id
        }
      };
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.DELETE_SELECTED_CHATS,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      if (exception is DioException) {
        print(exception.stackTrace);
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
    }
  }

  clearUserConversationList() {
    selectedChat!.chatMessages = [];
    /*Chats? _chats = userChatsList.firstWhere(
        (element) => element!.partner!.email == selectedChat!.partner!.email,
        orElse: () => null);
    if (_chats != null) {
      //userChatsList.removeAt(userChatsList.indexOf(_chats));
      userChatsList[userChatsList.indexOf(_chats)] = selectedChat;
    }*/
    userChatsList.forEach((element) {
      if (element!.partner!.email == selectedChat!.partner!.email) {
        userChatsList[userChatsList.indexOf(element)] = selectedChat;
      }
    });
    notifyListeners();
  }

  Future<void> clearUserConversation() async {
    if (selectedChat == null || userdata == null) return;
    clearUserConversationList();
    try {
      var data = {
        "data": {
          "partner": selectedChat!.partner!.email,
          "email": userdata!.email,
          "chatid": selectedChat!.id
        }
      };
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.CLEAR_USER_CONVERSATION,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  copyHighlightedMessages(BuildContext context) {
    String formatted = prepareHighlightedChatMessages()!;
    FlutterClipboard.copy(formatted)
        .then((value) => Alerts.showToast(context, t.copiedtoclipboard));
    resetSelectedChatMessages();
  }

  shareHightlightedMessages() async {
    String formatted = prepareHighlightedChatMessages()!;
    await Share.share(
      formatted,
      subject: selectedChatMessages.length == 1
          ? ""
          : userdata!.name! +
              " and " +
              selectedChat!.partner!.name! +
              " Chat Conversation",
    );
    resetSelectedChatMessages();
  }

  String? prepareHighlightedChatMessages() {
    if (selectedChatMessages.length == 1) {
      String _itms = "Nothing Found";
      /* ChatMessages? _chatMessages = selectedChat!.chatMessages!
          .firstWhereOrNull(
              (element) => element.msgReciept == selectedChatMessages[0]);
      if (_chatMessages != null) {
        return _chatMessages.message;
      }*/
      selectedChat!.chatMessages!.forEach((element) {
        if (element.msgReciept == selectedChatMessages[0]) {
          _itms = element.message!;
        }
      });
      return _itms;
    } else {
      String formatted = "";
      selectedChatMessages.forEach((itm) {
        selectedChat!.chatMessages!.forEach((_chatMessages) {
          if (_chatMessages.msgReciept == itm) {
            String? _content = _chatMessages.message != ""
                ? _chatMessages.message
                : _chatMessages.attachment;
            if (_chatMessages.sender == userdata!.email) {
              formatted += "[" +
                  TimUtil.formatFullDatestamp(_chatMessages.date!) +
                  "] \n" +
                  userdata!.name! +
                  ": " +
                  _content! +
                  "\n";
            } else {
              formatted += "[" +
                  TimUtil.formatFullDatestamp(_chatMessages.date!) +
                  "] \n" +
                  selectedChat!.partner!.name! +
                  ": " +
                  _content! +
                  "\n";
            }
          }
        });
        //ChatMessages? _chatMessages = selectedChat!.chatMessages!
        //    .firstWhereOrNull((element) => element.msgReciept == itm);
      });
      return formatted;
    }
  }

  blockUnblockUserDialog(BuildContext context) async {
    if (selectedChat == null) return;
    int? status = selectedChat!.isBlocked;
    await showDialog(
      context: context,
      builder: (context) => new CupertinoAlertDialog(
        title: new Text((status == 1 ? "Block " : "Unblock ") +
            selectedChat!.partner!.name!),
        content: new Text(status == 1
            ? ("You wont be able to send or recieve messages from " +
                selectedChat!.partner!.name!)
            : ("You will now be able to send and recieve messages from " +
                selectedChat!.partner!.name!)),
        actions: <Widget>[
          new TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(t.cancel),
          ),
          new TextButton(
            onPressed: () {
              blockUnblockUser(status == 1 ? 0 : 1);
              Navigator.of(context).pop(true);
            },
            child: new Text(
              t.ok,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  blockUnblockUser(int status) {
    if (selectedChat == null) return;
    selectedChat!.isBlocked = status;
    /*Chats? _chats = userChatsList.firstWhere(
        (element) => element!.partner!.email == selectedChat!.partner!.email,
        orElse: () => null);
    if (_chats != null) {
      userChatsList[userChatsList.indexOf(_chats)]!.isBlocked = status;
    }*/
    userChatsList.forEach((_chats) {
      if (_chats!.partner!.email == selectedChat!.partner!.email) {
        userChatsList[userChatsList.indexOf(_chats)]!.isBlocked = status;
      }
    });
    notifyListeners();
    blockUnblockUserServer(status);
  }

  Future<void> blockUnblockUserServer(int status) async {
    if (selectedChat == null || userdata == null) return;
    try {
      var data = {
        "data": {
          "partner": selectedChat!.partner!.email,
          "email": userdata!.email,
          "status": status
        }
      };
      final response = await Utility.getDio().post(
        ApiUrl.BLOCK_UNBLOCK_USER,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  loadMoreChats() {
    if (selectedChat != null && selectedChat!.hasMoreContent == 1) return;
    if (isLoadingMoreChats) return;
    isLoadingMoreChats = true;
    isErrorLoadingMoreChats = false;
    notifyListeners();
    loadMoreChatsServer();
  }

  loadMoreChatsError() {
    isLoadingMoreChats = false;
    isErrorLoadingMoreChats = true;
    notifyListeners();
  }

  //load more chats
  Future<void> loadMoreChatsServer() async {
    if (selectedChat == null) return;
    print(
        "total chat items = " + selectedChat!.chatMessages!.length.toString());
    String? email = selectedChat!.partner!.email;
    try {
      var data = {
        "data": {
          "email": userdata!.email,
          "partner": email,
          "chatId": selectedChat!.id,
          "count": selectedChat!.chatMessages!.length,
        }
      };
      print("load more data = " + data.toString());
      final response = await Utility.getDio().post(
        ApiUrl.LOAD_MORE_CHATS,
        data: jsonEncode(data),
      );
      if (selectedChat == null || selectedChat!.partner!.email != email) return;
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
        if (res['status'] == "ok") {
          List<ChatMessages> _chatMessages = getChats(res)!;
          selectedChat!.chatMessages!.addAll(_chatMessages);
          selectedChat!.hasMoreContent =
              int.parse(res['have_more_content'].toString());

          /*Chats? _chats = userChatsList.firstWhere(
              (element) => element!.partner!.email == email,
              orElse: () => null);
          if (_chats != null) {
            userChatsList[userChatsList.indexOf(_chats)] = selectedChat;
          }*/

          userChatsList.forEach((element) {
            if (element!.partner!.email == email) {
              userChatsList[userChatsList.indexOf(element)] = selectedChat;
            }
          });

          isLoadingMoreChats = false;
          isErrorLoadingMoreChats = false;
          notifyListeners();
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.

        loadMoreChatsError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      if (selectedChat == null || selectedChat!.partner!.email != email) return;
      loadMoreChatsError();
    }
  }

  Future<void> checkfornewmessages() async {
    print("Check for new messages");
    if (userChatsList.length == 0 || lastConversationDate == 0) return;
    try {
      var data = {
        "data": {
          "email": userdata!.email,
          "date": lastConversationDate,
        }
      };
      print(
          "checking for new messages when user was idle = " + data.toString());
      final response = await Utility.getDio().post(
        ApiUrl.CHECK_FOR_NEW_MESSAGES,
        data: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = Utility.decodeResponse(response.data);
        print(res);
        if (res['status'] == "ok") {
          List<ChatMessages> _chatMessages = getChats(res)!;
          print("_chatMessages length = " + _chatMessages.length.toString());
          _chatMessages.forEach((element) {
            if (selectedChat!.partner!.email == element.sender) {
              //we only add if the message is not there yet
              /*ChatMessages? _currentMessages = selectedChat!.chatMessages!
                  .firstWhereOrNull(
                      (_chat) => _chat.msgReciept == element.msgReciept);
              if (_currentMessages == null) {
                selectedChat!.chatMessages!.insert(0, element);
              }*/
              selectedChat!.chatMessages!.forEach((_currentMessages) {
                if (_currentMessages.msgReciept == element.msgReciept) {
                  selectedChat!.chatMessages!.insert(0, element);
                }
              });
            }

            userChatsList.forEach((_chats) {
              if (_chats!.partner!.email == element.sender) {
                _chats.chatMessages!.forEach((_element) {
                  if (_element.msgReciept == element.msgReciept) {
                    userChatsList[userChatsList.indexOf(_chats)]!
                        .chatMessages!
                        .insert(0, element);
                    userChatsList[userChatsList.indexOf(_chats)]!.unseen =
                        userChatsList[userChatsList.indexOf(_chats)]!.unseen! +
                            1;
                  }
                });
              }
            });

            /*Chats? _chats = userChatsList.firstWhere(
                (chat) => chat!.partner!.email == element.sender,
                orElse: () => null);
            if (_chats != null) {
              ChatMessages? __currentMessages = _chats.chatMessages!
                  .firstWhereOrNull(
                      (_chat) => _chat.msgReciept == element.msgReciept);
              if (__currentMessages == null) {
                userChatsList[userChatsList.indexOf(_chats)]!
                    .chatMessages!
                    .insert(0, element);
                userChatsList[userChatsList.indexOf(_chats)]!.unseen =
                    userChatsList[userChatsList.indexOf(_chats)]!.unseen! + 1;
              }
            }*/
          });
          notifyListeners();
        }
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  static List<ChatMessages>? getChats(dynamic res) {
    // final res = jsonDecode(responseBody);
    final parsed = res["chats"].cast<Map<String, dynamic>>();
    return parsed
        .map<ChatMessages>((json) => ChatMessages.fromJson(json))
        .toList();
  }
}



