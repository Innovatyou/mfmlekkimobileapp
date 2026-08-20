import 'dart:convert';

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
import 'package:higherground/screens/CounselingScreen.dart';
import 'package:higherground/screens/WellnessScreen.dart';
import 'package:higherground/screens/MarketplaceBrowseScreen.dart';
import 'package:higherground/screens/PartnershipScreen.dart';
import 'package:higherground/screens/EventsListScreen.dart';
import 'package:higherground/screens/EventsViewerScreen.dart';
import 'package:higherground/screens/HymnsListScreen.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/SearchScreen.dart';
import 'package:higherground/screens/DonateScreen.dart';
import 'package:higherground/screens/VideoScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/langs.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  DashboardScreenRouteState createState() => DashboardScreenRouteState();
}

class DashboardScreenRouteState extends State<DashboardScreen> {
  late DashboardModel dashboardModel;
  late AppStateManager appStateManager;
  Set<String> _hiddenDashboardItems = {};
  Map<String, String> _dashboardLabels = {};
  Map<String, List<String>> _dashboardOrder = {};
  final PageController _advertController = PageController();
  bool _advertDismissed = false;
  int _advertIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardPreferences();
  }

  @override
  void dispose() {
    _advertController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hiddenDashboardItems =
          (prefs.getStringList('dashboard_hidden_items') ?? []).toSet();
      final stored = prefs.getString('dashboard_labels');
      _dashboardLabels = stored == null
          ? {}
          : Map<String, String>.from(jsonDecode(stored) as Map);
      final order = prefs.getString('dashboard_order');
      if (order != null) {
        final decoded = Map<String, dynamic>.from(jsonDecode(order) as Map);
        _dashboardOrder = decoded.map(
            (key, value) => MapEntry(key, List<String>.from(value as List)));
      }
    });
  }

  Future<void> _saveDashboardPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'dashboard_hidden_items', _hiddenDashboardItems.toList());
    await prefs.setString('dashboard_labels', jsonEncode(_dashboardLabels));
    await prefs.setString('dashboard_order', jsonEncode(_dashboardOrder));
  }

  String _label(String value) => _dashboardLabels[value] ?? value;

  List<_DashboardAction> _ordered(
      String section, List<_DashboardAction> actions) {
    final order = _dashboardOrder[section] ?? [];
    actions.sort((left, right) {
      final leftIndex = order.indexOf(left.title);
      final rightIndex = order.indexOf(right.title);
      return (leftIndex < 0 ? 999 : leftIndex)
          .compareTo(rightIndex < 0 ? 999 : rightIndex);
    });
    return actions;
  }

  List<_DashboardAction> _visible(
          String section, List<_DashboardAction> actions) =>
      _ordered(section, actions)
          .where((action) =>
              !_hiddenDashboardItems.contains('$section:${action.title}'))
          .toList();

  String getHeader() {
    Userdata? userdata = appStateManager.userdata;
    if (userdata == null) {
      return 'Hi Friend,';
    }
    final firstName = userdata.firstname?.trim() ?? '';
    if (firstName.isEmpty) {
      return 'Hi Friend,';
    }
    return 'Hi ${firstName.toCapitalized()},';
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
    if (dashboardModel.data['mobile_app_enabled'] == false) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mobile_off_rounded, size: 64),
              SizedBox(height: 16),
              Text('Mobile app temporarily unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Please check back later.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    final double width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 720;
    final double quickActionWidth =
        isWide ? (width - 56) / 3 : (width - 44) / 2;
    final double serviceWidth = isWide ? (width - 56) / 2 : width - 32;

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: dashboardModel.brandingColor(
                'mobile_background_color', const Color(0xFFf0f2f5)),
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
                    _label('Quick Access'),
                    'Jump straight into today\'s most-used church tools.',
                    onEdit: () => _showDashboardEditor('quick'),
                  ),
                  const SizedBox(height: 14),
                  _buildCommunityRow(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _visible('quick', _buildQuickActions())
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
                    _label('Grow This Week'),
                    'Worship, study, and stay connected from one place.',
                    onEdit: () => _showDashboardEditor('grow'),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _visible('grow', _buildServiceActions())
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
        ),
        if (!_advertDismissed && dashboardModel.mobileAdverts.isNotEmpty)
          Positioned.fill(child: _buildAdvertOverlay()),
      ],
    );
  }

  Widget _buildAdvertOverlay() {
    final adverts = dashboardModel.mobileAdverts;
    final primary = dashboardModel.brandingColor(
        'mobile_primary_color', MyColors.mainC0lor);
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.66),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Material(
                color: Colors.white,
                elevation: 24,
                borderRadius: BorderRadius.circular(26),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 5,
                      child: PageView.builder(
                        controller: _advertController,
                        itemCount: adverts.length,
                        onPageChanged: (index) =>
                            setState(() => _advertIndex = index),
                        itemBuilder: (context, index) {
                          final advert = adverts[index];
                          final link = advert['link']?.toString() ?? '';
                          return InkWell(
                            onTap: link.isEmpty
                                ? null
                                : () => Utility.openBrowserTab(link,
                                    context: context,
                                    title: advert['title']?.toString() ??
                                        'Advert'),
                            child: CachedNetworkImage(
                              imageUrl: advert['image']?.toString() ?? '',
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Center(
                                  child: CircularProgressIndicator(
                                      color: primary)),
                              errorWidget: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      size: 52)),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.62)),
                        color: Colors.white,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () =>
                            setState(() => _advertDismissed = true),
                      ),
                    ),
                    if (adverts.length > 1)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            adverts.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: index == _advertIndex ? 22 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: index == _advertIndex
                                    ? primary
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
            dashboardModel.brandingColor(
                'mobile_primary_color', MyColors.primaryDark),
            dashboardModel.brandingColor(
                'mobile_primary_color', MyColors.mainC0lor),
            dashboardModel.brandingColor(
                'mobile_accent_color', MyColors.primaryLight),
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
            border: Border.all(color: MyColors.border),
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
                        color: Color(0xFF0f172a),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.searchmessagesbooks,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF475569),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle,
      {VoidCallback? onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0f172a),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          )),
          if (onEdit != null)
            IconButton(onPressed: onEdit, icon: const Icon(Icons.tune_rounded))
        ]),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF475569),
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
                _label(action.title),
                style: const TextStyle(
                  color: Color(0xFF0f172a),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                action.description,
                style: const TextStyle(
                  color: Color(0xFF475569),
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
                                  color: MyColors.primaryVeryLight,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    LineAwesomeIcons.calendar,
                                    color: MyColors.primary,
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
                                      color: Color(0xFF475569),
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
                                    color: MyColors.primary,
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
                                  color: Color(0xFF0f172a),
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
                                    color: Color(0xFF475569),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'View details',
                                    style: TextStyle(
                                      color: Color(0xFF475569),
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
                        color: Color(0xFF0f172a),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.description,
                      style: const TextStyle(
                        color: Color(0xFF475569),
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
                color: Color(0xFF475569),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Community first row ─────────────────────────────────────────────────────

  Widget _buildCommunityRow() {
    final tiles = <Widget>[];

    if (dashboardModel.isFeatureAvailable('counseling'))
      tiles.add(_CommunityTile(
        icon: Icons.lock_rounded,
        label: 'Counseling',
        description: 'Request private pastoral support & guidance.',
        color: const Color(0xFF6366f1),
        bg: const Color(0xFFe0e7ff),
        onTap: () =>
            Navigator.of(context).pushNamed(CounselingScreen.routeName),
      ));

    if (dashboardModel.isFeatureAvailable('partnership'))
      tiles.add(_CommunityTile(
        icon: Icons.handshake_rounded,
        label: 'Partnership',
        description: 'Pledge your commitment to advance the Kingdom.',
        color: const Color(0xFF10b981),
        bg: const Color(0xFFD1FAE5),
        onTap: () =>
            Navigator.of(context).pushNamed(PartnershipScreen.routeName),
      ));

    if (dashboardModel.isFeatureAvailable('wellness'))
      tiles.add(_CommunityTile(
        icon: Icons.favorite_rounded,
        label: 'My Wellness',
        description: 'Check your spiritual engagement score and care history.',
        color: const Color(0xFF8b5cf6),
        bg: const Color(0xFFEDE9FE),
        onTap: () {
          final email = appStateManager.userdata?.email ?? '';
          if (email.isEmpty) {
            Navigator.of(context).pushNamed('/AuthPage', arguments: true);
            return;
          }
          Navigator.of(context)
              .pushNamed(WellnessScreen.routeName, arguments: email);
        },
      ));

    return Row(
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: tiles[i]),
        ],
      ],
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
          color: const Color(0xFF6366f1),
          borderColor: const Color(0xFFe0e7ff),
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
          color: const Color(0xFF6366f1),
          borderColor: const Color(0xFFe0e7ff),
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
          color: const Color(0xFF6366f1),
          borderColor: const Color(0xFFe0e7ff),
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

    if (dashboardModel.isFeatureAvailable('marketplace'))
      actions.add(
        _DashboardAction(
          icon: Icons.storefront_outlined,
          title: 'Marketplace',
          description:
              'Buy, sell, and give away items within the church family.',
          color: const Color(0xFF8B5CF6),
          borderColor: const Color(0xFFEDE9FE),
          onTap: () {
            Navigator.of(context).pushNamed(MarketplaceBrowseScreen.routeName);
          },
        ),
      );

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
          color: const Color(0xFF6366f1),
          borderColor: const Color(0xFFe0e7ff),
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

    if (dashboardModel.isFeatureAvailable('devotionals')) {
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

  Future<void> _showDashboardEditor(String section) async {
    final actions = _ordered(section,
        section == 'quick' ? _buildQuickActions() : _buildServiceActions());
    final sectionName = section == 'quick' ? 'Quick Access' : 'Grow This Week';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Customize ${_label(sectionName)}'),
          content: SizedBox(
            width: 420,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.title_rounded),
                  title: Text(_label(sectionName)),
                  subtitle: const Text('Rename section'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () =>
                      _renameDashboardText(sectionName, setDialogState),
                ),
                const Divider(),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: actions.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final moved = actions.removeAt(oldIndex);
                    actions.insert(newIndex, moved);
                    _dashboardOrder[section] =
                        actions.map((action) => action.title).toList();
                    setState(() {});
                    setDialogState(() {});
                    _saveDashboardPreferences();
                  },
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    final key = '$section:${action.title}';
                    final visible = !_hiddenDashboardItems.contains(key);
                    return ListTile(
                      key: ValueKey(key),
                      leading: Checkbox(
                        value: visible,
                        onChanged: (value) {
                          setState(() {
                            value == true
                                ? _hiddenDashboardItems.remove(key)
                                : _hiddenDashboardItems.add(key);
                          });
                          setDialogState(() {});
                          _saveDashboardPreferences();
                        },
                      ),
                      title: Text(_label(action.title)),
                      subtitle: Text(visible ? 'Shown' : 'Hidden'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _renameDashboardText(
                                action.title, setDialogState),
                          ),
                          const Icon(Icons.drag_handle_rounded),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameDashboardText(
      String original, StateSetter setDialogState) async {
    final controller = TextEditingController(text: _label(original));
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Display name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.isEmpty) return;
    setState(() => _dashboardLabels[original] = value);
    setDialogState(() {});
    await _saveDashboardPreferences();
  }

  void _openDonation() {
    final donationsLink = dashboardModel.data['donations_link'];
    final String url =
        (donationsLink != null && donationsLink.toString().isNotEmpty)
            ? donationsLink.toString()
            : ApiUrl.DONATE;
    Navigator.of(context).pushNamed(DonateScreen.routeName, arguments: url);
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

class _CommunityTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: bg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0f172a),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
