import 'package:flutter/material.dart';
import 'package:floating/floating.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube in-app player using youtube_player_iframe
/// Plays YouTube videos natively within the app instead of redirecting
class YoutubePlayerIFrame extends StatefulWidget {
  final Media media;

  const YoutubePlayerIFrame({required this.media, Key? key}) : super(key: key);

  @override
  State<YoutubePlayerIFrame> createState() => _YoutubePlayerIFrameState();
}

class _YoutubePlayerIFrameState extends State<YoutubePlayerIFrame> {
  late YoutubePlayerController _controller;
  // Embedded webview playback can't survive true backgrounding/lock (neither
  // Android WebView nor iOS WKWebView keep running JS-driven media, and
  // YouTube's own player pauses on visibility loss). Picture-in-Picture is the
  // one legitimate, ToS-compliant way to keep the video going while
  // multitasking — Android only, doesn't survive screen lock.
  final _floating = Floating();

  @override
  void initState() {
    super.initState();
    _initializeController();
    _floating.enable(const OnLeavePiP());
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
  void didUpdateWidget(YoutubePlayerIFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.streamUrl != widget.media.streamUrl) {
      final newVideoId = Utility.extractYoutubeVideoId(widget.media.streamUrl ?? '');
      _controller.loadVideoById(videoId: newVideoId);
    }
  }

  @override
  void dispose() {
    _floating.cancelOnLeavePiP();
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



