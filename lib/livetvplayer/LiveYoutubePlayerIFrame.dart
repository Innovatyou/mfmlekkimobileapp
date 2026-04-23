import 'package:flutter/material.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube live stream in-app player using youtube_player_iframe
/// Plays YouTube livestreams natively within the app instead of redirecting
class LiveYoutubePlayerIFrame extends StatefulWidget {
  final LiveStreams media;

  const LiveYoutubePlayerIFrame({required this.media, Key? key}) : super(key: key);

  @override
  State<LiveYoutubePlayerIFrame> createState() => _LiveYoutubePlayerIFrameState();
}

class _LiveYoutubePlayerIFrameState extends State<LiveYoutubePlayerIFrame> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final videoId = Utility.extractYoutubeVideoId(widget.media.streamUrl ?? '');
    
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
  }

  @override
  void didUpdateWidget(LiveYoutubePlayerIFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.streamUrl != widget.media.streamUrl) {
      final newVideoId = Utility.extractYoutubeVideoId(widget.media.streamUrl ?? '');
      _controller.loadVideoById(videoId: newVideoId);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
    );
  }
}



