import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/models/Partnership.dart';
import 'package:higherground/models/PartnershipTier.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/MyPartnershipScreen.dart';
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

// ── Screen ───────────────────────────────────────────────────────────────────

class PartnershipScreen extends StatefulWidget {
  static const routeName = '/partnership';

  const PartnershipScreen({Key? key}) : super(key: key);

  @override
  State<PartnershipScreen> createState() => _PartnershipScreenState();
}

class _PartnershipScreenState extends State<PartnershipScreen> {
  bool _loading = false;
  bool _error = false;
  List<PartnershipTier> _tiers = [];
  Partnership? _current;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_PARTNERSHIP_TIERS,
        data: {'email': userdata?.email ?? ''},
      );
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (res != null && res['status'] == 'ok') {
        final tiers = (res['tiers'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(PartnershipTier.fromJson)
            .toList();
        Partnership? current;
        if (res['current'] is Map<String, dynamic>) {
          current =
              Partnership.fromJson(res['current'] as Map<String, dynamic>);
        }
        if (mounted) {
          setState(() {
            _tiers = tiers;
            _current = current;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
    }
  }

  void _openSheet(BuildContext context, PartnershipTier tier) {
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) {
      Navigator.of(context).pushNamed(AuthPage.routeName, arguments: true);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PledgeBottomSheet(
        tier: tier,
        current: _current,
        userdata: userdata,
        onSuccess: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          _load();
        },
      ),
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
            Icon(Icons.handshake_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text(
              'Partnership',
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
        actions: [
          if (userdata != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 15),
                label: const Text('My Pledges',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.of(context)
                    .pushNamed(MyPartnershipScreen.routeName),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: MyColors.primary,
        child: _loading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _error
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            size: 36, color: MyColors.textDisabled),
                        const SizedBox(height: 10),
                        const Text('Could not load tiers',
                            style: TextStyle(color: MyColors.textSecondary)),
                        const SizedBox(height: 10),
                        TextButton(
                            onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
                    children: [
                      // Current partnership summary
                      if (_current != null) ...[
                        _CurrentPartnershipBanner(partnership: _current!),
                        const SizedBox(height: 16),
                      ],

                      // Auth prompt (shown to guests)
                      if (userdata == null) ...[
                        _buildAuthPrompt(context),
                        const SizedBox(height: 16),
                      ],

                      // Tiers header
                      const Text(
                        'Partnership Tiers',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MyColors.textPrimary),
                      ),
                      const SizedBox(height: 12),

                      if (_tiers.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 28, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: MyColors.border),
                          ),
                          child: const Center(
                            child: Text('No tiers available yet.',
                                style: TextStyle(
                                    color: MyColors.textSecondary,
                                    fontSize: 13.5)),
                          ),
                        )
                      else
                        ..._tiers.map((t) => _TierActionCard(
                              tier: t,
                              onTap: () => _openSheet(context, t),
                            )),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAuthPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.primaryVeryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MyColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: MyColors.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sign in to join a tier or manage your partnership.',
              style: TextStyle(
                  fontSize: 13, color: MyColors.primaryDark, height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pushNamed(AuthPage.routeName, arguments: true),
            child: const Text('Sign In',
                style: TextStyle(
                    color: MyColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Current Partnership Banner ────────────────────────────────────────────────

class _CurrentPartnershipBanner extends StatelessWidget {
  final Partnership partnership;

  const _CurrentPartnershipBanner({required this.partnership});

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(partnership.tierColor);
    final fmt = NumberFormat('#,##0.00');
    final progress = partnership.pledgeAmount > 0
        ? (partnership.paidAmount / partnership.pledgeAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                          : 'Your Partnership',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MyColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${partnership.currency} ${fmt.format(partnership.paidAmount)} of ${fmt.format(partnership.pledgeAmount)} paid',
                      style: const TextStyle(
                          fontSize: 12, color: MyColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: partnership.status),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(MyPartnershipScreen.routeName),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: MyColors.primary,
            ),
            child: const Text('View details →',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'active' => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      'pending' => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
      'overdue' => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      'completed' => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      'cancelled' => (const Color(0xFFF1F5F9), MyColors.textSecondary),
      _ => (const Color(0xFFF1F5F9), MyColors.textSecondary),
    };
    final label = switch (status) {
      'active' => 'Active',
      'pending' => 'Pending',
      'overdue' => 'Overdue',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Tier Action Card ──────────────────────────────────────────────────────────

class _TierActionCard extends StatelessWidget {
  final PartnershipTier tier;
  final VoidCallback onTap;

  const _TierActionCard({required this.tier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(tier.color);
    final isCurrentTier = tier.action == 'renew';
    final fmt = NumberFormat('#,##0');

    final (buttonLabel, buttonBg, buttonFg) = switch (tier.action) {
      'renew' => ('Renew Commitment', color, Colors.white),
      'upgrade' => (
          'Upgrade to ${tier.name}',
          const Color(0xFF059669),
          Colors.white
        ),
      'downgrade' => (
          'Switch to ${tier.name}',
          Colors.transparent,
          MyColors.textSecondary
        ),
      _ => ('Join This Tier', MyColors.mainC0lor, Colors.white),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrentTier ? color.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTier ? color : MyColors.border,
          width: isCurrentTier ? 1.5 : 1,
        ),
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
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.workspace_premium_rounded,
                                color: color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(tier.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: MyColors.textPrimary)),
                          ),
                          if (isCurrentTier)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('YOUR TIER',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                      letterSpacing: 0.8)),
                            )
                          else if (tier.minAmount > 0)
                            Text(
                              'From \$${fmt.format(tier.minAmount)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color),
                            ),
                        ],
                      ),
                      if (tier.description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(tier.description,
                            style: const TextStyle(
                                fontSize: 13,
                                color: MyColors.textSecondary,
                                height: 1.5)),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: tier.action == 'downgrade'
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: MyColors.textSecondary,
                                  side:
                                      const BorderSide(color: MyColors.border),
                                  minimumSize: const Size(0, 38),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: onTap,
                                child: Text(buttonLabel,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonBg,
                                  foregroundColor: buttonFg,
                                  minimumSize: const Size(0, 38),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: onTap,
                                child: Text(buttonLabel,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                      ),
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

// ── Pledge Bottom Sheet ───────────────────────────────────────────────────────

class _PledgeBottomSheet extends StatefulWidget {
  final PartnershipTier tier;
  final Partnership? current;
  final Userdata userdata;
  final void Function(String message) onSuccess;

  const _PledgeBottomSheet({
    required this.tier,
    required this.current,
    required this.userdata,
    required this.onSuccess,
  });

  @override
  State<_PledgeBottomSheet> createState() => _PledgeBottomSheetState();
}

class _PledgeBottomSheetState extends State<_PledgeBottomSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _frequency = 'monthly';
  bool _submitting = false;

  // can be updated on "already_subscribed" error
  late String _action;
  Partnership? _current;

  static const _frequencies = [
    ('one-time', 'One-Time'),
    ('monthly', 'Monthly'),
    ('quarterly', 'Quarterly'),
    ('annually', 'Annually'),
  ];

  @override
  void initState() {
    super.initState();
    _action = widget.tier.action;
    _current = widget.current;
    _amountCtrl.text = widget.tier.minAmount > 0
        ? widget.tier.minAmount.toStringAsFixed(0)
        : '';
    if (_current != null) {
      _frequency = _current!.frequency;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _sheetTitle => switch (_action) {
        'renew' => 'Renew Your ${widget.tier.name} Commitment',
        'upgrade' => 'Upgrade to ${widget.tier.name}',
        'downgrade' => 'Switch to ${widget.tier.name}',
        _ => 'Join ${widget.tier.name}',
      };

  Future<void> _confirm() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid pledge amount.');
      return;
    }

    setState(() => _submitting = true);

    try {
      final Map<String, dynamic> payload;
      final String endpoint;

      if (_action == 'new') {
        endpoint = ApiUrl.SUBMIT_PARTNERSHIP_PLEDGE;
        payload = {
          'email': widget.userdata.email ?? '',
          'partner_name':
              '${widget.userdata.firstname ?? ''} ${widget.userdata.lastname ?? ''}'
                  .trim(),
          'tier_id': widget.tier.id.toString(),
          'pledge_amount': amount.toString(),
          'currency': 'USD',
          'frequency': _frequency,
          'notes': _notesCtrl.text.trim(),
        };
      } else {
        endpoint = ApiUrl.UPDATE_PARTNERSHIP_PLEDGE;
        payload = {
          'email': widget.userdata.email ?? '',
          'partnership_id': _current!.id.toString(),
          'tier_id': widget.tier.id.toString(),
          'pledge_amount': amount.toString(),
          'frequency': _frequency,
          'notes': _notesCtrl.text.trim(),
        };
      }

      final response = await (await Utility.getAuthenticatedDio())
          .post(endpoint, data: payload);
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;

      if (!mounted) return;
      setState(() => _submitting = false);

      if (res != null && res['status'] == 'ok') {
        final msg = res['message']?.toString() ??
            (_action == 'new'
                ? 'Application submitted. Awaiting approval.'
                : 'Changes submitted. Awaiting admin approval.');
        Navigator.of(context).pop();
        widget.onSuccess(msg);
      } else if (res != null &&
          res['status'] == 'error' &&
          res['code'] == 'already_subscribed') {
        // Update this sheet to the correct action
        final suggested = res['suggested_action'] as String? ?? 'renew';
        Partnership? existing;
        if (res['existing_partnership'] is Map<String, dynamic>) {
          existing = Partnership.fromJson(
              res['existing_partnership'] as Map<String, dynamic>);
        }
        setState(() {
          _action = suggested;
          _current = existing ?? _current;
        });
        _showError(
            'You already have a partnership. Please ${suggested} instead.');
      } else {
        _showError(res?['message']?.toString() ?? 'Something went wrong.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        _showError('Network error. Please try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: MyColors.danger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _sheetTitle,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MyColors.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded,
                      color: MyColors.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current tier info (for renew/upgrade/downgrade)
                  if (_action != 'new' && _current != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: MyColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz_rounded,
                              size: 16, color: MyColors.textDisabled),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Currently: ${_current!.tierName ?? 'Custom'} — ${_current!.currency} ${fmt.format(_current!.pledgeAmount)}',
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: MyColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pledge Amount
                  _label('Pledge Amount'),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MyColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: 'USD  ',
                      prefixStyle: const TextStyle(
                          fontSize: 14,
                          color: MyColors.textDisabled,
                          fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: MyColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: MyColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: MyColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Frequency
                  _label('Frequency'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _frequencies.map((opt) {
                      final (key, label) = opt;
                      final sel = _frequency == key;
                      return GestureDetector(
                        onTap: () => setState(() => _frequency = key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? MyColors.primaryVeryLight
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? MyColors.primary : MyColors.border,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? MyColors.primary
                                      : MyColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  _label('Notes (optional)'),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 14, color: MyColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Any additional message…',
                      hintStyle: const TextStyle(
                          color: MyColors.textDisabled, fontSize: 13.5),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: MyColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: MyColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: MyColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MyColors.textSecondary,
                            side: const BorderSide(color: MyColors.border),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitting ? null : _confirm,
                          child: _submitting
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white, radius: 10)
                              : const Text('Confirm',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
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
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MyColors.textSecondary)),
      );
}
