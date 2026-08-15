import 'package:higherground/models/MarketplacePhoto.dart';
import 'package:higherground/utils/ApiUrl.dart';

class MarketplaceItem {
  final int id;
  final String title;
  final String? description;
  final double price;
  final bool isFree;
  final String itemCondition;
  final String? image;
  final String? location;
  final String status;
  final int views;
  final bool isFeatured;
  final int? categoryId;
  final String? categoryName;
  final String? sellerName;
  final String? sellerEmail;
  final String? sellerPhone;
  final String? createdAt;
  final List<MarketplacePhoto> photos;

  MarketplaceItem({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.isFree,
    required this.itemCondition,
    this.image,
    this.location,
    required this.status,
    required this.views,
    required this.isFeatured,
    this.categoryId,
    this.categoryName,
    this.sellerName,
    this.sellerEmail,
    this.sellerPhone,
    this.createdAt,
    this.photos = const [],
  });

  String get coverImageUrl {
    if (image != null && image!.isNotEmpty) {
      return '${ApiUrl.BASEURL}uploads/marketplace/$image';
    }
    if (photos.isNotEmpty) {
      return photos.first.url;
    }
    return '';
  }

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    final photosList = <MarketplacePhoto>[];
    if (json['photos'] != null && json['photos'] is List) {
      for (final p in json['photos'] as List) {
        if (p is Map<String, dynamic>) {
          photosList.add(MarketplacePhoto.fromJson(p));
        }
      }
    }

    return MarketplaceItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isFree: json['is_free'].toString() == '1',
      itemCondition: json['item_condition']?.toString() ?? 'used',
      image: json['image']?.toString(),
      location: json['location']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      views: int.tryParse(json['views'].toString()) ?? 0,
      isFeatured: json['is_featured'].toString() == '1',
      categoryId: json['category_id'] != null
          ? int.tryParse(json['category_id'].toString())
          : null,
      categoryName: json['category_name']?.toString(),
      sellerName: json['seller_name']?.toString(),
      sellerEmail: json['seller_email']?.toString(),
      sellerPhone: json['seller_phone']?.toString(),
      createdAt: json['created_at']?.toString(),
      photos: photosList,
    );
  }
}
