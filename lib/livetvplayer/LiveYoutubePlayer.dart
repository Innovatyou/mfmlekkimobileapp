import 'package:flutter/material.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/video_player/YoutubePlayerPlaceholder.dart';

class LiveYoutubePlayer extends StatelessWidget {
  final LiveStreams media;
  const LiveYoutubePlayer({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerPlaceholder(
      streamUrl: media.streamUrl,
      title: media.title,
    );
  }
}



