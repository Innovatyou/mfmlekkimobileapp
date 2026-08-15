import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Inbox.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/InboxViewerScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NoitemScreen.dart';

class InboxListScreenState extends StatelessWidget {
  static const routeName = '/inboxlist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.inbox,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0f172a),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: InboxScreenBody(),
      ),
    );
  }
}

class InboxScreenBody extends StatefulWidget {
  @override
  InboxScreenBodyRouteState createState() => InboxScreenBodyRouteState();
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

  void loadItems() {
    refreshController.requestRefresh();
    page = 0;
    setState(() {});
    fetchItems();
  }

  void loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Inbox>? item) async {
    items!.clear();
    items = item;
    if (items != null && items!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('last_inbox_message_id', item![0].id!);
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
          'data': {'page': page.toString()}
        }),
      );

      if (response.statusCode == 200) {
        final dynamic res = Utility.decodeResponse(response.data);
        final List<Inbox>? mediaList = parseSliderMedia(res);
        if (page == 0) {
          Provider.of<AppStateManager>(context, listen: false)
              .unsetNotificationcount();
          setItems(mediaList);
        } else {
          setMoreItems(mediaList!);
        }
      } else {
        setFetchError();
      }
    } catch (exception) {
      print(exception);
      setFetchError();
    }
  }

  static List<Inbox>? parseSliderMedia(dynamic res) {
    final parsed = res['inbox'].cast<Map<String, dynamic>>();
    return parsed.map<Inbox>((json) => Inbox.fromJson(json)).toList();
  }

  void setFetchError() {
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
    Future.delayed(Duration.zero, () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xFF8E5972)),
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
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      controller: refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (isError == true && items!.isEmpty)
          ? NoitemScreen(
              title: t.oops,
              message: t.dataloaderror,
              onClick: _onRefresh,
            )
          : ListView.builder(
              itemCount: items!.length,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              itemBuilder: (BuildContext context, int index) {
                return ItemTile(object: items![index]);
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
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.of(context).pushNamed(
          InboxViewerScreen.routeName,
          arguments: ScreenArguements(
            position: 0,
            items: object,
            itemsList: [],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  TimUtil.formatDatestamp(object.date!),
                  style: TextStyles.caption(context).copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                Text(
                  TimUtil.formatTimestamp(object.date!),
                  style: TextStyles.caption(context).copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              object.title!,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF0f172a),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Bidi.stripHtmlIfNeeded(object.message!),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF6F616A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
