class PartnershipPayment {
  final double amount;
  final String paymentMethod;
  final String paymentDate;
  final String note;
  final String createdAt;

  const PartnershipPayment({
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.note,
    required this.createdAt,
  });

  factory PartnershipPayment.fromJson(Map<String, dynamic> j) =>
      PartnershipPayment(
        amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        paymentMethod: j['payment_method'] as String? ?? '',
        paymentDate: j['payment_date'] as String? ?? '',
        note: j['note'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
      );
}

class PartnershipPaymentSummary {
  final List<PartnershipPayment> payments;
  final double pledgeAmount;
  final double paidAmount;
  final double remaining;
  final String currency;

  const PartnershipPaymentSummary({
    required this.payments,
    required this.pledgeAmount,
    required this.paidAmount,
    required this.remaining,
    required this.currency,
  });

  factory PartnershipPaymentSummary.fromJson(Map<String, dynamic> j) {
    final list = (j['payments'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PartnershipPayment.fromJson)
        .toList();
    return PartnershipPaymentSummary(
      payments: list,
      pledgeAmount:
          double.tryParse(j['pledge_amount']?.toString() ?? '0') ?? 0,
      paidAmount: double.tryParse(j['paid_amount']?.toString() ?? '0') ?? 0,
      remaining: double.tryParse(j['remaining']?.toString() ?? '0') ?? 0,
      currency: j['currency'] as String? ?? 'USD',
    );
  }
}
