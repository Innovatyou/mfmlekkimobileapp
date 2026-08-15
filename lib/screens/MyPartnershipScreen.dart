import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/Partnership.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/DonateScreen.dart';
import 'package:higherground/screens/PartnershipHistoryScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Color _hexColor(String? hex) {
  if (hex == null || hex.isEmpty) return MyColors.primary;
  final h = hex.replaceAll('#', '');
  if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
  return MyColors.primary;
}

String _freqLabel(String f) => const {
      'one-time': 'One-Time',
      'monthly': 'Monthly',
      'quarterly': 'Quarterly',
      'annually': 'Annually',
    }[f] ??
    f;

// ── Screen ───────────────────────────────────────────────────────────────────

class MyPartnershipScreen extends StatefulWidget {
  static const routeName = '/my_partnership';

  const MyPartnershipScreen({Key? key}) : super(key: key);

  @override
  State<MyPartnershipScreen> createState() => _MyPartnershipScreenState();
}

class _MyPartnershipScreenState extends State<MyPartnershipScreen> {
  bool _loading = false;
  bool _error = false;
  List<Partnership> _partnerships = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;

    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final response = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.FETCH_MY_PARTNERSHIP,
        data: {'email': userdata.email ?? ''},
      );
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (res != null && res['status'] == 'ok') {
        final list = (res['partnerships'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(Partnership.fromJson)
            .toList();
        if (mounted) setState(() { _partnerships = list; _loading = false; });
      } else {
        if (mounted) setState(() { _loading = false; _error = true; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
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
            Icon(Icons.receipt_long_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text(
              'My Partnerships',
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
      body: RefreshIndicator(
        onRefresh: _load,
        color: MyColors.primary,
        child: userdata == null
            ? _buildAuthPrompt(context)
            : _loading
                ? const Center(child: CupertinoActivityIndicator(radius: 14))
                : _error
                    ? _buildError()
                    : _partnerships.isEmpty
                        ? _buildEmpty()
                        : ListView(
                            padding:
                                const EdgeInsets.fromLTRB(14, 14, 14, 32),
                            children: _partnerships
                                .map((p) => _PartnershipCard(
                                      partnership: p,
                                      onRefresh: _load,
                                    ))
                                .toList(),
                          ),
      ),
    );
  }

  Widget _buildAuthPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: MyColors.primaryVeryLight, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded,
                  color: MyColors.primary, size: 30),
            ),
            const SizedBox(height: 16),
            const Text('Sign in to view your partnerships',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MyColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Create an account or sign in to track your partnership history.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: MyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 46),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context)
                  .pushNamed(AuthPage.routeName, arguments: true),
              child: const Text('Sign In',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded,
              size: 36, color: MyColors.textDisabled),
          const SizedBox(height: 10),
          const Text('Could not load partnerships',
              style: TextStyle(color: MyColors.textSecondary)),
          const SizedBox(height: 10),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                  color: MyColors.primaryVeryLight, shape: BoxShape.circle),
              child: const Icon(Icons.handshake_rounded,
                  color: MyColors.primary, size: 28),
            ),
            const SizedBox(height: 16),
            const Text('No partnerships yet',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MyColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t made any partnership pledges yet. Head back to browse available tiers.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: MyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: MyColors.primary,
                side: const BorderSide(color: MyColors.primary),
                minimumSize: const Size(160, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Browse Tiers',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Partnership Card ──────────────────────────────────────────────────────────

class _PartnershipCard extends StatelessWidget {
  final Partnership partnership;
  final VoidCallback onRefresh;

  const _PartnershipCard({required this.partnership, required this.onRefresh});

  void _viewPayments(BuildContext context) {
    Navigator.of(context).pushNamed(
      PartnershipHistoryScreen.routeName,
      arguments: PartnershipHistoryArgs(
        partnershipId: partnership.id,
        tierName: partnership.tierName,
        currency: partnership.currency,
      ),
    );
  }

  void _makePayment(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          DonateScreen(url: ApiUrl.partnerPaymentUrl(partnership.id)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(partnership.tierColor);
    final fmt = NumberFormat('#,##0.00');
    final progress = partnership.pledgeAmount > 0
        ? (partnership.paidAmount / partnership.pledgeAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining =
        (partnership.pledgeAmount - partnership.paidAmount)
            .clamp(0.0, double.infinity);
    final isActionable =
        partnership.status == 'active' || partnership.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.workspace_premium_rounded,
                                color: color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partnership.tierName?.isNotEmpty == true
                                      ? partnership.tierName!
                                      : 'Custom Partnership',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: MyColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(_freqLabel(partnership.frequency),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: MyColors.textSecondary)),
                              ],
                            ),
                          ),
                          _StatusBadge(status: partnership.status),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Amounts row
                      Row(
                        children: [
                          _amountItem('Pledged',
                              '${partnership.currency} ${fmt.format(partnership.pledgeAmount)}',
                              MyColors.textBody),
                          const SizedBox(width: 20),
                          _amountItem('Paid',
                              '${partnership.currency} ${fmt.format(partnership.paidAmount)}',
                              const Color(0xFF059669)),
                          const SizedBox(width: 20),
                          _amountItem('Remaining',
                              '${partnership.currency} ${fmt.format(remaining)}',
                              partnership.status == 'overdue'
                                  ? const Color(0xFFDC2626)
                                  : MyColors.primary),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              partnership.status == 'overdue'
                                  ? const Color(0xFFDC2626)
                                  : color),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% paid'
                        '${partnership.startDate.isNotEmpty ? '  ·  Since ${partnership.startDate}' : ''}',
                        style: const TextStyle(
                            fontSize: 11, color: MyColors.textDisabled),
                      ),

                      // Action buttons (active / pending)
                      if (isActionable) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: MyColors.primary,
                                  side: const BorderSide(
                                      color: MyColors.primary),
                                  minimumSize: const Size(0, 38),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.history_rounded,
                                    size: 15),
                                label: const Text('View Payments',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () => _viewPayments(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      partnership.status == 'overdue'
                                          ? const Color(0xFFDC2626)
                                          : MyColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 38),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                                icon:
                                    const Icon(Icons.payment_rounded, size: 15),
                                label: const Text('Make Payment',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                onPressed: () => _makePayment(context),
                              ),
                            ),
                          ],
                        ),
                      ] else if (partnership.paidAmount > 0) ...[
                        // Completed / cancelled with payments — show history only
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MyColors.textSecondary,
                              side: const BorderSide(color: MyColors.border),
                              minimumSize: const Size(0, 38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.history_rounded, size: 15),
                            label: const Text('View Payment History',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            onPressed: () => _viewPayments(context),
                          ),
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

  Widget _amountItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: MyColors.textDisabled)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'active' => (
          const Color(0xFFD1FAE5),
          const Color(0xFF065F46),
          'Active'
        ),
      'pending' => (
          const Color(0xFFFEF3C7),
          const Color(0xFFB45309),
          'Pending'
        ),
      'overdue' => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
          'Overdue'
        ),
      'completed' => (
          const Color(0xFFE0E7FF),
          const Color(0xFF4338CA),
          'Completed'
        ),
      'cancelled' => (
          const Color(0xFFF1F5F9),
          MyColors.textSecondary,
          'Cancelled'
        ),
      _ => (const Color(0xFFF1F5F9), MyColors.textSecondary, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
