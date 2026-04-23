import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Items.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/screens/AudioScreen.dart';
import 'package:higherground/screens/BookmarkScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/PhotosScreen.dart';
import 'package:higherground/screens/PlaylistsScreen.dart';
import 'package:higherground/screens/RadioScreen.dart';
import 'package:higherground/screens/VideoScreen.dart';
import 'package:higherground/widgets/HomeTiles.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/DashboardModel.dart';

class MediaPage extends StatefulWidget {
  MediaPage();

  @override
  MediaPageRouteState createState() => new MediaPageRouteState();
}

class MediaPageRouteState extends State<MediaPage> {
  late DashboardModel dashboardModel;
  List<Items> listthree = [];

  @override
  void initState() {
    super.initState();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            Container(
              margin: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: dashboardModel.isFeatureAvailable("videomessages"),
                    child: Expanded(
                      child: HomeTiles(
                        index: 0,
                        height: 220,
                        width: 200,
                        title: t.videos,
                        thumbnail: "assets/images/videos.jpg",
                        color: Colors.red[100]!,
                        onclick: () {
                          Navigator.of(context)
                              .pushNamed(VideoScreen.routeName);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 0,
                  ),
                  Visibility(
                    visible: dashboardModel.isFeatureAvailable("audiomessages"),
                    child: Expanded(
                      child: HomeTiles(
                        index: 1,
                        height: 220,
                        width: 200,
                        title: t.audios,
                        thumbnail: "assets/images/audios.jpg",
                        color: Colors.purple[100]!,
                        onclick: () {
                          Navigator.of(context)
                              .pushNamed(AudioScreen.routeName);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            _buildListItems(),
            SizedBox(
              height: 10,
            ),
            const SizedBox(height: 6.0),
          ],
        ),
      ),
    );
  }

  Widget _buildListItems() {
    return Container(
      //color: Colors.black,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dashboardModel.listthree.length,
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          Items itms = dashboardModel.listthree[index];
          return Card(
            elevation: 0.5,
            margin: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 4,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(itms.icon!),
              ),
              title: Text(itms.title!),
              subtitle: Text(itms.description!),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                onItemClick(itms.position!);
              },
            ),
          );
          /* return InkWell(
            onTap: () {
              //print(itms.position!);
              onItemClick(itms.position!);
            },
            child: Card(
              elevation: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //color: Colors.white,
                ),
                width: double.infinity,
                height: 70,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 6),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(width: 1, color: MyColors.mainC0lor),
                      // ),
                      child: Icon(itms.icon),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            itms.title!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(itms.description!,
                              style:
                                  TextStyle(fontSize: 13, letterSpacing: .3)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );*/
        },
      ),
    );
  }

  onItemClick(int pos) {
    switch (pos) {
      case 1:
        Navigator.of(context).pushNamed(VideoScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(AudioScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushNamed(PhotosScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushNamed(RadioScreen.routeName);
        break;
      case 5:
        Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
        break;
      case 6:
        Navigator.of(context).pushNamed(BookmarksScreen.routeName);
        break;
      case 7:
        Navigator.of(context).pushNamed(PlaylistsScreen.routeName);
        break;
      case 8:
        Navigator.pushNamed(context, Downloader.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: null,
            ));
        break;
    }
  }
}



