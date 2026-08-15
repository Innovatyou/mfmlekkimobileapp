class PartnershipTier {
  final int id;
  final String name;
  final String description;
  final double minAmount;
  final String color;
  final String action; // "new" | "renew" | "upgrade" | "downgrade"

  const PartnershipTier({
    required this.id,
    required this.name,
    required this.description,
    required this.minAmount,
    required this.color,
    this.action = 'new',
  });

  factory PartnershipTier.fromJson(Map<String, dynamic> j) => PartnershipTier(
        id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        minAmount: double.tryParse(j['min_amount']?.toString() ?? '0') ?? 0,
        color: j['color'] as String? ?? '#6366f1',
        action: j['action'] as String? ?? 'new',
      );
}
