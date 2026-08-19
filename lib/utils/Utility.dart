import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:higherground/screens/InAppWebPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';
//import 'package:music_player/music_player.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class Utility {
  static Dio getDio() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(milliseconds: 30000);
    dio.options.receiveTimeout = const Duration(milliseconds: 30000);
    dio.options.sendTimeout = const Duration(milliseconds: 30000);
    dio.options.headers['Accept'] = 'application/json';
    return dio;
  }

  // Dio instance with the mobile Bearer token attached, for the
  // Marketplace/Partnership/Counseling/MemberCare endpoints that require it.
  static Future<Dio> getAuthenticatedDio() async {
    final dio = getDio();
    final userdata = await SQLiteDbProvider.db.getUserData();
    final token = userdata?.apiToken;
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return dio;
  }

  static Map<String, dynamic> decodeResponse(dynamic data) {
    if (data is String) return json.decode(data) as Map<String, dynamic>;
    return Map<String, dynamic>.from(data as Map);
  }

  static String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  static Future<void> openBrowserTab(
    String url, {
    BuildContext? context,
    String? title,
  }) async {
    final normalized = normalizeUrl(url);
    if (normalized.isEmpty) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation link is currently unavailable.')),
        );
      }
      return;
    }

    try {
      await FlutterWebBrowser.openWebPage(
        url: normalized,
        customTabsOptions: CustomTabsOptions(
          colorScheme: CustomTabsColorScheme.dark,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
        safariVCOptions: SafariViewControllerOptions(
          barCollapsingEnabled: true,
          preferredBarTintColor: MyColors.mainC0lor,
          preferredControlTintColor: MyColors.mainC0lor,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
          modalPresentationCapturesStatusBarAppearance: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('[Utility] Custom tab open failed: $e');
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InAppWebPage(
              url: normalized,
              title: title,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Utility] Custom tab open failed: $e');
      final uri = Uri.tryParse(normalized);
      if (uri == null) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid donation link.')),
          );
        }
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InAppWebPage(
              url: normalized,
              title: title,
            ),
          ),
        );
      }
    }
  }

  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static String getBase64EncodedString(String text) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(text.trim());
  }

  static String getBase64DecodedString(String text) {
    //print(text);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.decode(text.trim());
  }

  static String getFileExtension(String link) {
    String ext = "mp4";
    if (link.contains(".")) {
      ext = link.substring(link.lastIndexOf("."));
    }
    return ext.replaceAll(".", "");
  }

  static List<Media?> extractMediaByType(List<Media?> mediaList, String? type) {
    List<Media?> newList = [];
    for (Media? item in mediaList) {
      if (item!.mediaType == type) {
        newList.add(item);
      }
    }
    return newList;
  }

  static List<Media?> removeCurrentMediaFromList(
      List<Media?> mediaList, Media? media) {
    List<Media?> playlist = [];
    for (Media? item in mediaList) {
      if (item!.id != media!.id) {
        playlist.add(item);
      }
    }
    return playlist;
  }

  static List<LiveStreams> removeCurrentLiveStreamsFromList(
      List<LiveStreams> mediaList, LiveStreams media) {
    List<LiveStreams> playlist = [];
    for (LiveStreams item in mediaList) {
      if (item.id != media.id) {
        playlist.add(item);
      }
    }
    return playlist;
  }

  static bool showDownloadButton(BuildContext context, Media media) {
    if (Provider.of<DashboardModel>(context, listen: false)
            .isDownloadsAllowed() ==
        false) {
      return false;
    }
    if (Provider.of<DownloadsModel>(context, listen: false)
            .isMediaInDownloads(media.id) !=
        null) {
      return false;
    }
    if (Provider.of<DownloadsModel>(context, listen: false)
            .isMediaInCurrentDownloads(media.id) !=
        null) {
      return false;
    }
    if (media.videoType == "youtube_video") return false;
    if (media.canDownload!) {
      return true;
    }
    return false;
  }

  static bool canDownloadMedia(BuildContext context, Media media) {
    if (Provider.of<DashboardModel>(context, listen: false)
            .isDownloadsAllowed() ==
        false) {
      return false;
    }
    if (media.canDownload!) {
      if (media.isFree!)
        return true;
      else
        return false; //TODO check if user is subscribed
    }
    return false;
  }

  //update media total views
  static Future<void> updatemediatotalviews(int id) async {
    try {
      final response = await getDio().post(
        ApiUrl.update_media_total_views,
        data: jsonEncode({
          "data": {
            "media": id.toString(),
          }
        }),
      );
      print(response.data);
    } catch (exception) {}
  }

  // Extract YouTube video ID from URL or return as-is if already just the ID
  static String extractYoutubeVideoId(String urlOrId) {
    if (urlOrId.isEmpty) return '';
    
    // If it's already just an ID (11 characters, alphanumeric with dash and underscore)
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(urlOrId)) {
      return urlOrId;
    }
    
    // Try to extract from various YouTube URL formats
    RegExp regExp = RegExp(
      r'(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    
    Match? match = regExp.firstMatch(urlOrId);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }
    
    // If no match found, return the original (might be just the ID)
    return urlOrId;
  }

  /// Detects if the given URL or video type indicates YouTube content.
  /// WHY: ExoPlayer/BetterPlayer cannot handle YouTube URLs or IDs directly.
  /// They throw ExoPlaybackException: Source error and FileNotFoundException.
  /// YouTube MUST be played through youtube_player_iframe to comply with YouTube ToS.
  static bool isYouTubeVideo(String? streamUrl, String? videoType) {
    if (streamUrl == null || streamUrl.isEmpty) return false;
    if (videoType == null) return false;
    
    // Primary check: video type explicitly indicates YouTube
    if (videoType.toLowerCase() == 'youtube_video') {
      return true;
    }
    
    // Secondary check: URL patterns indicate YouTube
    final youtubePatterns = [
      RegExp(r'youtube\.com', caseSensitive: false),
      RegExp(r'youtu\.be', caseSensitive: false),
      RegExp(r'youtube-nocookie\.com', caseSensitive: false),
      RegExp(r'^[a-zA-Z0-9_-]{11}$'), // Just a video ID
    ];
    
    return youtubePatterns.any((pattern) => pattern.hasMatch(streamUrl));
  }

  /// Converts localhost URLs to 10.0.2.2 for Android emulator compatibility
  /// Android emulator uses 10.0.2.2 to access the host machine
  /// This ensures videos/media hosted on localhost work on emulator
  static String convertLocalhostToEmulator(String? url) {
    if (url == null || url.isEmpty) return url ?? '';
    
    // Replace localhost with 10.0.2.2 (Android emulator host IP)
    String converted = url.replaceAll('localhost', '10.0.2.2');
    converted = converted.replaceAll('127.0.0.1', '10.0.2.2');
    
    return converted;
  }

  /// Launches a URL in the default browser or app
  /// Supports YouTube URLs, web links, and fallback handling
  static Future<void> launchURL(String url) async {
    try {
      await FlutterWebBrowser.openWebPage(url: url);
    } catch (e) {
      debugPrint('[Utility] Error launching URL: $e');
      rethrow;
    }
  }
}



