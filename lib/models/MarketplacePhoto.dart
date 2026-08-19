import 'package:higherground/utils/ApiUrl.dart';

class MarketplacePhoto {
  final int id;
  final int itemId;
  final String filename;
  final int sortOrder;

  MarketplacePhoto({
    required this.id,
    required this.itemId,
    required this.filename,
    required this.sortOrder,
  });

  String get url => '${ApiUrl.BASEURL}uploads/marketplace/$filename';

  factory MarketplacePhoto.fromJson(Map<String, dynamic> json) {
    return MarketplacePhoto(
      id: int.tryParse(json['id'].toString()) ?? 0,
      itemId: int.tryParse(json['item_id'].toString()) ?? 0,
      filename: json['filename']?.toString() ?? '',
      sortOrder: int.tryParse(json['sort_order'].toString()) ?? 0,
    );
  }
}
