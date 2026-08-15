import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:higherground/models/wellness.dart';
import 'package:higherground/services/wellness_service.dart';

const _kCacheTtlMs = 15 * 60 * 1000; // 15 minutes

class WellnessProvider extends ChangeNotifier {
  final WellnessService _service = WellnessService();

  WellnessProfile? profile;
  List<BirthdayMember> birthdays = [];
  bool loading = false;
  String? error;

  Future<void> load(String email, {bool forceRefresh = false}) async {
    error = null;

    if (!forceRefresh) {
      final cached = await _loadCache(email);
      if (cached != null) {
        profile = cached;
        loading = false;
        notifyListeners();
        _refreshInBackground(email);
        return;
      }
    }

    loading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.fetchProfile(email),
        _service.fetchGroupBirthdays(email),
      ]);
      profile   = results[0] as WellnessProfile;
      birthdays = results[1] as List<BirthdayMember>;
      await _saveCache(email, profile!);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> requestCare(String email, String type, String msg) async {
    await _service.requestPastoralCare(
        email: email, careType: type, message: msg);
  }

  void clear() {
    profile   = null;
    birthdays = [];
    error     = null;
    loading   = false;
    notifyListeners();
  }

  // ── Cache helpers (shared_preferences + TTL) ────────────────────────────────

  Future<WellnessProfile?> _loadCache(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts  = prefs.getInt(_tsKey(email)) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - ts > _kCacheTtlMs) return null;
      final raw = prefs.getString(_dataKey(email));
      if (raw == null) return null;
      return WellnessProfile.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(String email, WellnessProfile p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dataKey(email), p.toJsonString());
      await prefs.setInt(_tsKey(email), DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  String _dataKey(String email) => 'wellness_profile_$email';
  String _tsKey(String email)   => 'wellness_ts_$email';

  void _refreshInBackground(String email) {
    Future.microtask(() async {
      try {
        final results = await Future.wait([
          _service.fetchProfile(email),
          _service.fetchGroupBirthdays(email),
        ]);
        profile   = results[0] as WellnessProfile;
        birthdays = results[1] as List<BirthdayMember>;
        await _saveCache(email, profile!);
        notifyListeners();
      } catch (_) {}
    });
  }
}
