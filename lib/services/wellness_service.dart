import 'package:dio/dio.dart';
import 'package:higherground/models/wellness.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';

class WellnessService {
  Future<Dio> _client() => Utility.getAuthenticatedDio();

  Future<WellnessProfile> fetchProfile(String email) async {
    final resp = await (await _client()).post<Map<String, dynamic>>(
      ApiUrl.MY_WELLNESS_PROFILE,
      data: FormData.fromMap({'email': email}),
    );
    final body = resp.data!;
    if (body['status'] != 'ok') {
      throw Exception(body['message'] ?? 'Failed to load wellness profile.');
    }
    return WellnessProfile.fromJson(body);
  }

  Future<bool> requestPastoralCare({
    required String email,
    required String careType,
    String message = '',
  }) async {
    final resp = await (await _client()).post<Map<String, dynamic>>(
      ApiUrl.REQUEST_PASTORAL_CARE,
      data: FormData.fromMap({
        'email': email,
        'care_type': careType,
        'message': message,
      }),
    );
    final body = resp.data!;
    if (body['status'] != 'ok') {
      throw Exception(body['message'] ?? 'Failed to submit care request.');
    }
    return true;
  }

  Future<List<BirthdayMember>> fetchGroupBirthdays(String email,
      {int days = 7}) async {
    final resp = await (await _client()).post<Map<String, dynamic>>(
      ApiUrl.GROUP_MEMBER_BIRTHDAYS,
      data: FormData.fromMap({'email': email, 'days': days}),
    );
    final body = resp.data!;
    if (body['status'] != 'ok') {
      throw Exception(body['message'] ?? 'Failed to load birthdays.');
    }
    final list = body['birthdays'] as List? ?? [];
    return list
        .map((e) => BirthdayMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
