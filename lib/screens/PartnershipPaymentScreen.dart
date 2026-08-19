import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/PartnershipPayment.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/DonateScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ── Args ─────────────────────────────────────────────────────────────────────

class PartnershipPaymentArgs {
  final int partnershipId;
  final String partnerName;
  final double pledgeAmount;
  final double paidAmount;
  final String currency;
  final String frequency;
  final String status;
  final String? tierName;

  const PartnershipPaymentArgs({
    required this.partnershipId,
    required this.partnerName,
    required this.pledgeAmount,
    required this.paidAmount,
    required this.currency,
    required this.frequency,
    required this.status,
    this.tierName,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class PartnershipPaymentScreen extends StatefulWidget {
  static const routeName = '/partnership/payment';

  const PartnershipPaymentScreen({Key? key}) : super(key: key);

  @override
  State<PartnershipPaymentScreen> createState() =>
      _PartnershipPaymentScreenState();
}

class _PartnershipPaymentScreenState extends State<PartnershipPaymentScreen> {
  static const _freqMap = {
    'one-time': 'One-Time',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'annually': 'Annually',
  };

  bool _historyLoading = false;
  PartnershipPaymentSummary? _history;
  String? _historyError;

  Future<void> _fetchHistory(PartnershipPaymentArgs args) async {
    final userdata =
        Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata == null) return;

    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    try {
      final response = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.FETCH_PARTNERSHIP_PAYMENTS,
        data: {
          'email': userdata.email ?? '',
          'partnership_id': args.partnershipId.toString(),
        },
      );
      final res = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (!mounted) return;
      if (res != null && res['status'] == 'ok') {
        setState(() {
          _history = PartnershipPaymentSummary.fromJson(res);
          _historyLoading = false;
        });
      } else {
        setState(() {
          _historyError = res?['message']?.toString() ?? 'Could not load history.';
          _historyLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _historyError = 'Network error. Please try again.';
          _historyLoading = false;
        });
      }
    }
  }

  void _payNow(BuildContext context, PartnershipPaymentArgs args) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DonateScreen(url: ApiUrl.partnerPaymentUrl(args.partnershipId)),
    ));
  }

  void _showHistorySheet(BuildContext context, PartnershipPaymentArgs args) {
    _fetchHistory(args);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentHistorySheet(
        args: args,
        historyLoading: _historyLoading,
        history: _history,
        historyError: _historyError,
        onRetry: () => _fetchHistory(args),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PartnershipPaymentArgs;
    final fmt = NumberFormat('#,##0.00');
    final freqLabel = _freqMap[args.frequency] ?? args.frequency;
    final remaining =
        (args.pledgeAmount - args.paidAmount).clamp(0.0, double.infinity);
    final progress = args.pledgeAmount > 0
        ? (args.paidAmount / args.pledgeAmount).clamp(0.0, 1.0)
        : 0.0;
    final canPay = args.status == 'active' || args.status == 'overdue';
    final isOverdue = args.status == 'overdue';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text(
              'Make Payment',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pledge Summary Card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MyColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Pledge Summary',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MyColors.textSecondary),
                      ),
                      const Spacer(),
                      _StatusBadge(status: args.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _summaryRow(Icons.person_outline_rounded, 'Partner',
                      args.partnerName),
                  if (args.tierName != null && args.tierName!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _summaryRow(Icons.workspace_premium_rounded, 'Tier',
                        args.tierName!),
                  ],
                  const SizedBox(height: 10),
                  _summaryRow(Icons.repeat_rounded, 'Frequency', freqLabel),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _amountBox('Pledged',
                          '${args.currency} ${fmt.format(args.pledgeAmount)}',
                          MyColors.textBody),
                      _amountBox('Paid',
                          '${args.currency} ${fmt.format(args.paidAmount)}',
                          const Color(0xFF059669)),
                      _amountBox(
                          'Remaining',
                          '${args.currency} ${fmt.format(remaining)}',
                          isOverdue
                              ? const Color(0xFFDC2626)
                              : MyColors.primary),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOverdue
                              ? const Color(0xFFDC2626)
                              : MyColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% completed',
                    style: const TextStyle(
                        fontSize: 11, color: MyColors.textDisabled),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (isOverdue)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your pledge is overdue. Please make a payment as soon as possible.',
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF991B1B),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Pay Now ────────────────────────────────────────────────
            if (canPay)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdue
                        ? const Color(0xFFDC2626)
                        : MyColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 20),
                  label: const Text(
                    'Pay Now',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _payNow(context, args),
                ),
              ),

            if (canPay) const SizedBox(height: 12),

            // ── View Payment History ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyColors.primary,
                  side: const BorderSide(color: MyColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text(
                  'View Payment History',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                onPressed: () => _showHistorySheet(context, args),
              ),
            ),

            const SizedBox(height: 24),

            if (!canPay)
              const Center(
                child: Text(
                  'Payments are only available for active or overdue pledges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: MyColors.textDisabled,
                      height: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: MyColors.textDisabled),
        const SizedBox(width: 8),
        Text('$label:  ',
            style: const TextStyle(
                fontSize: 13, color: MyColors.textSecondary)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MyColors.textBody)),
        ),
      ],
    );
  }

  Widget _amountBox(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: MyColors.textDisabled)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 13,
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
      'completed' => (
          const Color(0xFFDBEAFE),
          const Color(0xFF1D4ED8),
          'Completed'
        ),
      'overdue' => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          'Overdue'
        ),
      'cancelled' => (
          const Color(0xFFFFE4E6),
          const Color(0xFFBE123C),
          'Cancelled'
        ),
      _ => (const Color(0xFFF1F5F9), MyColors.textSecondary, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Payment History Bottom Sheet ──────────────────────────────────────────────

class _PaymentHistorySheet extends StatelessWidget {
  final PartnershipPaymentArgs args;
  final bool historyLoading;
  final PartnershipPaymentSummary? history;
  final String? historyError;
  final VoidCallback onRetry;

  const _PaymentHistorySheet({
    required this.args,
    required this.historyLoading,
    required this.history,
    required this.historyError,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Payment History',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MyColors.textPrimary),
                ),
                const Spacer(),
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
          const SizedBox(height: 4),
          const Divider(),
          // Body
          Expanded(
            child: historyLoading
                ? const Center(
                    child: CupertinoActivityIndicator(radius: 14))
                : historyError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                size: 36, color: MyColors.textDisabled),
                            const SizedBox(height: 10),
                            Text(historyError!,
                                style: const TextStyle(
                                    color: MyColors.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: onRetry,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : history == null || history!.payments.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    size: 36,
                                    color: MyColors.textDisabled),
                                SizedBox(height: 10),
                                Text('No payments recorded yet.',
                                    style: TextStyle(
                                        color: MyColors.textSecondary,
                                        fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            itemCount: history!.payments.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = history!.payments[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD1FAE5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 18,
                                          color: Color(0xFF059669)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${args.currency} ${fmt.format(p.amount)}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: MyColors.textPrimary),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            p.paymentMethod.isNotEmpty
                                                ? p.paymentMethod
                                                : 'Payment',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    MyColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      p.createdAt.length >= 10
                                          ? p.createdAt.substring(0, 10)
                                          : p.createdAt,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: MyColors.textDisabled),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          // Summary footer
          if (history != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _footerItem('Pledged',
                      '${args.currency} ${fmt.format(history!.pledgeAmount)}',
                      MyColors.textBody),
                  _footerItem('Paid',
                      '${args.currency} ${fmt.format(history!.paidAmount)}',
                      const Color(0xFF059669)),
                  _footerItem(
                      'Remaining',
                      '${args.currency} ${fmt.format(history!.remaining)}',
                      MyColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _footerItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: MyColors.textDisabled)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }
}
