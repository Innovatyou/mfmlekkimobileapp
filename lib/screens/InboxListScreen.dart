import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:higherground/screens/InboxViewerScreen.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'dart:async';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/models/Inbox.dart';
import 'NoitemScreen.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/utils/ApiUrl.dart';

class InboxListScreenState extends StatelessWidget {
  static const routeName = "/inboxlist";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.inbox),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12),
        child: InboxScreenBody(),
      ),
    );
  }
}

class InboxScreenBody extends StatefulWidget {
  @override
  InboxScreenBodyRouteState createState() => new InboxScreenBodyRouteState();
}

class InboxScreenBodyRouteState extends State<InboxScreenBody> {
  List<Inbox>? items = [];
  bool isLoading = false;
  bool isError = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int page = 0;

  void _onRefresh() async {
    loadItems();
  }

  void _onLoading() async {
    loadMoreItems();
  }

  loadItems() {
    refreshController.requestRefresh();
    page = 0;
    setState(() {});
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Inbox>? item) async {
    items!.clear();
    items = item;
    if (items != null && items!.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("last_inbox_message_id", item![0].id!);
    }
    refreshController.refreshCompleted();
    isError = false;
    setState(() {});
  }

  void setMoreItems(List<Inbox> item) {
    refreshController.loadComplete();
    isError = false;
    items!.addAll(item);
    setState(() {});
  }

  Future<void> fetchItems() async {
    try {
      final response = await Utility.getDio().post(
        ApiUrl.INBOX,
        data: jsonEncode({
          "data": {"page": page.toString()}
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        print(res);
        List<Inbox>? mediaList = parseSliderMedia(res);
        if (page == 0) {
          Provider.of<AppStateManager>(context, listen: false)
              .unsetNotificationcount();
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

  static List<Inbox>? parseSliderMedia(dynamic res) {
    final parsed = res["inbox"].cast<Map<String, dynamic>>();
    return parsed.map<Inbox>((json) => Inbox.fromJson(json)).toList();
  }

  setFetchError() {
    if (page == 0) {
      setState(() {
        isError = true;
        refreshController.refreshFailed();
      });
    } else {
      setState(() {
        refreshController.loadFailed();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
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
      child: (isError == true && items!.length == 0)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : ListView.builder(
              itemCount: items!.length,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              itemBuilder: (BuildContext context, int index) {
                return ItemTile(
                  object: items![index],
                );
              },
            ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Inbox object;

  const ItemTile({
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
        margin: EdgeInsets.all(5),
        height: 150,
        child: Row(
          children: <Widget>[
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
                          Text(TimUtil.formatDatestamp(object.date!),
                              style: TextStyles.caption(context).copyWith(
                                  fontSize: 14, fontWeight: FontWeight.bold)
                              //.copyWith(color: MyColors.grey_60),
                              ),
                          Spacer(),
                          Text(TimUtil.formatTimestamp(object.date!),
                              style: TextStyles.caption(context).copyWith(
                                  fontSize: 14, fontWeight: FontWeight.bold)
                              //.copyWith(color: MyColors.grey_60),

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
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        Bidi.stripHtmlIfNeeded(object.message!),
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
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



