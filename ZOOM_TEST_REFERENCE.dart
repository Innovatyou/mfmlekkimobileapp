// This is a reference integration test file that demonstrates testing the Zoom feature
// To use this, create a test file in test/zoom_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:higherground/service/zoom_service.dart';

void main() {
  group('Zoom Service Tests', () {
    test('ZoomServiceStatus parses live response correctly', () {
      final json = {
        'title': 'Sunday Night Prayer Meeting',
        'meeting_url': 'https://zoom.us/wc/join/test123',
      };

      final status = ZoomServiceStatus.fromJson(json);

      expect(status.isLive, true);
      expect(status.title, 'Sunday Night Prayer Meeting');
      expect(status.meetingUrl, 'https://zoom.us/wc/join/test123');
    });

    test('ZoomServiceStatus parses offline response correctly', () {
      final json = {
        'title': 'Sunday Night Prayer Meeting',
        'meeting_url': null,
      };

      final status = ZoomServiceStatus.fromJson(json);

      expect(status.isLive, false);
      expect(status.title, 'Sunday Night Prayer Meeting');
      expect(status.meetingUrl, null);
    });

    test('ZoomServiceStatus handles missing fields safely', () {
      final json = <String, dynamic>{};

      final status = ZoomServiceStatus.fromJson(json);

      expect(status.isLive, false);
      expect(status.title, ZoomServiceStatus.defaultTitle);
      expect(status.meetingUrl, null);
    });

    test('ZoomServiceStatus treats empty meeting_url as offline', () {
      final json = {
        'title': 'Sunday Night Prayer Meeting',
        'meeting_url': '   ',
      };

      final status = ZoomServiceStatus.fromJson(json);

      expect(status.isLive, false);
      expect(status.title, 'Sunday Night Prayer Meeting');
      expect(status.meetingUrl, null);
    });
  });
}

/*
HOW TO RUN THESE TESTS:

1. Create the test file:
   test/zoom_service_test.dart

2. Paste this content into that file

3. Run the tests:
   flutter test test/zoom_service_test.dart

4. Or run all tests:
   flutter test

EXPECTED OUTPUT:
✓ Zoom Service Tests
  ✓ ZoomServiceStatus parses live response correctly
  ✓ ZoomServiceStatus parses offline response correctly
  ✓ ZoomServiceStatus handles missing fields safely
  ✓ ZoomServiceStatus treats empty meeting_url as offline

All tests should pass!
*/
