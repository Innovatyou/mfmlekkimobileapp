import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/CounselingCase.dart';
import 'package:higherground/models/VideoSession.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/SubmitCounselingScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Platform branding ──────────────────────────────────────────────────────

Color _platformColor(String p) {
  switch (p) {
    case 'zoom':
      return const Color(0xFF2D8CFF);
    case 'google_meet':
      return const Color(0xFF00897B);
    case 'teams':
      return const Color(0xFF6264A7);
    case 'whatsapp':
      return const Color(0xFF25D366);
    default:
      return MyColors.primary;
  }
}

IconData _platformIcon(String p) {
  switch (p) {
    case 'zoom':
      return Icons.videocam_rounded;
    case 'google_meet':
      return Icons.video_call_rounded;
    case 'teams':
      return Icons.groups_rounded;
    case 'whatsapp':
      return Icons.chat_rounded;
    default:
      return Icons.video_camera_front_rounded;
  }
}

String _platformLabel(String p) {
  switch (p) {
    case 'zoom':
      return 'Zoom';
    case 'google_meet':
      return 'Google Meet';
    case 'teams':
      return 'Microsoft Teams';
    case 'whatsapp':
      return 'WhatsApp';
    default:
      return p;
  }
}

// ── Date helpers ───────────────────────────────────────────────────────────

DateTime? _parseScheduledTime(String raw) {
  try {
    return DateTime.parse(raw.replaceAll(' ', 'T'));
  } catch (_) {
    return null;
  }
}

String _formatScheduledTime(DateTime dt) {
  return '${DateFormat('EEE, MMM d').format(dt)} · ${DateFormat('h:mm a').format(dt)}';
}

bool _isSessionToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

// ── Deep link + join ───────────────────────────────────────────────────────

String? _buildZoomDeepLink(String url) {
  try {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final jIdx = segments.indexOf('j');
    if (jIdx < 0 || jIdx + 1 >= segments.length) return null;
    final confno = segments[jIdx + 1];
    final pwd = uri.queryParameters['pwd'];
    var dl = 'zoomus://zoom.us/join?confno=$confno';
    if (pwd != null && pwd.isNotEmpty) dl += '&pwd=$pwd';
    return dl;
  } catch (_) {
    return null;
  }
}

Uri? _buildTeamsDeepLink(String url) {
  try {
    return Uri.parse(
        url.replaceFirst(RegExp(r'https://teams\.microsoft\.com'), 'msteams://'));
  } catch (_) {
    return null;
  }
}

Uri? _buildWhatsappDeepLink(String url) {
  try {
    if (url.contains('wa.me')) {
      final uri = Uri.parse(url);
      final phone =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      if (phone.isEmpty) return null;
      return Uri.parse('whatsapp://send?phone=$phone');
    }
    return Uri.tryParse(url.replaceFirst(RegExp(r'https?://'), 'whatsapp://'));
  } catch (_) {
    return null;
  }
}

Future<void> _joinSession(BuildContext context, VideoSession session) async {
  final link = session.meetingLink;
  if (link.isEmpty) return;
  final platform = session.meetingPlatform;

  Future<void> fallback() => Utility.openBrowserTab(
      link, context: context, title: _platformLabel(platform));

  try {
    if (platform == 'zoom') {
      final dl = _buildZoomDeepLink(link);
      if (dl != null) {
        final uri = Uri.parse(dl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          return;
        }
      }
    } else if (platform == 'teams') {
      final uri = _buildTeamsDeepLink(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    } else if (platform == 'whatsapp') {
      final uri = _buildWhatsappDeepLink(link);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    }
    await fallback();
  } catch (_) {
    await fallback();
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────

class CounselingScreen extends StatefulWidget {
  static const routeName = '/counseling';

  const CounselingScreen({Key? key}) : super(key: key);

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  bool _casesLoading = false;
  bool _casesError = false;
  List<CounselingCase> _cases = [];

  List<VideoSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchAll);
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchCases(), _fetchSessions()]);
  }

  Future<void> _fetchCases() async {
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;
    setState(() {
      _casesLoading = true;
      _casesError = false;
    });
    try {
      final response = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.FETCH_MY_COUNSELING_CASES,
        data: FormData.fromMap({'email': userdata.email ?? ''}),
      );
      debugPrint('[Counseling] fetchCases raw: ${response.data}');
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (res != null && res['status'] == 'ok') {
        final rawList = res['data'];
        if (rawList == null) {
          // backend returned data: null — treat as empty list
          if (mounted) setState(() { _cases = []; _casesLoading = false; });
          return;
        }
        final list = (rawList as List)
            .whereType<Map<String, dynamic>>()
            .map((e) => CounselingCase.fromJson(e))
            .toList();
        if (mounted) setState(() { _cases = list; _casesLoading = false; });
      } else {
        debugPrint('[Counseling] fetchCases non-ok: $res');
        if (mounted) setState(() { _casesLoading = false; _casesError = true; });
      }
    } catch (e) {
      debugPrint('[Counseling] fetchCases error: $e');
      if (mounted) setState(() { _casesLoading = false; _casesError = true; });
    }
  }

  Future<void> _fetchSessions() async {
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;
    try {
      final response = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.FETCH_MY_VIDEO_SESSIONS,
        data: FormData.fromMap({'email': userdata.email ?? ''}),
      );
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (res != null && res['status'] == 'ok') {
        final list = (res['data'] as List)
            .map((e) => VideoSession.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() => _sessions = list);
      }
    } catch (_) {
      // Sessions fail silently — section stays hidden
    }
  }

  Future<void> _openSubmitScreen() async {
    await Navigator.of(context).pushNamed(SubmitCounselingScreen.routeName);
    _fetchAll();
  }

  void _showCaseDetail(CounselingCase c) {
    final related = _sessions.where((s) => s.caseTitle == c.title).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CaseDetailSheet(counselingCase: c, sessions: related),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text(
              'Counseling',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userdata == null
          ? _buildAuthRequired(context)
          : _buildBody(context),
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: MyColors.primaryVeryLight, shape: BoxShape.circle),
              child: const Icon(Icons.lock_rounded,
                  color: MyColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Sign In Required',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: MyColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to access confidential counseling services.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MyColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AuthPage.routeName, arguments: true),
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: MyColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        children: [
          _buildIntroCard(),
          if (_sessions.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildVideoSessionsSection(),
          ],
          const SizedBox(height: 20),
          _buildCasesSection(),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366f1), Color(0xFF4338ca)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confidential Counseling',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Need to speak with a pastor? Submit a confidential request below. Your privacy is protected.',
            style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.55),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MyColors.primaryDark,
              minimumSize: const Size(double.infinity, 46),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Request Counseling',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            onPressed: _openSubmitScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Video Sessions',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MyColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ..._sessions.map((s) => _VideoSessionCard(session: s)),
      ],
    );
  }

  Widget _buildCasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Cases',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MyColors.textPrimary),
        ),
        const SizedBox(height: 12),
        if (_casesLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CupertinoActivityIndicator(radius: 16),
            ),
          )
        else if (_casesError)
          _buildErrorState()
        else if (_cases.isEmpty)
          _buildEmptyState()
        else
          ..._cases.map(
              (c) => _CaseTile(counselingCase: c, onTap: () => _showCaseDetail(c))),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 36, color: MyColors.textDisabled),
          const SizedBox(height: 8),
          const Text('Could not load cases',
              style: TextStyle(color: MyColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetchCases,
            child: const Text('Retry',
                style: TextStyle(color: MyColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
                color: MyColors.primaryVeryLight, shape: BoxShape.circle),
            child: const Icon(Icons.inbox_rounded,
                color: MyColors.primary, size: 26),
          ),
          const SizedBox(height: 12),
          const Text(
            'You have no counseling requests yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MyColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Video Session Card ─────────────────────────────────────────────────────

class _VideoSessionCard extends StatelessWidget {
  final VideoSession session;

  const _VideoSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final color = _platformColor(session.meetingPlatform);
    final icon = _platformIcon(session.meetingPlatform);
    final label = _platformLabel(session.meetingPlatform);
    final dt = _parseScheduledTime(session.meetingScheduledAt);
    final isToday = dt != null && _isSessionToday(dt);
    final hasLink = session.meetingLink.isNotEmpty;
    final isPending = session.meetingStatus == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Platform label + Today badge
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: color, size: 17),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color),
                          ),
                          const Spacer(),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEA580C),
                                    letterSpacing: 0.5),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Date/time + duration
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 13, color: MyColors.textDisabled),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dt != null
                                  ? _formatScheduledTime(dt)
                                  : session.meetingScheduledAt,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.textBody),
                            ),
                          ),
                          const Icon(Icons.timer_outlined,
                              size: 13, color: MyColors.textDisabled),
                          const SizedBox(width: 3),
                          Text(
                            '${session.durationMinutes} min',
                            style: const TextStyle(
                                fontSize: 12, color: MyColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Case title
                      Text(
                        session.caseTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: MyColors.textSecondary),
                      ),
                      if (session.assignedTo != null &&
                          session.assignedTo!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 13, color: MyColors.textDisabled),
                            const SizedBox(width: 4),
                            Text(
                              session.assignedTo!,
                              style: const TextStyle(
                                  fontSize: 12, color: MyColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Status badge + Join button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPending ? 'Pending' : 'Confirmed',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isPending
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF1D4ED8)),
                            ),
                          ),
                          const Spacer(),
                          if (hasLink)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 34),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: () => _joinSession(context, session),
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 14),
                              label: const Text('Join',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            )
                          else
                            const Text(
                              'Meeting link coming soon',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: MyColors.textDisabled,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Awaiting confirmation from your pastor.',
                          style: TextStyle(
                              fontSize: 11,
                              color: MyColors.textDisabled,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Case Tile ──────────────────────────────────────────────────────────────

class _CaseTile extends StatelessWidget {
  final CounselingCase counselingCase;
  final VoidCallback onTap;

  const _CaseTile({required this.counselingCase, required this.onTap});

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'marriage':
        return Icons.favorite_rounded;
      case 'family':
        return Icons.people_rounded;
      case 'grief':
        return Icons.spa_rounded;
      case 'addiction':
        return Icons.warning_rounded;
      case 'mental_health':
        return Icons.psychology_rounded;
      case 'financial':
        return Icons.account_balance_wallet_rounded;
      case 'spiritual':
        return Icons.menu_book_rounded;
      case 'relationship':
        return Icons.group_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'marriage':
        return const Color(0xFFEC4899);
      case 'family':
        return const Color(0xFF0D9488);
      case 'grief':
        return const Color(0xFF64748B);
      case 'addiction':
        return const Color(0xFFF97316);
      case 'mental_health':
        return const Color(0xFF8B5CF6);
      case 'financial':
        return const Color(0xFF10B981);
      case 'spiritual':
        return const Color(0xFF6366F1);
      case 'relationship':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _statusBadgeBg(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFFDBEAFE);
      case 'in_progress':
        return const Color(0xFFFEF3C7);
      case 'on_hold':
        return const Color(0xFFF1F5F9);
      case 'closed':
        return const Color(0xFFD1FAE5);
      case 'referred':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _statusBadgeFg(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF1D4ED8);
      case 'in_progress':
        return const Color(0xFFD97706);
      case 'on_hold':
        return const Color(0xFF64748B);
      case 'closed':
        return const Color(0xFF065F46);
      case 'referred':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'on_hold':
        return 'On Hold';
      case 'closed':
        return 'Closed';
      case 'referred':
        return 'Referred';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _colorForCategory(counselingCase.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MyColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForCategory(counselingCase.category),
                  color: catColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          counselingCase.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: MyColors.textPrimary),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: MyColors.textDisabled),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusBadgeBg(counselingCase.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(counselingCase.status),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusBadgeFg(counselingCase.status)),
                        ),
                      ),
                      if (counselingCase.assignedTo != null &&
                          counselingCase.assignedTo!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 12, color: MyColors.textDisabled),
                            const SizedBox(width: 3),
                            Text(
                              counselingCase.assignedTo!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: MyColors.textSecondary),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (counselingCase.nextFollowup != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: MyColors.textDisabled),
                        const SizedBox(width: 4),
                        Text(
                          'Next follow-up: ${counselingCase.nextFollowup}',
                          style: const TextStyle(
                              fontSize: 11, color: MyColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Case Detail Bottom Sheet ───────────────────────────────────────────────

class _CaseDetailSheet extends StatelessWidget {
  final CounselingCase counselingCase;
  final List<VideoSession> sessions;

  const _CaseDetailSheet(
      {required this.counselingCase, required this.sessions});

  static String _categoryLabel(String c) {
    const map = {
      'marriage': 'Marriage',
      'family': 'Family',
      'grief': 'Grief & Loss',
      'addiction': 'Addiction',
      'mental_health': 'Mental Health',
      'financial': 'Financial',
      'spiritual': 'Spiritual',
      'relationship': 'Relationships',
      'other': 'Other',
    };
    return map[c] ?? c;
  }

  static String _statusLabel(String s) {
    const map = {
      'open': 'Open',
      'in_progress': 'In Progress',
      'on_hold': 'On Hold',
      'closed': 'Closed',
      'referred': 'Referred',
    };
    return map[s] ?? s;
  }

  static String _priorityLabel(String p) {
    const map = {
      'low': 'Low',
      'normal': 'Normal',
      'high': 'High',
      'urgent': 'Urgent',
    };
    return map[p] ?? p;
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: MyColors.textDisabled),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: MyColors.textSecondary)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MyColors.textBody)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: MyColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Row(
              children: [
                const Text('Case Details',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MyColors.textPrimary)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: MyColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Case info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: MyColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          counselingCase.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MyColors.textPrimary),
                        ),
                        const Divider(height: 20),
                        _row(Icons.category_rounded, 'Category',
                            _categoryLabel(counselingCase.category)),
                        const SizedBox(height: 10),
                        _row(Icons.flag_rounded, 'Status',
                            _statusLabel(counselingCase.status)),
                        const SizedBox(height: 10),
                        _row(Icons.low_priority_rounded, 'Priority',
                            _priorityLabel(counselingCase.priority)),
                        if (counselingCase.assignedTo != null &&
                            counselingCase.assignedTo!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _row(Icons.person_rounded, 'Pastor',
                              counselingCase.assignedTo!),
                        ],
                        if (counselingCase.nextFollowup != null) ...[
                          const SizedBox(height: 10),
                          _row(Icons.calendar_today_rounded, 'Next Follow-up',
                              counselingCase.nextFollowup!),
                        ],
                        const SizedBox(height: 10),
                        _row(Icons.access_time_rounded, 'Opened',
                            counselingCase.openedAt),
                      ],
                    ),
                  ),
                  // Related video sessions
                  if (sessions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Upcoming Sessions',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MyColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ...sessions.map((s) => _VideoSessionCard(session: s)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
