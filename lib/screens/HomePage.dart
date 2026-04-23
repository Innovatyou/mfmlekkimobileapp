import 'package:badges/badges.dart' as badge;
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:higherground/audio_player/miniPlayer.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/PublicationsPage.dart';
import 'package:higherground/screens/ConnectPage.dart';
import 'package:higherground/screens/DashboardScreen.dart';
import 'package:higherground/screens/MediaPage.dart';
import 'package:higherground/screens/SettingsPage.dart';
import 'package:higherground/socials/NotificationSection.dart';
import 'package:higherground/utils/MarqueeWidget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/socials/UserPostsSection.dart';
import 'package:higherground/socials/chat/ChatUsersScreen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  static const routeName = "/homescreen";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HomePageItem();
  }
}

class HomePageItem extends StatefulWidget {
  HomePageItem({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageItemState createState() => _HomePageItemState();
}

class _HomePageItemState extends State<HomePageItem>
    with SingleTickerProviderStateMixin {
  late DashboardModel dashmodel;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  List<BottomNavigationBarItem> items = [];

  final iconList = <IconData>[
    LineAwesomeIcons.home,
    LineAwesomeIcons.play_circle,
    LineAwesomeIcons.blog,
    LineAwesomeIcons.alternate_share,
    LineAwesomeIcons.teamspeak,
  ];

  String getTitle() {
    switch (currentIndex) {
      case 0:
        return t.appname;
      case 1:
        return t.media;
      case 2:
        return t.publications;
      case 3:
        return t.connect;
      case 4:
        return t.posts;
      default:
        return t.appname;
    }
  }

  @override
  void initState() {
    super.initState();
    DashboardModel dashmodel =
        Provider.of<DashboardModel>(context, listen: false);
    items.add(
        BottomNavigationBarItem(icon: Icon(iconList[0]), label: 'Home'));
    items.add(
        BottomNavigationBarItem(icon: Icon(iconList[1]), label: 'Media'));
    if (dashmodel.isFeatureAvailable("publications")) {
      items.add(
          BottomNavigationBarItem(icon: Icon(iconList[2]), label: 'Publications'));
    }
    items.add(
        BottomNavigationBarItem(icon: Icon(iconList[3]), label: 'Connect'));
    if (dashmodel.isFeatureAvailable("gosocial")) {
      items.add(
          BottomNavigationBarItem(icon: Icon(iconList[4]), label: 'Posts'));
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStateManager appManager = Provider.of<AppStateManager>(context);
    dashmodel = Provider.of<DashboardModel>(context);
    Userdata? userdata = appManager.userdata;
    return Scaffold(
      appBar: AppBar(
        title: MarqueeWidget(
          child: Text(
            getTitle(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: MyColors.mainC0lor,
        toolbarHeight: 50,
        elevation: 2,
        leading: Container(
            padding: const EdgeInsets.all(13.0),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(LineAwesomeIcons.user_edit),
              onPressed: () {
                Navigator.of(context).pushNamed(SettingsPage.routeName);
              },
            )),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 0),
            margin: EdgeInsets.only(right: 0),
            child: IconButton(
                padding: EdgeInsets.zero,
                icon: appManager.notificationcount == ""
                    ? Icon(LineAwesomeIcons.bell)
                    : badge.Badge(
                        badgeContent: Text(
                          appManager.notificationcount,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        child: Icon(LineAwesomeIcons.bell),
                      ),
                onPressed: (() {
                  appManager.unsetNotificationcount();
                  Navigator.of(context)
                      .pushNamed(NotificationSection.routeName);
                })),
          ),
          Container(
            width: 0,
          ),
          Container(
            padding: const EdgeInsets.only(right: 0),
            margin: EdgeInsets.only(right: 0),
            child: IconButton(
                padding: EdgeInsets.zero,
                icon: appManager.chatnotificationcount == ""
                    ? Icon(LineAwesomeIcons.facebook_messenger)
                    : badge.Badge(
                        badgeContent: Text(
                          appManager.chatnotificationcount,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        child: Icon(LineAwesomeIcons.facebook_messenger),
                      ),
                onPressed: (() {
                  if (userdata == null) {
                    Navigator.pushNamed(context, AuthPage.routeName,
                        arguments: true);
                  } else {
                    appManager.unsetChatNotificationcount();
                    Navigator.of(context).pushNamed(ChatUsersScreen.routeName);
                  }
                })),
          ),
          Container(
            width: 8,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: getBody(currentIndex),
          ),
          MiniPlayer(),
        ],
      ),
      bottomNavigationBar: SnakeNavigationBar.color(
        backgroundColor: Colors.grey[100],
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.indicator,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        padding: const EdgeInsets.all(0),

        ///configuration for SnakeNavigationBar.color
        snakeViewColor: MyColors.mainC0lor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.blueGrey,

        ///configuration for SnakeNavigationBar.gradient
        //snakeViewGradient: selectedGradient,
        //selectedItemGradient: snakeShape == SnakeShape.indicator ? selectedGradient : null,
        //unselectedItemGradient: unselectedGradient,

        showUnselectedLabels: false,
        showSelectedLabels: false,

        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: items,
      ),
    );
  }

  Widget getBody(int pos) {
    if (pos == 0) {
      return DashboardScreen();
    }
    if (pos == 1) {
      return MediaPage();
    }
    if (pos == 2) {
      if (dashmodel.isFeatureAvailable("publications")) {
        return PublicationsPage();
      }
      return ConnectPage();
    }
    if (pos == 3) {
      if (dashmodel.isFeatureAvailable("publications")) {
        return ConnectPage();
      }
      return UserPostsSection();
    }
    if (pos == 4) {
      return UserPostsSection();
    }
    return DashboardScreen();
    /*switch (pos) {
      case 0:
        return DashboardScreen();
      case 1:
        return MediaPage();
      case 2:
        return PublicationsPage();
      case 3:
        return ConnectPage();
      case 4:
        return UserPostsSection();
      default:
        return DashboardScreen();
    }*/
  }
}

class Constants {
  static final Color primaryColor = Color.fromRGBO(86, 215, 188, 1);
  static final Color scaffoldBackgroundColor = Color.fromRGBO(245, 247, 249, 1);
}



