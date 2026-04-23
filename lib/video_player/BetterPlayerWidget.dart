import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/Utility.dart';

/// BetterPlayerWidget - Wraps BetterPlayer for non-YouTube videos
/// 
/// WHY THIS WRAPPER:
/// - Centralizes all BetterPlayer configuration in one place
/// - Clearly shows that this ONLY handles non-YouTube videos
/// - Makes it easy to maintain and update player settings
/// - Prevents accidental use with YouTube content
/// 
/// SUPPORTS: MP4, HLS, DASH, live streams, downloaded videos
/// NEVER RECEIVES: YouTube URLs or video IDs (filtered by UnifiedVideoPlayer)
class BetterPlayerWidget extends StatefulWidget {
  final Media media;

  const BetterPlayerWidget({
    required this.media,
    Key? key,
  }) : super(key: key);

  @override
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // Determine data source type based on http flag
    final sourceType = widget.media.http == true
        ? BetterPlayerDataSourceType.network
        : BetterPlayerDataSourceType.file;

    // Convert localhost to emulator IP for compatibility
    final convertedUrl = Utility.convertLocalhostToEmulator(widget.media.streamUrl);

    // Create data source
    final betterPlayerDataSource = BetterPlayerDataSource(
      sourceType,
      convertedUrl,
    );

    // Initialize controller with configuration
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 3 / 2,
        autoPlay: true,
        allowedScreenSleep: false,
        // Placeholder shows while video loads
        placeholder: CachedNetworkImage(
          imageUrl: Utility.convertLocalhostToEmulator(widget.media.coverPhoto),
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

    // ✅ CRITICAL FIX: Actually initialize the video player controller
    try {
      await _betterPlayerController!.initialize();
      print('Video player initialized successfully for: ${widget.media.title}');
      if (mounted) {
        setState(() {}); // Trigger rebuild with initialized controller
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: ${widget.media.title}')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(BetterPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If media changed, reinitialize player
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
      aspectRatio: 3 / 2,
      child: BetterPlayer(
        controller: _betterPlayerController!,
      ),
    );
  }
}



