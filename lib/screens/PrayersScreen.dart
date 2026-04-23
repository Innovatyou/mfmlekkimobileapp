import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/providers/PrayerScreensModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/PostPrayerScreen.dart';
import 'package:higherground/screens/PrayerViewer.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class PrayersScreen extends StatefulWidget {
  static const routeName = "/PrayersScreen";
  PrayersScreen();

  @override
  PrayersScreenRouteState createState() => new PrayersScreenRouteState();
}

class PrayersScreenRouteState extends State<PrayersScreen> {
  @override
  Widget build(BuildContext context) {
    DashboardModel dashboardModel = Provider.of<DashboardModel>(context);
    return ChangeNotifierProvider(
      create: (context) => PrayerScreensModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(t.Prayerrequests),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 12),
          child: AudioScreenBody(),
        ),
        floatingActionButton: (dashboardModel.data['post_prayer'] as bool)
            ? FloatingActionButton.small(
                onPressed: () async {
                  Userdata? userdata = await SQLiteDbProvider.db.getUserData();
                  if (userdata == null) {
                    Navigator.of(context)
                        .pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context).pushNamed(PostPrayerScreen.routeName);
                  }
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: MyColors.mainC0lor,
              )
            : null,
      ),
    );
  }
}

class AudioScreenBody extends StatefulWidget {
  @override
  MediaScreenRouteState createState() => new MediaScreenRouteState();
}

class MediaScreenRouteState extends State<AudioScreenBody> {
  late PrayerScreensModel mediaScreensModel;
  List<Prayers>? items;
  var titleTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );

  void _onRefresh() async {
    mediaScreensModel.loadItems();
  }

  void _onLoading() async {
    mediaScreensModel.loadMoreItems();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      Provider.of<PrayerScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<PrayerScreensModel>(context);
    items = mediaScreensModel.itemList;

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
      controller: mediaScreensModel.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (mediaScreensModel.isError == true && items!.length == 0)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : ListView.separated(
              itemCount: items!.length,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                Prayers prayers = items![index];
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, PrayerViewer.routeName,
                        arguments: prayers);
                  },
                  leading: ClipOval(
                      child: Container(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(30),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(
                        LineAwesomeIcons.praying_hands,
                      ),
                    ),
                  )),
                  title: Text(
                    prayers.title!,
                    maxLines: 2,
                    style: titleTextStyle,
                  ),
                  subtitle: Text(prayers.date! + " | " + prayers.requester!),
                  trailing: Icon(Icons.navigate_next_rounded),
                );
              },
            ),
    );
  }
}



