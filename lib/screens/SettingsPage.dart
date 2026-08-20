import 'dart:convert';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/UserProfile.dart';
import 'package:higherground/screens/WellnessScreen.dart';
import 'package:higherground/providers/wellness_provider.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:higherground/models/Userdata.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = "/SettingsPage";
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppStateManager appManager;
  Userdata? userdata;
  bool phoneSwitch = false;
  bool dobSwitch = false, followSwitch = false;
  bool commentSwitch = false, likeSwitch = false;
  bool _settingsLoaded = false; // ignore: unused_field

  Future<void> loadItems(Userdata userdata) async {
    try {
      final response = await Utility.getDio().post(
        ApiUrl.fetchUserSettings,
        data: jsonEncode({
          "data": {"email": userdata.email},
        }),
      );
      if (response.statusCode == 200) {
        dynamic res = Utility.decodeResponse(response.data);
        if (res == null || res['user'] == null) return;
        setState(() {
          phoneSwitch = int.parse(res['user']['show_phone'].toString()) == 0;
          dobSwitch =
              int.parse(res['user']['show_dateofbirth'].toString()) == 0;
          followSwitch =
              int.parse(res['user']['notify_follows'].toString()) == 0;
          commentSwitch =
              int.parse(res['user']['notify_comments'].toString()) == 0;
          likeSwitch = int.parse(res['user']['notify_likes'].toString()) == 0;
          _settingsLoaded = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserSettings(Userdata userdata) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      final response = await Utility.getDio().post(
        ApiUrl.updateUserSettings,
        data: jsonEncode({
          "data": {
            "email": userdata.email,
            "show_dateofbirth": dobSwitch ? 0 : 1,
            "show_phone": phoneSwitch ? 0 : 1,
            "notify_follows": followSwitch ? 0 : 1,
            "notify_comments": commentSwitch ? 0 : 1,
            "notify_likes": likeSwitch ? 0 : 1,
          },
        }),
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        Map<String, dynamic> res = Utility.decodeResponse(response.data);
        if (res["status"] == "error") {
          Alerts.show(context, t.error, res["msg"]);
        } else {
          Alerts.show(context, t.success, res["msg"]);
        }
      }
    } catch (e) {
      Navigator.of(context).pop();
      Alerts.show(context, t.error, e.toString());
    }
  }

  Future<void> showLogoutAlert() async {
    return showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(t.logoutfromapp),
        content: Text(t.logoutfromapphint),
        actions: [
          CupertinoDialogAction(
            child: Text(t.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(t.ok),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WellnessProvider>().clear();
              appManager.unsetUserData();
            },
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteAccountAlert() async {
    return showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(t.deleteaccount),
        content: Text(t.deleteaccounthint),
        actions: [
          CupertinoDialogAction(
            child: Text(t.cancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(t.ok),
            onPressed: () {
              Navigator.of(context).pop();
              deleteAccountServer(userdata!.email!);
            },
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccountServer(String email) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      final response = await Utility.getDio().post(
        ApiUrl.DELETE_ACCOUNT,
        data: jsonEncode({
          "data": {"email": email},
        }),
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        Alerts.show(context, "", t.deleteaccountsuccess);
        context.read<WellnessProvider>().clear();
        appManager.unsetUserData();
      } else {
        Alerts.show(context, "", t.cannotprocess);
      }
    } catch (e) {
      Navigator.of(context).pop();
      Alerts.show(context, "", e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = Provider.of<AppStateManager>(
        context,
        listen: false,
      ).userdata;
      if (user != null) {
        loadItems(user);
        if ((user.email ?? '').isNotEmpty) {
          context.read<WellnessProvider>().load(user.email!);
        }
      }
    });
    eventBus.on<UserLoggedInEvent>().listen((event) {
      if (event.user != null) loadItems(event.user!);
    });
  }

  @override
  Widget build(BuildContext context) {
    appManager = Provider.of<AppStateManager>(context);
    userdata = appManager.userdata;
    final dashModel = Provider.of<DashboardModel>(context);
    final website = dashModel.data['website']?.toString() ?? '';
    final background = dashModel.brandingColor(
      'mobile_background_color',
      const Color(0xFFF1F4F9),
    );
    final primary = dashModel.brandingColor(
      'mobile_primary_color',
      MyColors.mainC0lor,
    );

    return Scaffold(
      backgroundColor: background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileCard(
                    userdata: userdata,
                    onTapProfile: () {
                      if (userdata != null) {
                        Navigator.of(
                          context,
                        ).pushNamed(UserProfile.routeName, arguments: userdata);
                      } else {
                        Navigator.of(
                          context,
                        ).pushNamed(AuthPage.routeName, arguments: true);
                      }
                    },
                  ),
                  if (userdata != null) ...[
                    if (dashModel.isFeatureAvailable('wellness')) ...[
                      const SizedBox(height: 16),
                      _WellnessTile(email: userdata!.email ?? ''),
                    ],
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SettingsTile(
                          icon: LineAwesomeIcons.alternate_sign_out,
                          iconColor: const Color(0xFFf59e0b),
                          iconBg: const Color(0xFFFEF3C7),
                          title: t.logoutfromapp,
                          onTap: showLogoutAlert,
                        ),
                        _SettingsTile(
                          icon: LineAwesomeIcons.remove_user,
                          iconColor: const Color(0xFFef4444),
                          iconBg: const Color(0xFFFEE2E2),
                          title: t.deletemyaccount,
                          titleColor: const Color(0xFFef4444),
                          isLast: true,
                          onTap: showDeleteAccountAlert,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'PRIVACY'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SwitchTile(
                          icon: LineAwesomeIcons.phone,
                          iconColor: primary,
                          iconBg: primary.withValues(alpha: 0.12),
                          title: t.phonenumber,
                          subtitle: t.showmyphonenumber,
                          value: phoneSwitch,
                          onChanged: (v) => setState(() => phoneSwitch = v),
                        ),
                        _SwitchTile(
                          icon: LineAwesomeIcons.birthday_cake,
                          iconColor: const Color(0xFF8b5cf6),
                          iconBg: const Color(0xFFede9fe),
                          title: t.dateofbirth,
                          subtitle: t.showmyfulldateofbirth,
                          value: dobSwitch,
                          isLast: true,
                          onChanged: (v) => setState(() => dobSwitch = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'NOTIFICATIONS'),
                    const SizedBox(height: 8),
                    _SettingsGroup(
                      children: [
                        _SwitchTile(
                          icon: LineAwesomeIcons.comment,
                          iconColor: const Color(0xFF0ea5e9),
                          iconBg: const Color(0xFFe0f2fe),
                          title: t.notifymewhenusercommentsonmypost,
                          value: commentSwitch,
                          onChanged: (v) => setState(() => commentSwitch = v),
                        ),
                        _SwitchTile(
                          icon: LineAwesomeIcons.heart,
                          iconColor: const Color(0xFFec4899),
                          iconBg: const Color(0xFFfce7f3),
                          title: t.notifymewhenuserlikesmypost,
                          value: likeSwitch,
                          isLast: true,
                          onChanged: (v) => setState(() => likeSwitch = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => updateUserSettings(userdata!),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(t.update),
                        style: FilledButton.styleFrom(
                          backgroundColor: dashModel.brandingColor(
                            'mobile_primary_color',
                            MyColors.mainC0lor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _SectionLabel(label: 'APP EXPERIENCE'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SwitchTile(
                        icon: LineAwesomeIcons.bible,
                        iconColor: primary,
                        iconBg: primary.withValues(alpha: 0.12),
                        title: t.youversionbible.trim().isEmpty
                            ? 'You version Bible Reader'
                            : t.youversionbible,
                        subtitle:
                            'Launch verses in You version for a smoother reading flow.',
                        value: appManager.youversionbible,
                        isLast: true,
                        onChanged: (v) =>
                            appManager.setYouVersionBiblePreference(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: 'INFORMATION'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      if (website.isNotEmpty)
                        _SettingsTile(
                          icon: LineAwesomeIcons.chrome,
                          iconColor: const Color(0xFF10b981),
                          iconBg: const Color(0xFFd1fae5),
                          title: t.website,
                          onTap: () => Utility.openBrowserTab(
                            website,
                            context: context,
                            title: t.website,
                          ),
                        ),
                      _SettingsTile(
                        icon: LineAwesomeIcons.tags,
                        iconColor: primary,
                        iconBg: primary.withValues(alpha: 0.12),
                        title: t.terms,
                        onTap: () => Utility.openBrowserTab(
                          ApiUrl.TERMS,
                          context: context,
                          title: t.terms,
                        ),
                      ),
                      _SettingsTile(
                        icon: LineAwesomeIcons.th_list,
                        iconColor: const Color(0xFF0ea5e9),
                        iconBg: const Color(0xFFe0f2fe),
                        title: t.privacy,
                        onTap: () => Utility.openBrowserTab(
                          ApiUrl.PRIVACY,
                          context: context,
                          title: t.privacy,
                        ),
                      ),
                      _SettingsTile(
                        icon: LineAwesomeIcons.info,
                        iconColor: const Color(0xFF8b5cf6),
                        iconBg: const Color(0xFFede9fe),
                        title: t.about,
                        onTap: () => Utility.openBrowserTab(
                          ApiUrl.ABOUT,
                          context: context,
                          title: t.about,
                        ),
                      ),
                      _SettingsTile(
                        icon: LineAwesomeIcons.app_store,
                        iconColor: const Color(0xFF0ea5e9),
                        iconBg: const Color(0xFFe0f2fe),
                        title: t.rateapp,
                        isLast: true,
                        onTap: () => Utility.openBrowserTab(
                          "https://play.google.com/store/apps/details?id=org.mfmlekki.app",
                          context: context,
                          title: t.rateapp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${t.appname}  •  v${appManager.version}',
                      style: const TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final dashboard = Provider.of<DashboardModel>(context, listen: false);
    final primary = dashboard.brandingColor(
      'mobile_primary_color',
      MyColors.mainC0lor,
    );
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Text(
          t.appsettings,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        background: ColoredBox(color: primary),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final Userdata? userdata;
  final VoidCallback onTapProfile;

  const _ProfileCard({required this.userdata, required this.onTapProfile});

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardModel>(context);
    final surface = dashboard.brandingColor(
      'mobile_surface_color',
      Colors.white,
    );
    final textColor = dashboard.brandingColor(
      'mobile_text_color',
      const Color(0xFF0f172a),
    );
    final primary = dashboard.brandingColor(
      'mobile_primary_color',
      MyColors.mainC0lor,
    );
    final bool loggedIn = userdata != null;
    final String name = loggedIn
        ? '${userdata!.firstname?.toTitleCase() ?? ''} ${userdata!.lastname?.toTitleCase() ?? ''}'
            .trim()
        : 'Guest';
    final String sub =
        loggedIn ? (userdata!.email ?? '') : 'Sign in to access your account';

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTapProfile,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _Avatar(userdata: userdata),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        style: const TextStyle(
                          color: Color(0xFF64748b),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    loggedIn ? 'View Profile' : 'Sign In',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Userdata? userdata;
  const _Avatar({required this.userdata});

  @override
  Widget build(BuildContext context) {
    if (userdata?.photo != null && userdata!.photo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
          imageUrl: userdata!.photo!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (_, __) => _DefaultAvatar(),
          errorWidget: (_, __, ___) => _DefaultAvatar(),
        ),
      );
    }
    return _DefaultAvatar();
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Provider.of<DashboardModel>(
      context,
    ).brandingColor('mobile_primary_color', MyColors.mainC0lor);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Settings group container
// ─────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final surface = Provider.of<DashboardModel>(
      context,
    ).brandingColor('mobile_surface_color', Colors.white);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Navigation tile
// ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.titleColor,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(16))
                : BorderRadius.zero,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _IconBadge(icon: icon, color: iconColor, bg: iconBg),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? const Color(0xFF0f172a),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: titleColor?.withValues(alpha: 0.5) ??
                        const Color(0xFFcbd5e1),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 58,
            endIndent: 0,
            color: Color(0xFFf1f5f9),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Switch tile
// ─────────────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.value,
    this.isLast = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Provider.of<DashboardModel>(
      context,
    ).brandingColor('mobile_primary_color', MyColors.mainC0lor);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _IconBadge(icon: icon, color: iconColor, bg: iconBg),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0f172a),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: value,
                activeTrackColor: primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 58,
            endIndent: 0,
            color: Color(0xFFf1f5f9),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Icon badge
// ─────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;

  const _IconBadge({required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Wellness tile
// ─────────────────────────────────────────────────────────────

class _WellnessTile extends StatelessWidget {
  final String email;
  const _WellnessTile({required this.email});

  static Color _gradeColor(String grade) {
    switch (grade) {
      case 'high':
        return const Color(0xFF10b981);
      case 'medium':
        return const Color(0xFF3b82f6);
      case 'low':
        return const Color(0xFFf59e0b);
      default:
        return const Color(0xFF8b5cf6);
    }
  }

  static String _gradeLabel(String grade) {
    switch (grade) {
      case 'high':
        return 'Active Member';
      case 'medium':
        return 'Growing';
      case 'low':
        return 'Developing';
      default:
        return 'Getting Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessProvider>(
      builder: (ctx, prov, _) {
        final profile = prov.profile;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(
              context,
            ).pushNamed(WellnessScreen.routeName, arguments: email),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfce7f3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFec4899),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Spiritual Wellness',
                          style: TextStyle(
                            color: Color(0xFF0f172a),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (prov.loading && profile == null)
                          Container(
                            width: 110,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFe2e8f0),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        else if (profile != null)
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _gradeColor(profile.grade),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Score: ${profile.score} · ${_gradeLabel(profile.grade)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748b),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            'View your engagement & care history',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94a3b8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFcbd5e1),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
