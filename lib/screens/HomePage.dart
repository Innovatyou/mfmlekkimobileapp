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
import 'package:higherground/screens/DrawerView.dart';
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

  List<_HomeTab> _buildTabs(DashboardModel model) {
    final tabs = <_HomeTab>[];
    tabs.add(_HomeTab(
      icon: LineAwesomeIcons.home,
      label: model.data['mobile_app_name']?.toString().isNotEmpty == true
          ? model.data['mobile_app_name'].toString()
          : t.appname,
      builder: () => DashboardScreen(),
    ));
    tabs.add(_HomeTab(
      icon: LineAwesomeIcons.play_circle,
      label: t.media,
      builder: () => MediaPage(),
    ));
    if (model.isFeatureAvailable("publications")) {
      tabs.add(_HomeTab(
        icon: LineAwesomeIcons.blog,
        label: t.publications,
        builder: () => PublicationsPage(),
      ));
    }
    tabs.add(_HomeTab(
      icon: LineAwesomeIcons.alternate_share,
      label: t.connect,
      builder: () => ConnectPage(),
    ));
    if (model.isFeatureAvailable("gosocial")) {
      tabs.add(_HomeTab(
        icon: LineAwesomeIcons.teamspeak,
        label: t.posts,
        builder: () => UserPostsSection(),
      ));
    }
    return tabs;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppStateManager appManager = Provider.of<AppStateManager>(context);
    dashmodel = Provider.of<DashboardModel>(context);
    Userdata? userdata = appManager.userdata;
    final tabs = _buildTabs(dashmodel);
    final safeIndex = currentIndex.clamp(0, tabs.length - 1);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: MyColors.surface,
      endDrawer: const DrawerView(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tabs[safeIndex].label,
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
        backgroundColor: dashmodel.brandingColor(
            'mobile_primary_color', MyColors.navBackground),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        elevation: 0,
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
              icon: appManager.darkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              onPressed: appManager.toggleDarkMode,
            ),
          ),
          const SizedBox(width: 10),
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
            padding: const EdgeInsets.symmetric(vertical: 12),
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
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, right: 16),
            child: _buildChromeButton(
              icon: Icons.menu_rounded,
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tabs[safeIndex].builder(),
          ),
          MiniPlayer(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dashmodel.brandingColor(
                'mobile_primary_color', MyColors.navBackground),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MyColors.navBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SnakeNavigationBar.color(
            backgroundColor: Colors.transparent,
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.indicator,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            snakeViewColor: dashmodel
                .brandingColor('mobile_accent_color', MyColors.primary)
                .withValues(alpha: 0.20),
            selectedItemColor: dashmodel.brandingColor(
                'mobile_accent_color', MyColors.primary),
            unselectedItemColor: const Color(0xFF6b7280),
            showUnselectedLabels: false,
            showSelectedLabels: false,
            currentIndex: safeIndex,
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
