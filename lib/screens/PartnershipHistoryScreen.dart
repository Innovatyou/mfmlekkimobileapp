import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/PartnershipPayment.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ── Args ─────────────────────────────────────────────────────────────────────

class PartnershipHistoryArgs {
  final int partnershipId;
  final String? tierName;
  final String? currency;

  const PartnershipHistoryArgs({
    required this.partnershipId,
    this.tierName,
    this.currency,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class PartnershipHistoryScreen extends StatefulWidget {
  static const routeName = '/partnership/history';

  const PartnershipHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PartnershipHistoryScreen> createState() =>
      _PartnershipHistoryScreenState();
}

class _PartnershipHistoryScreenState
    extends State<PartnershipHistoryScreen> {
  bool _loading = false;
  bool _error = false;
  PartnershipPaymentSummary? _summary;

  PartnershipHistoryArgs get _args =>
      ModalRoute.of(context)!.settings.arguments as PartnershipHistoryArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_summary == null && !_loading) _load();
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
        ApiUrl.FETCH_PARTNERSHIP_PAYMENTS,
        data: {
          'email': userdata.email ?? '',
          'partnership_id': _args.partnershipId.toString(),
        },
      );
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (res != null && res['status'] == 'ok') {
        if (mounted) {
          setState(() {
            _summary = PartnershipPaymentSummary.fromJson(res);
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() { _loading = false; _error = true; });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final currency = args.currency ?? _summary?.currency ?? 'USD';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            if (args.tierName?.isNotEmpty == true)
              Text(
                args.tierName!,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12),
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
                        const Text('Could not load payment history',
                            style:
                                TextStyle(color: MyColors.textSecondary)),
                        const SizedBox(height: 10),
                        TextButton(
                            onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _summary == null
                    ? const SizedBox.shrink()
                    : _buildContent(currency),
      ),
    );
  }

  Widget _buildContent(String currency) {
    final fmt = NumberFormat('#,##0.00');
    final s = _summary!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
      children: [
        // ── Summary Card ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4338ca), Color(0xFF6366f1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366f1).withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Pledged',
                  '$currency ${fmt.format(s.pledgeAmount)}',
                  Colors.white70,
                  Colors.white,
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.25)),
              Expanded(
                child: _summaryItem(
                  'Paid',
                  '$currency ${fmt.format(s.paidAmount)}',
                  Colors.white70,
                  const Color(0xFF6EE7B7),
                ),
              ),
              Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.25)),
              Expanded(
                child: _summaryItem(
                  'Remaining',
                  '$currency ${fmt.format(s.remaining)}',
                  Colors.white70,
                  s.remaining > 0
                      ? const Color(0xFFFCD34D)
                      : const Color(0xFF6EE7B7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Progress bar ────────────────────────────────────────────────
        if (s.pledgeAmount > 0) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MyColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Payment Progress',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: MyColors.textSecondary)),
                    Text(
                      '${((s.paidAmount / s.pledgeAmount).clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MyColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (s.paidAmount / s.pledgeAmount).clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        MyColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Payment Records ─────────────────────────────────────────────
        const Text(
          'Payment Records',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MyColors.textPrimary),
        ),
        const SizedBox(height: 12),

        if (s.payments.isEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MyColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 36, color: MyColors.textDisabled),
                SizedBox(height: 10),
                Text('No payments recorded yet.',
                    style: TextStyle(
                        color: MyColors.textSecondary, fontSize: 13.5)),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MyColors.border),
            ),
            child: Column(
              children: s.payments.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final isLast = i == s.payments.length - 1;
                return _PaymentRow(
                  payment: p,
                  currency: currency,
                  fmt: fmt,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _summaryItem(
      String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: labelColor)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Payment Row ───────────────────────────────────────────────────────────────

class _PaymentRow extends StatelessWidget {
  final PartnershipPayment payment;
  final String currency;
  final NumberFormat fmt;
  final bool showDivider;

  const _PaymentRow({
    required this.payment,
    required this.currency,
    required this.fmt,
    required this.showDivider,
  });

  String _methodLabel(String m) {
    if (m.isEmpty) return 'Payment';
    return m
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = payment.paymentDate.isNotEmpty
        ? payment.paymentDate
        : payment.createdAt.length >= 10
            ? payment.createdAt.substring(0, 10)
            : payment.createdAt;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 20, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currency ${fmt.format(payment.amount)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MyColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _methodLabel(payment.paymentMethod),
                      style: const TextStyle(
                          fontSize: 12, color: MyColors.textSecondary),
                    ),
                    if (payment.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        payment.note,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: MyColors.textDisabled,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                    fontSize: 11, color: MyColors.textDisabled),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 68, endIndent: 16),
      ],
    );
  }
}
