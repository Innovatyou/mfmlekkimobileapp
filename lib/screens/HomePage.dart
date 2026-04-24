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

class _HomeTab {
  const _HomeTab({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final Widget Function() builder;
}

class _HomePageItemState extends State<HomePageItem>
    with SingleTickerProviderStateMixin {
  late DashboardModel dashmodel;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0;
  final List<_HomeTab> tabs = [];

  String get currentTitle => tabs[currentIndex].label;

  @override
  void initState() {
    super.initState();
    dashmodel = Provider.of<DashboardModel>(context, listen: false);
    tabs.add(
      _HomeTab(
        icon: LineAwesomeIcons.home,
        label: t.appname,
        builder: () => DashboardScreen(),
      ),
    );
    tabs.add(
      _HomeTab(
        icon: LineAwesomeIcons.play_circle,
        label: t.media,
        builder: () => MediaPage(),
      ),
    );
    if (dashmodel.isFeatureAvailable("publications")) {
      tabs.add(
        _HomeTab(
          icon: LineAwesomeIcons.blog,
          label: t.publications,
          builder: () => PublicationsPage(),
        ),
      );
    }
    tabs.add(
      _HomeTab(
        icon: LineAwesomeIcons.alternate_share,
        label: t.connect,
        builder: () => ConnectPage(),
      ),
    );
    if (dashmodel.isFeatureAvailable("gosocial")) {
      tabs.add(
        _HomeTab(
          icon: LineAwesomeIcons.teamspeak,
          label: t.posts,
          builder: () => UserPostsSection(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStateManager appManager = Provider.of<AppStateManager>(context);
    dashmodel = Provider.of<DashboardModel>(context);
    Userdata? userdata = appManager.userdata;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F4),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            MarqueeWidget(
              child: Text(
                currentIndex == 0
                    ? 'Worship, grow, and stay connected.'
                    : 'Everything you need for this moment.',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColors.primaryDark,
                MyColors.mainC0lor,
                const Color(0xFFB73D7C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
          child: _buildChromeButton(
            icon: LineAwesomeIcons.user_edit,
            onPressed: () {
              Navigator.of(context).pushNamed(SettingsPage.routeName);
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildChromeButton(
              icon: LineAwesomeIcons.bell,
              badgeText: appManager.notificationcount,
              onPressed: () {
                appManager.unsetNotificationcount();
                Navigator.of(context).pushNamed(NotificationSection.routeName);
              },
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, right: 16),
            child: _buildChromeButton(
              icon: LineAwesomeIcons.facebook_messenger,
              badgeText: appManager.chatnotificationcount,
              onPressed: () {
                if (userdata == null) {
                  Navigator.pushNamed(context, AuthPage.routeName,
                      arguments: true);
                } else {
                  appManager.unsetChatNotificationcount();
                  Navigator.of(context).pushNamed(ChatUsersScreen.routeName);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tabs[currentIndex].builder(),
          ),
          MiniPlayer(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: MyColors.primaryDark.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SnakeNavigationBar.color(
            backgroundColor: Colors.transparent,
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.indicator,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            snakeViewColor: MyColors.primary.withValues(alpha: 0.14),
            selectedItemColor: MyColors.mainC0lor,
            unselectedItemColor: const Color(0xFF7E7380),
            showUnselectedLabels: false,
            showSelectedLabels: false,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() => currentIndex = index);
            },
            items: tabs
                .map(
                  (tab) => BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildChromeButton({
    required IconData icon,
    required VoidCallback onPressed,
    String badgeText = '',
  }) {
    final Widget button = Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );

    if (badgeText.isEmpty) {
      return button;
    }

    return badge.Badge(
      position: badge.BadgePosition.topEnd(top: -10, end: -8),
      badgeStyle: badge.BadgeStyle(
        badgeColor: const Color(0xFFFFD166),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      badgeContent: Text(
        badgeText,
        style: const TextStyle(
          color: Color(0xFF40220F),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: button,
    );
  }
}

class Constants {
  static final Color primaryColor = Color.fromRGBO(86, 215, 188, 1);
  static final Color scaffoldBackgroundColor = Color.fromRGBO(245, 247, 249, 1);
}
