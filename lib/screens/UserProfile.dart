import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/wellness_provider.dart';
import 'package:higherground/screens/UpdateProfile.dart';
import 'package:higherground/screens/WellnessScreen.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  static const routeName = "/UserProfile";
  const UserProfile({Key? key, this.userdata}) : super(key: key);
  final Userdata? userdata;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Userdata get u => widget.userdata!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = widget.userdata?.email ?? '';
      if (mounted && email.isNotEmpty) {
        context.read<WellnessProvider>().load(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Wellness summary card ──────────────────────────
                  const SizedBox(height: 20),
                  _WellnessSummaryCard(email: u.email ?? ''),

                  // ── Personal info ──────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionLabel('PERSONAL INFORMATION'),
                  const SizedBox(height: 8),
                  _InfoGroup(children: [
                    _InfoTile(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF6366f1),
                      iconBg: const Color(0xFFe0e7ff),
                      label: t.fullname,
                      value: '${u.firstname?.toTitleCase() ?? ''} ${u.lastname?.toTitleCase() ?? ''}'.trim(),
                    ),
                    _InfoTile(
                      icon: FontAwesomeIcons.venusMars.data,
                      iconColor: const Color(0xFF8b5cf6),
                      iconBg: const Color(0xFFede9fe),
                      label: t.gender,
                      value: u.gender,
                    ),
                    _InfoTile(
                      icon: FontAwesomeIcons.cakeCandles.data,
                      iconColor: const Color(0xFFec4899),
                      iconBg: const Color(0xFFfce7f3),
                      label: t.dateofbirth,
                      value: u.dob,
                      isLast: true,
                    ),
                  ]),

                  // ── Contact ────────────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionLabel('CONTACT'),
                  const SizedBox(height: 8),
                  _InfoGroup(children: [
                    _InfoTile(
                      icon: Icons.email_rounded,
                      iconColor: const Color(0xFF0ea5e9),
                      iconBg: const Color(0xFFe0f2fe),
                      label: t.emailaddress,
                      value: u.email,
                    ),
                    _InfoTile(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF10b981),
                      iconBg: const Color(0xFFd1fae5),
                      label: t.phonenumber,
                      value: u.phonenumber,
                    ),
                    _InfoTile(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFFf59e0b),
                      iconBg: const Color(0xFFFEF3C7),
                      label: t.address,
                      value: u.address,
                      isLast: true,
                    ),
                  ]),

                  // ── Work & Bio ─────────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionLabel('WORK & BIO'),
                  const SizedBox(height: 8),
                  _InfoGroup(children: [
                    _InfoTile(
                      icon: Icons.work_rounded,
                      iconColor: const Color(0xFF6366f1),
                      iconBg: const Color(0xFFe0e7ff),
                      label: t.occupation,
                      value: u.occupation,
                    ),
                    _InfoTile(
                      icon: Icons.notes_rounded,
                      iconColor: const Color(0xFF64748b),
                      iconBg: const Color(0xFFf1f5f9),
                      label: t.aboutme,
                      value: (u.aboutme ?? '').isEmpty
                          ? null
                          : Utility.getBase64DecodedString(u.aboutme!),
                      isLast: true,
                      multiLine: true,
                    ),
                  ]),

                  // ── Social links ───────────────────────────────────
                  if (_hasSocials()) ...[
                    const SizedBox(height: 24),
                    _SectionLabel('SOCIAL'),
                    const SizedBox(height: 8),
                    _InfoGroup(children: [
                      if ((u.facebook ?? '').isNotEmpty)
                        _InfoTile(
                          icon: FontAwesomeIcons.facebook.data,
                          iconColor: const Color(0xFF1877F2),
                          iconBg: const Color(0xFFdbeafe),
                          label: t.facebookpage,
                          value: u.facebook,
                          isLink: true,
                          isLast: (u.twitter ?? '').isEmpty &&
                              (u.linkedln ?? '').isEmpty,
                        ),
                      if ((u.twitter ?? '').isNotEmpty)
                        _InfoTile(
                          icon: FontAwesomeIcons.xTwitter.data,
                          iconColor: const Color(0xFF000000),
                          iconBg: const Color(0xFFf1f5f9),
                          label: t.twitterpage,
                          value: u.twitter,
                          isLink: true,
                          isLast: (u.linkedln ?? '').isEmpty,
                        ),
                      if ((u.linkedln ?? '').isNotEmpty)
                        _InfoTile(
                          icon: FontAwesomeIcons.linkedin.data,
                          iconColor: const Color(0xFF0A66C2),
                          iconBg: const Color(0xFFdbeafe),
                          label: t.linkdln,
                          value: u.linkedln,
                          isLink: true,
                          isLast: true,
                        ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSocials() =>
      (u.facebook ?? '').isNotEmpty ||
      (u.twitter ?? '').isNotEmpty ||
      (u.linkedln ?? '').isNotEmpty;

  Widget _buildSliverHeader(BuildContext context) {
    final String fullName =
        '${u.firstname?.toTitleCase() ?? ''} ${u.lastname?.toTitleCase() ?? ''}'.trim();

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      backgroundColor: MyColors.navBackground,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LineAwesomeIcons.edit_1,
                  color: Colors.white, size: 18),
            ),
            onPressed: () => Navigator.of(context).pushReplacementNamed(
              UpdateProfile.routeName,
              arguments: widget.userdata,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            _CoverPhoto(url: u.coverphoto),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Avatar + name anchored at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ProfileAvatar(url: u.photo),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Member' : fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Color(0x88000000),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        if ((u.email ?? '').isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            u.email!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover photo
// ─────────────────────────────────────────────────────────────────────────────

class _CoverPhoto extends StatelessWidget {
  final String? url;
  const _CoverPhoto({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e0a3c), Color(0xFF4f46e5), Color(0xFF0d1117)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  final String? url;
  const _ProfileAvatar({this.url});

  @override
  Widget build(BuildContext context) {
    final Widget inner = (url != null && url!.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, __) => _icon(),
            errorWidget: (_, __, ___) => _icon(),
          )
        : _icon();

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: inner,
      ),
    );
  }

  Widget _icon() => Container(
        color: const Color(0xFF4f46e5),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6366f1),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Info group container
// ─────────────────────────────────────────────────────────────────────────────

class _InfoGroup extends StatelessWidget {
  final List<Widget> children;
  const _InfoGroup({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// Info tile
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Wellness summary card
// ─────────────────────────────────────────────────────────────────────────────

class _WellnessSummaryCard extends StatelessWidget {
  final String email;
  const _WellnessSummaryCard({required this.email});

  static Color _gradeColor(String grade) {
    switch (grade) {
      case 'high':   return const Color(0xFF10b981);
      case 'medium': return const Color(0xFF3b82f6);
      case 'low':    return const Color(0xFFf59e0b);
      default:       return const Color(0xFF8b5cf6);
    }
  }

  static String _gradeLabel(String grade) {
    switch (grade) {
      case 'high':   return 'Active Member';
      case 'medium': return 'Growing';
      case 'low':    return 'Developing';
      default:       return 'Getting Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessProvider>(
      builder: (ctx, prov, _) {
        final profile = prov.profile;

        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            WellnessScreen.routeName,
            arguments: email,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
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
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfce7f3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Color(0xFFec4899), size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Spiritual Wellness',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0f172a),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (prov.loading && profile == null)
                        Container(
                          width: 100,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFFe2e8f0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                      else if (profile != null)
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Tap to view your wellness',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94a3b8)),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF94a3b8), size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info tile
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? value;
  final bool isLast;
  final bool isLink;
  final bool multiLine;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.value,
    this.isLast = false,
    this.isLink = false,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final String display =
        (value == null || value!.trim().isEmpty) ? '—' : value!.trim();
    final bool empty = display == '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment:
                multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      display,
                      style: TextStyle(
                        color: empty
                            ? const Color(0xFFcbd5e1)
                            : isLink
                                ? MyColors.primary
                                : const Color(0xFF0f172a),
                        fontSize: 14,
                        fontWeight:
                            empty ? FontWeight.w400 : FontWeight.w500,
                        height: multiLine ? 1.4 : 1.0,
                        decoration: isLink && !empty
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: MyColors.primary,
                      ),
                      maxLines: multiLine ? 5 : 1,
                      overflow: multiLine
                          ? TextOverflow.fade
                          : TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 0,
            color: Color(0xFFf1f5f9),
          ),
      ],
    );
  }
}
