import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:higherground/models/wellness.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/providers/wellness_provider.dart';
import 'package:higherground/screens/MyGroupsScreen.dart';
import 'package:higherground/screens/PrayersScreen.dart';
import 'package:higherground/widgets/birthday_avatar_card.dart';
import 'package:higherground/widgets/care_event_tile.dart';
import 'package:higherground/widgets/request_care_sheet.dart';
import 'package:higherground/widgets/score_arc.dart';

class WellnessScreen extends StatefulWidget {
  static const routeName = '/WellnessScreen';

  final String email;
  const WellnessScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  bool _careExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WellnessProvider>().load(widget.email);
    });
  }

  Future<void> _refresh() async {
    await context.read<WellnessProvider>().load(widget.email, forceRefresh: true);
  }

  void _openCareSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestCareSheet(
        email: widget.email,
        onSuccess: () {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.read<WellnessProvider>().load(widget.email, forceRefresh: true);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: const Text('My Wellness',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        backgroundColor: MyColors.navBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<WellnessProvider>(
        builder: (context, prov, _) {
          if (prov.loading && prov.profile == null) {
            return _buildShimmer();
          }

          if (prov.error != null && prov.profile == null) {
            return _buildError(prov.error!);
          }

          final p = prov.profile;
          if (p == null) return _buildShimmer();

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF6366f1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEngagementCard(p),
                  const SizedBox(height: 16),
                  _buildActivityRow(p.activity),
                  const SizedBox(height: 16),
                  _buildCareHistory(p.careEvents),
                  const SizedBox(height: 16),
                  _buildBirthdays(prov.birthdays),
                  const SizedBox(height: 20),
                  _buildRequestButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Spiritual Engagement Card ───────────────────────────────────────────────

  Widget _buildEngagementCard(WellnessProfile p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ScoreArc(score: p.score, grade: p.grade),
          if (p.flags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: p.flags.map(_flagChip).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _flagChip(String flag) {
    const labels = {
      'in_group':    'In a Group',
      'donor':       'Giving Member',
      'prayer':      'Prayer Warrior',
      'testimony':   'Has Testified',
      'cared':       'Pastorally Connected',
      'recent_care': 'Recently Checked On',
    };
    final label = labels[flag] ?? flag;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFe0e7ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366f1))),
    );
  }

  // ── Activity Summary Row ────────────────────────────────────────────────────

  Widget _buildActivityRow(ActivitySummary a) {
    return Row(
      children: [
        _ActivityTile(
          label: 'Groups',
          count: a.groupsCount,
          color: const Color(0xFF6366f1),
          onTap: () => Navigator.of(context)
              .pushNamed(MyGroupsScreen.routeName),
        ),
        const SizedBox(width: 8),
        _ActivityTile(
          label: 'Prayers',
          count: a.prayersCount,
          color: const Color(0xFF8b5cf6),
          onTap: () =>
              Navigator.of(context).pushNamed(PrayersScreen.routeName),
        ),
        const SizedBox(width: 8),
        _ActivityTile(
          label: 'Testimonies',
          count: a.testimonyCount,
          color: const Color(0xFF10b981),
        ),
        const SizedBox(width: 8),
        _ActivityTile(
          label: 'Donations',
          count: a.donationCount,
          color: const Color(0xFFf59e0b),
        ),
      ],
    );
  }

  // ── Care History ────────────────────────────────────────────────────────────

  Widget _buildCareHistory(List<CareEvent> events) {
    const maxCollapsed = 5;
    final shown = _careExpanded ? events : events.take(maxCollapsed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Care Received'),
        const SizedBox(height: 10),
        if (events.isEmpty)
          _EmptyState(
            'Our pastoral team will connect with you soon. '
            'You can also request care below.',
          )
        else ...[
          ...shown.map((e) => CareEventTile(event: e)),
          if (events.length > maxCollapsed)
            GestureDetector(
              onTap: () =>
                  setState(() => _careExpanded = !_careExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _careExpanded ? 'Show less' : 'See all ${events.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366f1),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ── Birthdays ───────────────────────────────────────────────────────────────

  Widget _buildBirthdays(List<BirthdayMember> birthdays) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Upcoming Birthdays'),
        const SizedBox(height: 10),
        if (birthdays.isEmpty)
          _EmptyState('No birthdays in the next 7 days.')
        else
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: birthdays.length,
              itemBuilder: (_, i) =>
                  BirthdayAvatarCard(member: birthdays[i]),
            ),
          ),
      ],
    );
  }

  // ── Request Care Button ─────────────────────────────────────────────────────

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _openCareSheet,
        icon: const Icon(Icons.favorite_border_rounded, size: 18),
        label: const Text('Request Pastoral Care',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366f1),
          side: const BorderSide(color: Color(0xFF6366f1), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Shimmer placeholder ─────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFe2e8f0),
      highlightColor: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _shimmerBox(height: 240, radius: 16),
            const SizedBox(height: 16),
            Row(children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(child: _shimmerBox(height: 70, radius: 12)),
                if (i < 3) const SizedBox(width: 8),
              ]
            ]),
            const SizedBox(height: 16),
            _shimmerBox(height: 100, radius: 12),
            const SizedBox(height: 10),
            _shimmerBox(height: 100, radius: 12),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double height, double radius = 8}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Color(0xFFf59e0b)),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF64748b), fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1e293b),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFe2e8f0)),
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748b)),
          textAlign: TextAlign.center,
        ),
      );
}

class _ActivityTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _ActivityTile({
    required this.label,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  )),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748b),
                  ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
