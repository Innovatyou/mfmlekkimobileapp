import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/MarketplaceCategory.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';

class MarketplaceModel with ChangeNotifier {
  // ─── Categories & currency ─────────────────────────────────────────
  List<MarketplaceCategory> categories = [];
  String currencySymbol = '₦';

  // ─── Browse feed ───────────────────────────────────────────────────
  List<MarketplaceItem> listings = [];
  bool browseLoading = false;
  bool browseError = false;
  bool hasMore = true;
  int browseOffset = 0;
  String browseSearch = '';
  int? browseCategoryId;

  // ─── My listings ──────────────────────────────────────────────────
  List<MarketplaceItem> myListings = [];
  bool myLoading = false;
  bool myError = false;

  // ─── Item detail ──────────────────────────────────────────────────
  MarketplaceItem? currentItem;
  bool detailLoading = false;
  bool detailError = false;

  // ─── Submission ───────────────────────────────────────────────────
  bool submitting = false;
  String? submitError;

  // ─────────────────────────────────────────────────────────────────
  // Categories
  // ─────────────────────────────────────────────────────────────────

  Future<void> fetchCategories() async {
    try {
      final res = await Utility.getDio().post(
        ApiUrl.FETCH_MARKETPLACE_CATEGORIES,
        data: jsonEncode({'data': {}}),
        options: Options(responseType: ResponseType.plain),
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          categories = (json['categories'] as List)
              .map((c) => MarketplaceCategory.fromJson(c as Map<String, dynamic>))
              .toList();
          currencySymbol = json['currency_symbol']?.toString() ?? '₦';
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────
  // Browse listings
  // ─────────────────────────────────────────────────────────────────

  Future<void> fetchListings({bool refresh = false}) async {
    if (refresh) {
      browseOffset = 0;
      hasMore = true;
      listings = [];
    }
    if (!hasMore || browseLoading) return;

    browseLoading = true;
    browseError = false;
    notifyListeners();

    try {
      final res = await Utility.getDio().post(
        ApiUrl.FETCH_MARKETPLACE_LISTINGS,
        data: jsonEncode({
          'data': {
            'search': browseSearch,
            'category_id': browseCategoryId?.toString() ?? '',
            'start': browseOffset.toString(),
          }
        }),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          final newItems = (json['items'] as List)
              .map((i) => MarketplaceItem.fromJson(i as Map<String, dynamic>))
              .toList();
          if (json['currency_symbol'] != null) {
            currencySymbol = json['currency_symbol'].toString();
          }
          listings.addAll(newItems);
          browseOffset += newItems.length;
          hasMore = listings.length < (json['total'] as int? ?? 0);
        } else {
          browseError = true;
        }
      } else {
        browseError = true;
      }
    } catch (_) {
      browseError = true;
    }

    browseLoading = false;
    notifyListeners();
  }

  void setSearchFilter(String query) {
    browseSearch = query;
    fetchListings(refresh: true);
  }

  void setCategoryFilter(int? catId) {
    browseCategoryId = catId;
    fetchListings(refresh: true);
  }

  // ─────────────────────────────────────────────────────────────────
  // My listings
  // ─────────────────────────────────────────────────────────────────

  Future<void> fetchMyListings() async {
    final user = await SQLiteDbProvider.db.getUserData();
    if (user == null) return;

    myLoading = true;
    myError = false;
    notifyListeners();

    try {
      final res = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.FETCH_MY_MARKETPLACE_LISTINGS,
        data: jsonEncode({'data': {'email': user.email}}),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          myListings = (json['items'] as List)
              .map((i) => MarketplaceItem.fromJson(i as Map<String, dynamic>))
              .toList();
        } else {
          myError = true;
        }
      } else {
        myError = true;
      }
    } catch (_) {
      myError = true;
    }

    myLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Item detail
  // ─────────────────────────────────────────────────────────────────

  Future<void> fetchItem(int itemId) async {
    detailLoading = true;
    detailError = false;
    currentItem = null;
    notifyListeners();

    try {
      final res = await Utility.getDio().post(
        ApiUrl.FETCH_MARKETPLACE_ITEM,
        data: jsonEncode({'data': {'item_id': itemId.toString()}}),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          currentItem = MarketplaceItem.fromJson(
              json['item'] as Map<String, dynamic>);
        } else {
          detailError = true;
        }
      } else {
        detailError = true;
      }
    } catch (_) {
      detailError = true;
    }

    detailLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  // Submit listing
  // ─────────────────────────────────────────────────────────────────

  Future<int?> submitListing(Map<String, dynamic> payload) async {
    submitting = true;
    submitError = null;
    notifyListeners();

    try {
      final user = await SQLiteDbProvider.db.getUserData();
      payload['email'] = user?.email ?? '';

      final res = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.SUBMIT_MARKETPLACE_LISTING,
        data: jsonEncode({'data': payload}),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          submitting = false;
          notifyListeners();
          return int.tryParse(json['item_id'].toString());
        }
        submitError = json['message']?.toString() ?? 'Submission failed';
      } else {
        submitError = 'Server error. Please try again.';
      }
    } catch (_) {
      submitError = 'Network error. Please check your connection.';
    }

    submitting = false;
    notifyListeners();
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // Upload photo
  // ─────────────────────────────────────────────────────────────────

  Future<bool> uploadPhoto(int itemId, String filePath) async {
    try {
      final user = await SQLiteDbProvider.db.getUserData();
      final formData = FormData.fromMap({
        'email': user?.email ?? '',
        'item_id': itemId.toString(),
        'photo': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(Platform.pathSeparator).last,
        ),
      });

      final res = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.UPLOAD_MARKETPLACE_PHOTO,
        data: formData,
      );

      if (res.statusCode == 200) {
        dynamic json = res.data;
        if (json is String) json = jsonDecode(json);
        return json['status'] == 'ok';
      }
    } catch (_) {}
    return false;
  }

  // ─────────────────────────────────────────────────────────────────
  // Update listing
  // ─────────────────────────────────────────────────────────────────

  Future<bool> updateListing(int itemId, Map<String, dynamic> payload) async {
    submitting = true;
    submitError = null;
    notifyListeners();

    try {
      final user = await SQLiteDbProvider.db.getUserData();
      payload['email'] = user?.email ?? '';
      payload['item_id'] = itemId.toString();

      final res = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.UPDATE_MARKETPLACE_LISTING,
        data: jsonEncode({'data': payload}),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          submitting = false;
          notifyListeners();
          return true;
        }
        submitError = json['message']?.toString() ?? 'Update failed';
      } else {
        submitError = 'Server error. Please try again.';
      }
    } catch (_) {
      submitError = 'Network error. Please check your connection.';
    }

    submitting = false;
    notifyListeners();
    return false;
  }

  // ─────────────────────────────────────────────────────────────────
  // Delete listing
  // ─────────────────────────────────────────────────────────────────

  Future<bool> deleteListing(int itemId) async {
    try {
      final user = await SQLiteDbProvider.db.getUserData();
      final res = await (await Utility.getAuthenticatedDio()).post(
        ApiUrl.DELETE_MY_MARKETPLACE_LISTING,
        data: jsonEncode({
          'data': {'email': user?.email ?? '', 'item_id': itemId.toString()}
        }),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        if (json['status'] == 'ok') {
          myListings.removeWhere((i) => i.id == itemId);
          listings.removeWhere((i) => i.id == itemId);
          notifyListeners();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // ─────────────────────────────────────────────────────────────────
  // Submit inquiry
  // ─────────────────────────────────────────────────────────────────

  Future<bool> submitInquiry({
    required int itemId,
    required String name,
    required String email,
    String phone = '',
    required String message,
  }) async {
    try {
      final res = await Utility.getDio().post(
        ApiUrl.SUBMIT_MARKETPLACE_INQUIRY,
        data: jsonEncode({
          'data': {
            'item_id': itemId.toString(),
            'name': name,
            'email': email,
            'phone': phone,
            'message': message,
          }
        }),
        options: Options(responseType: ResponseType.plain),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.data);
        return json['status'] == 'ok';
      }
    } catch (_) {}
    return false;
  }
}
