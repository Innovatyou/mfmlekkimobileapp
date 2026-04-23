import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class ZoomServiceStatus {
  static const String defaultTitle = 'Sunday Night Prayer Meeting';

  final String title;
  final String? meetingUrl;

  ZoomServiceStatus({
    required this.title,
    this.meetingUrl,
  });

  factory ZoomServiceStatus.fromJson(Map<String, dynamic> json) {
    final String title = (json['title'] as String?)?.trim().isNotEmpty == true
        ? (json['title'] as String).trim()
        : defaultTitle;

    final String? parsedMeetingUrl = (json['meeting_url'] as String?)?.trim();
    final String? meetingUrl =
        (parsedMeetingUrl == null || parsedMeetingUrl.isEmpty)
            ? null
            : parsedMeetingUrl;

    return ZoomServiceStatus(
      title: title,
      meetingUrl: meetingUrl,
    );
  }

  bool get isLive => meetingUrl != null && meetingUrl!.isNotEmpty;
}

class ZoomService {
  static const String _baseUrl = 'https://church.innovative.ng/api/zoom/live';

  /// Fetches the current zoom service status
  /// Returns ZoomServiceStatus with live/offline status
  static Future<ZoomServiceStatus> fetchZoomServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          return ZoomServiceStatus(
            title: ZoomServiceStatus.defaultTitle,
            meetingUrl: null,
          );
        }
        final jsonData = decoded;
        return ZoomServiceStatus.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return ZoomServiceStatus(
          title: ZoomServiceStatus.defaultTitle,
          meetingUrl: null,
        );
      } else {
        throw Exception(
          'Failed to load zoom service status (${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw Exception('Request timeout while fetching zoom service status');
    } on FormatException {
      throw Exception('Invalid zoom service response format');
    } catch (e) {
      throw Exception('Unable to fetch zoom service status: $e');
    }
  }

  /// Validates if the meeting URL is valid and accessible
  static Future<bool> validateMeetingUrl(String url) async {
    try {
      final response = await http.head(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

