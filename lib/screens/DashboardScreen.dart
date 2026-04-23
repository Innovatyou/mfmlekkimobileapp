import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/bible/BibleScreen.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/notes/NotesListScreen.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/DevotionalsScreen.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/EventsListScreen.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/screens/HymnsListScreen.dart';
import 'package:higherground/screens/ZoomLiveServiceScreen.dart';
import 'package:higherground/screens/SearchScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/langs.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/widgets/HomeTiles.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
// replaced carousel_slider usage with built-in PageView to avoid
// package name conflict with Flutter SDK CarouselController
import 'package:higherground/providers/DashboardModel.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen();

  @override
  DashboardScreenRouteState createState() => new DashboardScreenRouteState();
}

class DashboardScreenRouteState extends State<DashboardScreen> {
  late DashboardModel dashboardModel;
  late AppStateManager appStateManager;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

// My Text Styles
  TextStyle kHeadingextStyle = TextStyle(
    fontSize: 25,
    color: MyColors.white,
    fontWeight: FontWeight.bold,
  );
  TextStyle kSubheadingextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    height: 0,
  );

  TextStyle kTitleTextStyle = TextStyle(
    fontSize: 20,
    color: MyColors.white,
    fontWeight: FontWeight.bold,
  );

  TextStyle kSubtitleTextSyule = TextStyle(
    fontSize: 18,
    color: MyColors.white,
    // fontWeight: FontWeight.bold,
  );

  var titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );

  String getHeader() {
    Userdata? userdata = appStateManager.userdata;
    if (userdata == null) {
      return "Hi Friend, ";
    } else {
      return "Hi " + userdata.firstname!.toCapitalized() + ",";
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  void initState() {
    //Provider.of<DashboardModel>(context, listen: false).fetchItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);
    appStateManager = Provider.of<AppStateManager>(context);
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: MyColors.primaryDark,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                SizedBox(height: 15),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(getHeader(), style: kHeadingextStyle))),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(greeting() + "!", style: kSubheadingextStyle),
                    )),

                Visibility(
                  visible: dashboardModel.isFeatureAvailable("media"),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(SearchScreen.routeName);
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: MyColors.white, width: 0.5)),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 16),
                          Text(
                            t.searchmessagesbooks,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFA0A5BD),
                            ),
                          ),
                          Spacer(),
                          Icon(LineAwesomeIcons.search)
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0),

                Visibility(
                  visible: dashboardModel.isFeatureAvailable("events") &&
                      dashboardModel.upcomingevents.length > 0,
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    // color: Colors.white,
                    //margin: const EdgeInsets.only(left: 10, right: 10),
                    //padding: const EdgeInsets.only(left: 15, right: 0),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  t.upcomingevents,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              MaterialButton(
                                elevation: 0,
                                textColor: Colors.white,
                                color: MyColors.mainC0lor,
                                height: 0,
                                child: Icon(Icons.keyboard_arrow_right),
                                minWidth: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(EventsListScreen.routeName);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 250.0,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: dashboardModel.upcomingevents.length,
                            itemBuilder: (context, index) {
                              final media = dashboardModel.upcomingevents[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      EventsViewerScreen.routeName,
                                      arguments: ScreenArguements(
                                        position: 0,
                                        items: media,
                                        itemsList: [],
                                      ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    right: 5,
                                    bottom: 10,
                                    top: 10,
                                  ),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: CachedNetworkImage(
                                          imageUrl: media.thumbnail!,
                                          imageBuilder: (context, imageProvider) =>
                                              Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) => Center(
                                              child: CupertinoActivityIndicator()),
                                          errorWidget: (context, url, error) => Center(
                                              child: Icon(
                                            Icons.error,
                                            color: Colors.grey,
                                          )),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 70,
                                          color: Colors.black45,
                                          padding: EdgeInsets.all(12),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              media.title!,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 0,
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 3,
                    right: 3,
                    bottom: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: dashboardModel.isFeatureAvailable("events"),
                        child: HomeTiles(
                          index: 0,
                          title: t.events,
                          height: width > 600 ? 300 : 120,
                          width: (width / 3) - 2,
                          thumbnail: "assets/images/events.jpg",
                          color: Colors.red[100]!,
                          onclick: () {
                            Navigator.of(context)
                                .pushNamed(EventsListScreen.routeName);
                          },
                        ),
                      ),
                      Container(
                        width: 0,
                      ),
                      Visibility(
                        visible: dashboardModel.isFeatureAvailable("notes"),
                        child: HomeTiles(
                          index: 1,
                          title: t.notes,
                          height: width > 600 ? 300 : 120,
                          width: (width / 3) - 2,
                          thumbnail: "assets/images/notes.jpg",
                          color: Colors.orange[100]!,
                          onclick: () {
                            Navigator.of(context)
                                .pushNamed(NotesListScreen.routeName);
                          },
                        ),
                      ),
                      Container(
                        width: 0,
                      ),
                      Visibility(
                        visible: dashboardModel.isFeatureAvailable("donations"),
                        child: HomeTiles(
                            index: 2,
                            height: width > 600 ? 300 : 120,
                            width: (width / 3) - 2,
                            title: t.donate,
                            thumbnail: "assets/images/donate.jpg",
                            color: Colors.white,
                            onclick: () {
                              final donationsLink = dashboardModel.data['donations_link'];
                              final linkStr = donationsLink != null ? donationsLink.toString() : "";
                              if (linkStr.isEmpty) {
                                Utility.openBrowserTab(ApiUrl.DONATE);
                              } else {
                                Utility.openBrowserTab(linkStr);
                              }
                            }),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0,
                ),
                Visibility(
                  visible: dashboardModel.isFeatureAvailable("bible"),
                  child: getItem(LineAwesomeIcons.bible, t.bible,
                      "Dig deep into God's word.", () {
                    if (appStateManager.youversionbible) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: SizedBox(
                                  width: 180,
                                  child: Text(
                                    t.readbiblein,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  )),
                              content: Container(
                                height: 250.0,
                                width: 400.0,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: appLanguageData.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: Text(
                                        appLanguageData[AppLanguage
                                            .values[index]]!['name']!,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        switch (index) {
                                          case 0:
                                            Utility.openBrowserTab(
                                                ApiUrl.YOUVERSIONBIBLE_ENG);
                                            break;
                                          case 1:
                                            Utility.openBrowserTab(
                                                ApiUrl.YOUVERSIONBIBLE_FR);
                                            break;
                                          case 2:
                                            Utility.openBrowserTab(
                                                ApiUrl.YOUVERSIONBIBLE_SP);
                                            break;
                                          case 3:
                                            Utility.openBrowserTab(
                                                ApiUrl.YOUVERSIONBIBLE_PO);
                                            break;
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          });
                      return;
                    }
                    Navigator.of(context).pushNamed(BibleScreen.routeName);
                  }),
                ),
                Container(
                  height: 2,
                ),
                // Livestreams - show if the feature is available
                Visibility(
                  visible: dashboardModel.isFeatureAvailable("livestreams"),
                  child: getItem(LineAwesomeIcons.youtube, t.livestreams,
                      t.livestreamshint, () {
                    Navigator.of(context)
                        .pushNamed(LivestreamsScreen.routeName);
                  }),
                ),
                // Zoom Live Service
                Visibility(
                  visible: true,
                  child: getItem(LineAwesomeIcons.video, "Live Zoom Service",
                      "Join our live Sunday service on Zoom", () {
                    Navigator.of(context)
                        .pushNamed(ZoomLiveServiceScreen.routeName);
                  }),
                ),
                // Devotionals
                Visibility(
                  visible: dashboardModel.isFeatureAvailable("donations"),
                  child: getItem(LineAwesomeIcons.book_reader, t.devotionals,
                      t.devotionalshint, () {
                    Navigator.of(context)
                        .pushNamed(DevotionalsScreen.routeName);
                  }),
                ),

                Container(
                  height: 2,
                ),
                Visibility(
                  visible: dashboardModel.isFeatureAvailable("donations"),
                  child: getItem(LineAwesomeIcons.music, t.hymns,
                      "Sing to God! Sing praise to His name.", () {
                    Navigator.of(context).pushNamed(HymnsListScreen.routeName);
                  }),
                ),

                /*  Container(
                  margin: EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(EventsListScreen.routeName);
                          },
                          child: _buildGridItem(Icons.event_available_outlined,
                              t.events, Utility.hexToColor("#e3c674")),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(NotesListScreen.routeName);
                          },
                          child: _buildGridItem(
                              Icons.note_alt_sharp, t.notes, Colors.white),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            final donationsLink = dashboardModel.data['donations_link'];
                            final linkStr = donationsLink != null ? donationsLink.toString() : "";
                            if (linkStr.isEmpty) {
                              Utility.openBrowserTab(ApiUrl.DONATE);
                            } else {
                              Utility.openBrowserTab(linkStr);
                            }
                          },
                          child: _buildGridItem(LineAwesomeIcons.donate,
                              t.donate, Utility.hexToColor("#e3c674")),
                        ),
                      ),
                    ],
                  ),
                ),*/
                // _buildMenuList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getItem(IconData icon, title, String description, Function onclick) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 4,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title!),
        subtitle: Text(description),
        trailing: Icon(Icons.navigate_next),
        onTap: () {
          onclick();
        },
      ),
    );
  }

  Color getCOlor(int index) {
    if (index == 0) {
      return Colors.purple[500]!.withOpacity(0.2);
    }
    if (index == 1) {
      return Colors.blue[500]!.withOpacity(0.2);
    }
    return Colors.blue[500]!.withOpacity(0.4);
  }

  onclick(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, HymnsListScreen.routeName);
    }
    if (index == 3) {
      Navigator.of(context).pushNamed(NotesListScreen.routeName);
    }
  }
}



