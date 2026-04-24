import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/bible/BibleScreen.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/notes/NotesListScreen.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/DevotionalsScreen.dart';
import 'package:higherground/screens/EventsListScreen.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/screens/HymnsListScreen.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/SearchScreen.dart';
import 'package:higherground/screens/VideoScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/langs.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenRouteState createState() => DashboardScreenRouteState();
}

class DashboardScreenRouteState extends State<DashboardScreen> {
  late DashboardModel dashboardModel;
  late AppStateManager appStateManager;

  String getHeader() {
    Userdata? userdata = appStateManager.userdata;
    if (userdata == null) {
      return 'Hi Friend,';
    }
    return 'Hi ${userdata.firstname!.toCapitalized()},';
  }

  String greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);
    appStateManager = Provider.of<AppStateManager>(context);
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 720;
    final double quickActionWidth =
        isWide ? (width - 56) / 3 : (width - 44) / 2;
    final double serviceWidth = isWide ? (width - 56) / 2 : width - 32;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F1F4),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 20),
              if (dashboardModel.isFeatureAvailable('media')) ...[
                _buildSearchCard(),
                const SizedBox(height: 20),
              ],
              _buildSectionHeader(
                'Quick Access',
                'Jump straight into today\'s most-used church tools.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildQuickActions()
                    .map(
                      (action) => SizedBox(
                        width: quickActionWidth,
                        child: _buildActionCard(action),
                      ),
                    )
                    .toList(),
              ),
              if (dashboardModel.isFeatureAvailable('events') &&
                  dashboardModel.upcomingevents.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildSectionHeader(
                  t.upcomingevents,
                  'See what is coming up and plan your next moment of fellowship.',
                ),
                const SizedBox(height: 14),
                _buildUpcomingEvents(),
              ],
              const SizedBox(height: 28),
              _buildSectionHeader(
                'Grow This Week',
                'Worship, study, and stay connected from one place.',
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildServiceActions()
                    .map(
                      (action) => SizedBox(
                        width: serviceWidth,
                        child: _buildServiceCard(action),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            MyColors.primaryDark,
            MyColors.mainC0lor,
            const Color(0xFFC04B86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.primaryDark.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${greeting()}  •  Welcome Home',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            getHeader(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your church life is organized here: worship live, revisit messages, study scripture, and stay in step with the community.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildHeroButton(
                icon: LineAwesomeIcons.youtube,
                label: 'Join Live Service',
                isPrimary: true,
                onTap: () {
                  Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
                },
              ),
              _buildHeroButton(
                icon: LineAwesomeIcons.bible,
                label: t.bible,
                isPrimary: false,
                onTap: _openBible,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final Color foreground = isPrimary ? MyColors.primaryDark : Colors.white;

    return Material(
      color: isPrimary
          ? const Color(0xFFFFD88E)
          : Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).pushNamed(SearchScreen.routeName);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE6D7E0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: MyColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LineAwesomeIcons.search,
                  color: MyColors.mainC0lor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search messages, books, and resources',
                      style: TextStyle(
                        color: Color(0xFF23141D),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.searchmessagesbooks,
                      style: const TextStyle(
                        color: Color(0xFF7A6B75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF7A6B75),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF23141D),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A6B75),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(_DashboardAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: action.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(height: 18),
              Text(
                action.title,
                style: const TextStyle(
                  color: Color(0xFF23141D),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action.description,
                style: const TextStyle(
                  color: Color(0xFF7A6B75),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return SizedBox(
      height: 258,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dashboardModel.upcomingevents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final media = dashboardModel.upcomingevents[index];
          return SizedBox(
            width: 280,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    EventsViewerScreen.routeName,
                    arguments: ScreenArguements(
                      position: 0,
                      items: media,
                      itemsList: [],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: SizedBox(
                          height: 156,
                          width: double.infinity,
                          child: media.thumbnail == null ||
                                  media.thumbnail!.isEmpty
                              ? Container(
                                  color: const Color(0xFFF1E4EA),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    LineAwesomeIcons.calendar,
                                    color: MyColors.mainC0lor,
                                    size: 42,
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: media.thumbnail!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: const Color(0xFFF1E4EA),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Color(0xFF7A6B75),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.primaryVeryLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Upcoming Event',
                                  style: TextStyle(
                                    color: MyColors.mainC0lor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                media.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF23141D),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Color(0xFF7A6B75),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'View details',
                                    style: TextStyle(
                                      color: Color(0xFF7A6B75),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(_DashboardAction action) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8DDE4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: Color(0xFF23141D),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: const TextStyle(
                        color: Color(0xFF7A6B75),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF7A6B75),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_DashboardAction> _buildQuickActions() {
    final List<_DashboardAction> actions = [];

    if (dashboardModel.isFeatureAvailable('events')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.calendar,
          title: t.events,
          description:
              'Track services, programs, and upcoming church gatherings.',
          color: const Color(0xFFB2436D),
          borderColor: const Color(0xFFF0D8E2),
          onTap: () {
            Navigator.of(context).pushNamed(EventsListScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('notes')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.sticky_note,
          title: t.notes,
          description:
              'Capture message insights and revisit your personal reflections.',
          color: const Color(0xFF5A4BCF),
          borderColor: const Color(0xFFE3E0FA),
          onTap: () {
            Navigator.of(context).pushNamed(NotesListScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('bible')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.bible,
          title: t.bible,
          description: 'Open scripture quickly and continue your daily study.',
          color: const Color(0xFF8F3E88),
          borderColor: const Color(0xFFECDCF0),
          onTap: _openBible,
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('hymns')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.music,
          title: t.hymns,
          description: 'Sing to God and keep songs of faith close at hand.',
          color: const Color(0xFF0F8D97),
          borderColor: const Color(0xFFD5EFF1),
          onTap: () {
            Navigator.of(context).pushNamed(HymnsListScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('video')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.play_circle,
          title: t.videos,
          description: 'Watch inspiring and uplifting video content anytime.',
          color: const Color(0xFFF97316),
          borderColor: const Color(0xFFFEEAD9),
          onTap: () {
            Navigator.of(context).pushNamed(VideoScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('donations')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.donate,
          title: t.donate,
          description:
              'Give securely and support ongoing ministry initiatives.',
          color: const Color(0xFF1E8B72),
          borderColor: const Color(0xFFD7EFE8),
          onTap: _openDonation,
        ),
      );
    }

    return actions;
  }

  List<_DashboardAction> _buildServiceActions() {
    final List<_DashboardAction> actions = [];

    if (dashboardModel.isFeatureAvailable('bible')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.bible,
          title: t.bible,
          description: 'Dig deep into God\'s word and study at your own pace.',
          color: const Color(0xFF8F3E88),
          borderColor: const Color(0xFFECDCF0),
          onTap: _openBible,
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('livestreams')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.youtube,
          title: t.livestreams,
          description: t.livestreamshint,
          color: const Color(0xFFD24F45),
          borderColor: const Color(0xFFF5DDDB),
          onTap: () {
            Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('donations')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.book_reader,
          title: t.devotionals,
          description: t.devotionalshint,
          color: const Color(0xFFB06B1B),
          borderColor: const Color(0xFFF7E7CB),
          onTap: () {
            Navigator.of(context).pushNamed(DevotionalsScreen.routeName);
          },
        ),
      );
    }

    if (dashboardModel.isFeatureAvailable('hymns')) {
      actions.add(
        _DashboardAction(
          icon: LineAwesomeIcons.music,
          title: t.hymns,
          description: 'Sing to God and keep songs of faith close at hand.',
          color: const Color(0xFF0F8D97),
          borderColor: const Color(0xFFD5EFF1),
          onTap: () {
            Navigator.of(context).pushNamed(HymnsListScreen.routeName);
          },
        ),
      );
    }

    return actions;
  }

  void _openDonation() {
    final donationsLink = dashboardModel.data['donations_link'];
    final String linkStr =
        donationsLink != null ? donationsLink.toString() : '';
    if (linkStr.isEmpty) {
      Utility.openBrowserTab(ApiUrl.DONATE, context: context, title: t.donate);
    } else {
      Utility.openBrowserTab(linkStr, context: context, title: t.donate);
    }
  }

  void _openBible() {
    if (appStateManager.youversionbible) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: SizedBox(
              width: 180,
              child: Text(
                t.readbiblein,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            content: SizedBox(
              height: 250,
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appLanguageData.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(
                      appLanguageData[AppLanguage.values[index]]!['name']!,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      switch (index) {
                        case 0:
                          Utility.openBrowserTab(
                            ApiUrl.YOUVERSIONBIBLE_ENG,
                            context: context,
                            title: t.bible,
                          );
                          break;
                        case 1:
                          Utility.openBrowserTab(
                            ApiUrl.YOUVERSIONBIBLE_FR,
                            context: context,
                            title: t.bible,
                          );
                          break;
                        case 2:
                          Utility.openBrowserTab(
                            ApiUrl.YOUVERSIONBIBLE_SP,
                            context: context,
                            title: t.bible,
                          );
                          break;
                        case 3:
                          Utility.openBrowserTab(
                            ApiUrl.YOUVERSIONBIBLE_PO,
                            context: context,
                            title: t.bible,
                          );
                          break;
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      );
      return;
    }

    Navigator.of(context).pushNamed(BibleScreen.routeName);
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
}
