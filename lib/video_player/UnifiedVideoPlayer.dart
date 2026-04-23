import 'package:flutter/material.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/Utility.dart';
import 'BetterPlayerWidget.dart';
import 'YoutubePlayerIFrame.dart';

/// UnifiedVideoPlayer - Intelligent router for all video sources
/// 
/// CURRENT ARCHITECTURE:
/// - YouTube videos → YoutubePlayerIFrame (in-app playback with youtube_player_iframe)
/// - All others (MP4, HLS, streams) → BetterPlayer/ExoPlayer (existing implementation)
/// - Maintains backward compatibility with existing non-YouTube playback
class UnifiedVideoPlayer extends StatelessWidget {
  final Media? media;
  final Key? playerKey;

  const UnifiedVideoPlayer({
    required this.media,
    this.playerKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      return Center(
        child: Text('No media available'),
      );
    }

    // Detect YouTube content and route to appropriate player
    final isYoutube = Utility.isYouTubeVideo(media!.streamUrl, media!.videoType);

    if (isYoutube) {
      // YouTube videos now play in-app using youtube_player_iframe
      return YoutubePlayerIFrame(
        media: media!,
        key: playerKey,
      );
    } else {
      // Route to BetterPlayer for all other video sources (MP4, HLS, live streams)
      // This maintains existing functionality for non-YouTube content
      return BetterPlayerWidget(
        media: media!,
        key: playerKey,
      );
    }
  }
}



