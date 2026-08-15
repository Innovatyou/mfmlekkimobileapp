class MarketplaceCategory {
  final int id;
  final String name;

  MarketplaceCategory({required this.id, required this.name});

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
