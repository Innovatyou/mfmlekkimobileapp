import 'package:dio/dio.dart';
import 'package:higherground/models/Inbox.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/screens/InboxViewerScreen.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:higherground/utils/TimUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'PostCommentsScreen.dart';
import 'package:higherground/models/CommentsArguement.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/models/Notifications.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'utils.dart';

class NotificationSection extends StatefulWidget {
  static const routeName = "/NotificationSection";
  NotificationSection();

  @override
  NotificationSectionRouteState createState() =>
      new NotificationSectionRouteState();
}

class NotificationSectionRouteState extends State<NotificationSection>
    with AutomaticKeepAliveClientMixin {
  List<Notifications>? items = [];
  bool isError = false;
  Userdata? userdata;
  late RefreshController refreshController;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _notificationTabOpenedSubscription;
  int page = 0;

  void _onRefresh() async {
    loadItems();
  }

  void _onLoading() async {
    loadMoreItems();
  }

  loadItems() {
    page = 0;
    refreshController.requestRefresh();

    setState(() {});
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Notifications>? item) async {
    items!.clear();
    items = item;
    if (items != null && items!.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("last_inbox_message_id", items![0].timestamp!);
    }
    refreshController.refreshCompleted();
    isError = false;
    setState(() {});
  }

  void setMoreItems(List<Notifications> item) {
    items!.addAll(item);
    refreshController.loadComplete();
    setState(() {});
  }

  Future<void> fetchItems() async {
    try {
      final dio = await Utility.getAuthenticatedDio();
      final response = await dio.post(
        ApiUrl.userNotifications,
        data: jsonEncode({
          "data": {
            "email": userdata == null ? "" : userdata!.email,
            "page": page.toString()
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
          dynamic res;
          if (response.data is String) {
            res = jsonDecode(response.data);
          } else {
            res = response.data;
          }
        List<Notifications>? itmsList = parseNotifications(res);
        if (page == 0) {
          setItems(itmsList);
        } else {
          setMoreItems(itmsList!);
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
        print(exception.stackTrace);
        print(exception.error);
        print(exception.message);
        print(exception.response);
      }
      setFetchError();
    }
  }

  static List<Notifications>? parseNotifications(dynamic res) {
    //final res = jsonDecode(responseBody);
    final parsed = res["notifications"].cast<Map<String, dynamic>>();
    return parsed
        .map<Notifications>((json) => Notifications.fromJson(json))
        .toList();
  }

  setFetchError() {
    if (page == 0) {
      isError = true;
      refreshController.refreshFailed();
      setState(() {});
    } else {
      refreshController.loadFailed();
      setState(() {});
    }
  }

  @override
  void initState() {
    refreshController = RefreshController(initialRefresh: false);

    _notificationSubscription =
        eventBus.on<OnNotificationReceived>().listen((event) {
      if (!mounted) return;
      loadItems();
    });

    _notificationTabOpenedSubscription =
        eventBus.on<OnNotificationsTabOpened>().listen((event) {
      if (!mounted) return;
      loadItems();
    });

    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
    super.initState();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationTabOpenedSubscription?.cancel();
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(t.notifications),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text(t.pulluploadmore);
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text(t.loadfailedretry);
            } else if (mode == LoadStatus.canLoading) {
              body = Text(t.releaseloadmore);
            } else {
              body = Text(t.nomoredata);
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: (isError == true)
            ? NoitemScreen(
                title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
            : (items!.length == 0
                ? EmptyListScreen(message: t.noitemstodisplay)
                : ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 0.5,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: Divider(),
                        ),
                      );
                    },
                    itemCount: items!.length,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(3),
                    itemBuilder: (BuildContext context, int index) {
                      // print(items[index].coverPhoto);
                      Notifications notification = items![index];
                      return items![index].type! == "inbox"
                          ? InboxTile(
                              object: Inbox(
                                id: notification.id,
                                title: notification.title,
                                message: notification.message,
                                date: notification.timestamp,
                              ),
                            )
                          : NotificationsList(
                              object: notification,
                            );
                    },
                  )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class NotificationsList extends StatefulWidget {
  final Notifications object;

  const NotificationsList({
    Key? key,
    required this.object,
  }) : super(key: key);

  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListTile(
        onTap: () async {
          if (widget.object.type == "follow") return;
          await Navigator.pushNamed(
            context,
            PostCommentsScreen.routeName,
            arguments: CommentsArguement(item: widget.object.userPosts),
          );
        },
        leading: Card(
          margin: EdgeInsets.all(0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Container(
            height: 50,
            width: 50,
            child: CachedNetworkImage(
              imageUrl: widget.object.avatar!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter:
                          ColorFilter.mode(Colors.black12, BlendMode.darken)),
                ),
              ),
              placeholder: (context, url) =>
                  Center(child: CupertinoActivityIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.error,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(5),
        title: getUserName(
            context,
            new Userdata(
                email: widget.object.email,
                name: widget.object.name,
                photo: widget.object.avatar,
                coverphoto: widget.object.coverPhoto)),
        subtitle: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.object.message!,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              TimUtil.timeAgoSinceDate(widget.object.timestamp!),
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 15),
            ),
          ),
          widget.object.type == "follow"
              ? Container()
              : InkWell(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      PostCommentsScreen.routeName,
                      arguments:
                          CommentsArguement(item: widget.object.userPosts),
                    );
                  },
                  child: Row(
                    children: [
                      Spacer(),
                      Text(t.viewpost),
                      Icon(Icons.navigate_next)
                    ],
                  ),
                )
        ]),
      ),
    );
  }
}

class InboxTile extends StatelessWidget {
  final Inbox object;

  const InboxTile({
    Key? key,
    required this.object,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(InboxViewerScreen.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: object,
              itemsList: [],
            ));
      },
      child: RoundedContainer(
        padding: const EdgeInsets.all(5),
        margin: EdgeInsets.only(left: 4, right: 4),
        height: 100,
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Icon(Icons.notifications),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      //color: Colors.blue,
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          Text(
                            TimUtil.timeAgoSinceDate(object.date!),
                            style: TextStyles.caption(context)
                                .copyWith(fontSize: 12)
                                .copyWith(color: Colors.grey),
                          ),
                          Container(
                            width: 12,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        object.title!,
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ),
                    Container(
                      height: 6,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



