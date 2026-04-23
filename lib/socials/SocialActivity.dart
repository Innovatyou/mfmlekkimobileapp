import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/events.dart';
import 'package:provider/provider.dart';
import 'FollowPeopleSection.dart';
import 'NotificationSection.dart';
import 'UserPostsSection.dart';
import 'Settings.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'UserProfileScreen.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/UserEvents.dart';
import 'chat/ChatUsersScreen.dart';

class SocialActivity extends StatefulWidget {
  static const routeName = "/socialactivity";
  SocialActivity({Key? key}) : super(key: key);

  @override
  _SocialActivityState createState() => _SocialActivityState();
}

class _SocialActivityState extends State<SocialActivity> {
  Userdata? userdata;
  PageController? _pageController;
  int currentIndex = 0;

  List<BottomNavigationBarItem> navigationItems = [
    BottomNavigationBarItem(
        icon: Icon(
          Icons.home,
        ),
        label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: "Groups"),
    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(t.churchsocial),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                UserProfileScreen.routeName,
                arguments: ScreenArguements(items: userdata),
              );
            },
            child: Card(
              margin: EdgeInsets.all(12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                height: 30,
                width: 30,
                child: CachedNetworkImage(
                  imageUrl: userdata!.photo!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black12, BlendMode.darken)),
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
          )
        ],
      ),
      extendBody: true,
      body: PageView.builder(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, position) {
          return _handleNavigationChange(position);
        },
        itemCount: 5, // Can be null
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: MyColors.mainC0lor,
        unselectedItemColor: MyColors.grey_40,
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 3) {
            eventBus.fire(OnNotificationsTabOpened());
          }

          _pageController!.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        items: navigationItems.toList(),
      ),
    );
  }

  Widget _handleNavigationChange(int index) {
    Widget? _child;
    switch (index) {
      case 0:
        _child = Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 55),
            child: UserPostsSection());
        break;
      case 1:
        _child = Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 55), child: ChatUsersScreen());
        break;
      case 2:
        _child = Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 55),
            child: FollowPeopleSection());
        break;
      case 3:
        _child = Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 55),
            child: NotificationSection());
        break;
      case 4:
        _child = Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 55), child: SettingsScreen());
        break;
    }
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: Duration(milliseconds: 500),
      child: _child,
    );
  }
}


