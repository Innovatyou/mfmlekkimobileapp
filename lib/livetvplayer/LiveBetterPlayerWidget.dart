import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/utils/Utility.dart';

/// LiveBetterPlayerWidget - Wraps BetterPlayer for non-YouTube livestreams
/// 
/// SUPPORTS: HLS (.m3u8), RTMP, and other non-YouTube livestreams
/// NEVER RECEIVES: YouTube livestream URLs (filtered by UnifiedLivePlayer)
/// 
/// This maintains existing livestream functionality for all non-YouTube sources
class LiveBetterPlayerWidget extends StatefulWidget {
  final LiveStreams media;

  const LiveBetterPlayerWidget({
    required this.media,
    Key? key,
  }) : super(key: key);

  @override
  State<LiveBetterPlayerWidget> createState() => _LiveBetterPlayerWidgetState();
}

class _LiveBetterPlayerWidgetState extends State<LiveBetterPlayerWidget> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Determine stream format based on type
    final sourceType = _getSourceType(widget.media.type);

    // Convert localhost to emulator IP for compatibility
    final convertedUrl = Utility.convertLocalhostToEmulator(widget.media.streamUrl);

    final betterPlayerDataSource = BetterPlayerDataSource(
      sourceType,
      convertedUrl,
      videoFormat: _getVideoFormat(widget.media.type),
      liveStream: true,
      // Keeps the stream playing (with lock-screen/notification controls)
      // when the app is backgrounded or the device is locked.
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        title: widget.media.title ?? 'Live Stream',
        author: 'Live now',
        imageUrl: widget.media.coverphoto,
        notificationChannelName: 'Live Stream Playback',
        activityName: 'MainActivity',
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        allowedScreenSleep: false,
        // Don't auto-pause on backgrounding — the notification above is what
        // keeps playback (and the underlying foreground service) alive.
        handleLifecycle: false,
        placeholder: CachedNetworkImage(
        imageUrl: widget.media.coverphoto ?? '',
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CupertinoActivityIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(
              Icons.error,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );
  }

  BetterPlayerDataSourceType _getSourceType(String? streamType) {
    if (streamType == 'rtmp') {
      return BetterPlayerDataSourceType.network;
    }
    return BetterPlayerDataSourceType.network;
  }

  BetterPlayerVideoFormat _getVideoFormat(String? streamType) {
    if (streamType == 'm3u8') {
      return BetterPlayerVideoFormat.hls;
    } else if (streamType == 'rtmp') {
      return BetterPlayerVideoFormat.other;
    }
    return BetterPlayerVideoFormat.hls;
  }

  @override
  void didUpdateWidget(LiveBetterPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If stream changed, reinitialize
    if (oldWidget.media.id != widget.media.id) {
      _betterPlayerController?.pause();
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_betterPlayerController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: BetterPlayer(
        controller: _betterPlayerController!,
      ),
    );
  }
}



