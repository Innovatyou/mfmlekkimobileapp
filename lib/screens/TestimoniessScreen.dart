import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Testimony.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/providers/TestimonyScreensModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/PostTestimonyScreen.dart';
import 'package:higherground/screens/TestimonyViewer.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class TestimoniessScreen extends StatefulWidget {
  static const routeName = "/TestimoniessScreen";
  TestimoniessScreen();

  @override
  TestimoniessScreennRouteState createState() =>
      new TestimoniessScreennRouteState();
}

class TestimoniessScreennRouteState extends State<TestimoniessScreen> {
  @override
  Widget build(BuildContext context) {
    DashboardModel dashboardModel = Provider.of<DashboardModel>(context);
    return ChangeNotifierProvider(
      create: (context) => TestimonyScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F2F5),
          surfaceTintColor: Colors.transparent,
          title: Text(
            t.testimonies,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF23141D),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AudioScreenBody(),
        ),
        floatingActionButton: (dashboardModel.data['post_testimony'] as bool)
            ? FloatingActionButton.small(
                onPressed: () async {
                  Userdata? userdata = await SQLiteDbProvider.db.getUserData();
                  if (userdata == null) {
                    Navigator.of(context)
                        .pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context)
                        .pushNamed(PostTestimonyScreen.routeName);
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
                backgroundColor: const Color(0xFF7A3F60),
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
  late TestimonyScreensModel mediaScreensModel;
  List<Testimony>? items;
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
      Provider.of<TestimonyScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<TestimonyScreensModel>(context);
    items = mediaScreensModel.itemList;

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
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 8);
              },
              itemBuilder: (BuildContext context, int index) {
                final testimony = items![index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8DDE4)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onTap: () {
                    Navigator.pushNamed(context, TestimonyViewer.routeName,
                        arguments: testimony);
                  },
                  leading: ClipOval(
                      child: Container(
                    color: const Color(0xFFF5EAF1),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: const Icon(
                        LineAwesomeIcons.quote_left,
                        color: Color(0xFF8F3E88),
                      ),
                    ),
                  )),
                  title: Text(
                    testimony.title!,
                    maxLines: 2,
                    style: titleTextStyle,
                  ),
                  subtitle: Text(
                    testimony.date! + " | " + testimony.testifier!,
                    style: const TextStyle(color: Color(0xFF7A6B75)),
                  ),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  ),
                );
              },
            ),
    );
  }
}



