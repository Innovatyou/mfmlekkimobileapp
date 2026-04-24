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
  late final PageController _pageController;
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          t.churchsocial,
          style: const TextStyle(
            color: Color(0xFF23141D),
            fontWeight: FontWeight.w700,
          ),
        ),
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
              margin: const EdgeInsets.all(12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                height: 30,
                width: 30,
                child: CachedNetworkImage(
                  imageUrl: userdata?.photo ?? '',
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
          )
        ],
      ),
      extendBody: true,
      body: Container(
        margin: const EdgeInsets.only(bottom: 78),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, position) {
            return _handleNavigationChange(position);
          },
          itemCount: 5,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFECE1E8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: MyColors.mainC0lor,
            unselectedItemColor: const Color(0xFF8B7D86),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            currentIndex: currentIndex,
            onTap: (int index) {
              setState(() {
                currentIndex = index;
              });

              if (index == 3) {
                eventBus.fire(OnNotificationsTabOpened());
              }

              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            items: navigationItems.toList(),
          ),
        ),
      ),
    );
  }

  Widget _handleNavigationChange(int index) {
    Widget? _child;
    switch (index) {
      case 0:
        _child = UserPostsSection();
        break;
      case 1:
        _child = ChatUsersScreen();
        break;
      case 2:
        _child = FollowPeopleSection();
        break;
      case 3:
        _child = NotificationSection();
        break;
      case 4:
        _child = SettingsScreen();
        break;
    }
    return AnimatedSwitcher(
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      duration: const Duration(milliseconds: 500),
      child: _child,
    );
  }
}


