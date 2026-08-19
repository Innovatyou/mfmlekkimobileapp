import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/CounselingScreen.dart';
import 'package:higherground/screens/MyPartnershipScreen.dart';
import 'package:higherground/screens/PartnershipScreen.dart';
import 'package:higherground/screens/MarketplaceBrowseScreen.dart';
import 'package:higherground/screens/SettingsPage.dart';
import 'package:higherground/screens/UserProfile.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/widgets/AppLogo.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DrawerView extends StatelessWidget {
  const DrawerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appManager = Provider.of<AppStateManager>(context);
    final Userdata? userdata = appManager.userdata;
    final dashboard = Provider.of<DashboardModel>(context);
    final website = dashboard.data['website']?.toString() ?? '';
    final showMarketplace = dashboard.isFeatureAvailable('marketplace');
    final showCounseling = dashboard.isFeatureAvailable('counseling');
    final showPartnership = dashboard.isFeatureAvailable('partnership');
    final showCommunity = showMarketplace || showCounseling || showPartnership;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0d1117),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Header ──────────────────────────────────────────
                  _DrawerHeader(dashboard: dashboard),

                  // ── User profile row ────────────────────────────────
                  _UserRow(
                    userdata: userdata,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (userdata != null) {
                        Navigator.of(context).pushNamed(
                          UserProfile.routeName,
                          arguments: userdata,
                        );
                      } else {
                        Navigator.of(context).pushNamed(
                          AuthPage.routeName,
                          arguments: true,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Community section ────────────────────────────────
                  if (showCommunity) _SectionLabel('COMMUNITY'),
                  const SizedBox(height: 6),
                  if (showMarketplace) ...[
                    _DrawerTile(
                      icon: Icons.storefront_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBg: const Color(0xFF1e1535),
                      label: 'Church Marketplace',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(MarketplaceBrowseScreen.routeName);
                      },
                    ),
                    _divider(),
                  ],
                  if (showCounseling) ...[
                    _DrawerTile(
                      icon: Icons.lock_rounded,
                      iconColor: const Color(0xFF6366f1),
                      iconBg: const Color(0xFF1a1f3a),
                      label: 'Counseling',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(CounselingScreen.routeName);
                      },
                    ),
                    _divider(),
                  ],
                  if (showPartnership) ...[
                    _DrawerTile(
                      icon: Icons.handshake_rounded,
                      iconColor: const Color(0xFF10b981),
                      iconBg: const Color(0xFF0d2b22),
                      label: 'Partnership',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(PartnershipScreen.routeName);
                      },
                    ),
                    _divider(),
                    _DrawerTile(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFF10b981),
                      iconBg: const Color(0xFF0d2b22),
                      label: 'My Partnerships',
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(MyPartnershipScreen.routeName);
                      },
                    ),
                  ],

                  if (showCommunity) const SizedBox(height: 24),

                  // ── Links section ────────────────────────────────────
                  if (website.isNotEmpty) ...[
                    _SectionLabel('LINKS'),
                    const SizedBox(height: 6),
                    _DrawerTile(
                      icon: LineAwesomeIcons.chrome,
                      iconColor: const Color(0xFF10b981),
                      iconBg: const Color(0xFF0d2b22),
                      label: t.website,
                      onTap: () {
                        Navigator.of(context).pop();
                        Utility.openBrowserTab(website,
                            context: context, title: t.website);
                      },
                    ),
                    _divider(),
                  ] else ...[
                    _SectionLabel('LINKS'),
                    const SizedBox(height: 6),
                  ],
                  _DrawerTile(
                    icon: LineAwesomeIcons.tags,
                    iconColor: const Color(0xFF6366f1),
                    iconBg: const Color(0xFF1a1f3a),
                    label: t.terms,
                    onTap: () {
                      Navigator.of(context).pop();
                      Utility.openBrowserTab(ApiUrl.TERMS,
                          context: context, title: t.terms);
                    },
                  ),
                  _divider(),
                  _DrawerTile(
                    icon: LineAwesomeIcons.th_list,
                    iconColor: const Color(0xFF0ea5e9),
                    iconBg: const Color(0xFF0d1f2d),
                    label: t.privacy,
                    onTap: () {
                      Navigator.of(context).pop();
                      Utility.openBrowserTab(ApiUrl.PRIVACY,
                          context: context, title: t.privacy);
                    },
                  ),
                  _divider(),
                  _DrawerTile(
                    icon: LineAwesomeIcons.info,
                    iconColor: const Color(0xFFf59e0b),
                    iconBg: const Color(0xFF2b1f09),
                    label: t.about,
                    onTap: () {
                      Navigator.of(context).pop();
                      Utility.openBrowserTab(ApiUrl.ABOUT,
                          context: context, title: t.about);
                    },
                  ),
                  _divider(),
                  _DrawerTile(
                    icon: LineAwesomeIcons.app_store,
                    iconColor: const Color(0xFFec4899),
                    iconBg: const Color(0xFF2b0d1a),
                    label: t.rateapp,
                    onTap: () {
                      Navigator.of(context).pop();
                      Utility.openBrowserTab(
                        'https://play.google.com/store/apps/details?id=org.mfmlekki.app',
                        context: context,
                        title: t.rateapp,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Settings ─────────────────────────────────────────
                  _SectionLabel('PREFERENCES'),
                  const SizedBox(height: 6),
                  _DrawerTile(
                    icon: LineAwesomeIcons.cog,
                    iconColor: const Color(0xFF818cf8),
                    iconBg: const Color(0xFF1a1f3a),
                    label: t.appsettings,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(SettingsPage.routeName);
                    },
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0x14ffffff),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '${t.appname}  •  v${appManager.version}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 56),
        color: const Color(0x0Dffffff),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Header with gradient + logo
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  final DashboardModel dashboard;
  const _DrawerHeader({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(24, top + 28, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            dashboard.brandingColor(
                'mobile_header_color', const Color(0xFF4f46e5)),
            dashboard.brandingColor(
                'mobile_primary_color', const Color(0xFF6366f1)),
            const Color(0xFF0d1117),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _brandingLogo(),
          const SizedBox(height: 16),
          Text(
            dashboard.data['mobile_app_name']?.toString().trim().isNotEmpty ==
                    true
                ? dashboard.data['mobile_app_name'].toString()
                : t.appname,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dashboard.data['mobile_tagline']?.toString().trim().isNotEmpty ==
                    true
                ? dashboard.data['mobile_tagline'].toString()
                : 'Towards global evangelism',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandingLogo() {
    final logoUrl = dashboard.data['mobile_logo_url']?.toString().trim() ?? '';
    if (logoUrl.isEmpty) return const AppLogo(size: 62, radius: 18);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: 62,
        height: 62,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => const AppLogo(size: 62, radius: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User profile row
// ─────────────────────────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final Userdata? userdata;
  final VoidCallback onTap;
  const _UserRow({required this.userdata, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = userdata != null;
    final String name = loggedIn
        ? '${userdata!.firstname ?? ''} ${userdata!.lastname ?? ''}'.trim()
        : 'Guest';
    final String sub = loggedIn ? (userdata!.email ?? '') : 'Tap to sign in';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _avatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Guest' : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.25),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    if (userdata?.photo != null && userdata!.photo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: CachedNetworkImage(
          imageUrl: userdata!.photo!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6366f1),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual drawer tile
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: MyColors.primary.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
