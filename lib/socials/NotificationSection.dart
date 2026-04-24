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
      if (exception is DioException) {
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
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        title: Text(
          t.notifications,
          style: const TextStyle(
            color: Color(0xFF23141D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text(t.pulluploadmore);
            } else if (mode == LoadStatus.loading) {
              body = const CupertinoActivityIndicator();
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
                        child: SizedBox(
                          height: 0.5,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: const Divider(),
                        ),
                      );
                    },
                    itemCount: items!.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE1E8)),
      ),
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
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: SizedBox(
            height: 50,
            width: 50,
            child: CachedNetworkImage(
              imageUrl: widget.object.avatar ?? '',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) =>
                  const Center(child: CupertinoActivityIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.person,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.all(5),
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF53404B)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              TimUtil.timeAgoSinceDate(widget.object.timestamp!),
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A7D86)),
            ),
          ),
          widget.object.type == "follow"
              ? const SizedBox.shrink()
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
                      const Spacer(),
                      Text(
                        t.viewpost,
                        style: const TextStyle(color: Color(0xFF563349)),
                      ),
                      const Icon(Icons.navigate_next, color: Color(0xFF563349))
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
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 4, right: 4),
        height: 100,
        child: Row(
          children: <Widget>[
            const CircleAvatar(
              backgroundColor: Color(0xFFF2E6EC),
              child: Icon(Icons.notifications, color: Color(0xFF563349)),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          const Spacer(),
                          Text(
                            TimUtil.timeAgoSinceDate(object.date!),
                            style: TextStyles.caption(context)
                                .copyWith(fontSize: 12)
                                .copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
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
                    const SizedBox(height: 6),
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



