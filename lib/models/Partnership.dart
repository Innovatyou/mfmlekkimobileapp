class Partnership {
  final int id;
  final int? tierId;
  final String partnerName;
  final String partnerEmail;
  final String? partnerPhone;
  final double pledgeAmount;
  final double paidAmount;
  final String currency;
  final String frequency;
  final String status;
  final String startDate;
  final String createdAt;
  final String? tierName;
  final String? tierColor;
  final String? notes;

  const Partnership({
    required this.id,
    this.tierId,
    required this.partnerName,
    required this.partnerEmail,
    this.partnerPhone,
    required this.pledgeAmount,
    required this.paidAmount,
    required this.currency,
    required this.frequency,
    required this.status,
    required this.startDate,
    required this.createdAt,
    this.tierName,
    this.tierColor,
    this.notes,
  });

  bool get isPending => status == 'pending';
  bool get canPay => status == 'active' || status == 'overdue';
  bool get isApproved => paidAmount > 0 && status != 'cancelled' && status != 'pending';

  factory Partnership.fromJson(Map<String, dynamic> j) => Partnership(
        id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
        tierId: j['tier_id'] != null
            ? int.tryParse(j['tier_id'].toString())
            : null,
        partnerName: j['partner_name'] as String? ?? '',
        partnerEmail: j['partner_email'] as String? ?? '',
        partnerPhone: j['partner_phone'] as String?,
        pledgeAmount:
            double.tryParse(j['pledge_amount']?.toString() ?? '0') ?? 0,
        paidAmount:
            double.tryParse(j['paid_amount']?.toString() ?? '0') ?? 0,
        currency: j['currency'] as String? ?? 'USD',
        frequency: j['frequency'] as String? ?? 'monthly',
        status: j['status'] as String? ?? 'active',
        startDate: j['start_date'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
        tierName: j['tier_name'] as String?,
        tierColor: j['tier_color'] as String?,
        notes: j['notes'] as String?,
      );
}
