import 'package:flutter/material.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/video_player/YoutubePlayerPlaceholder.dart';

class YoutubeVideoPlayer extends StatelessWidget {
  final Media media;
  YoutubeVideoPlayer({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerPlaceholder(
      streamUrl: media.streamUrl,
      title: media.title,
    );
  }
}


