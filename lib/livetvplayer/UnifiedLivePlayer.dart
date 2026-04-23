import 'package:flutter/material.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'LiveYoutubePlayerIFrame.dart';
import 'LiveBetterPlayerWidget.dart';
import 'LiveFacebookPlayer.dart';

/// UnifiedLivePlayer - Intelligent router for live stream sources
/// 
/// ROUTING LOGIC:
/// - YouTube livestreams → LiveYoutubePlayerIFrame (youtube_player_iframe)
/// - HLS/RTMP streams → LiveBetterPlayerWidget (BetterPlayer/ExoPlayer)
/// - Facebook livestreams → LiveFacebookPlayer (existing)
/// 
/// WHY: Same reason as VOD - ExoPlayer cannot authenticate with YouTube.
/// YouTube livestreams must use youtube_player_iframe for reliability.
class UnifiedLivePlayer extends StatelessWidget {
  final LiveStreams? media;
  final Key? playerKey;

  const UnifiedLivePlayer({
    required this.media,
    this.playerKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      return Center(
        child: Text('No livestream available'),
      );
    }

    // Route based on stream type
    // YouTube takes priority over other checks
    if (media!.type == 'youtube') {
      return LiveYoutubePlayerIFrame(
        media: media!,
        key: playerKey,
      );
    } else if (media!.type == 'm3u8' || media!.type == 'rtmp') {
      return LiveBetterPlayerWidget(
        media: media!,
        key: playerKey,
      );
    } else if (media!.type == 'facebook') {
      return LiveFacebookPlayer(
        media: media!,
        key: playerKey,
      );
    } else {
      return Center(
        child: Text('Unsupported stream type: ${media!.type}'),
      );
    }
  }
}



