import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:higherground/models/LiveStreams.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakelock/wakelock.dart';
import 'UnifiedLivePlayer.dart';

class LivestreamsPlayer extends StatefulWidget {
  static String routeName = "/livestreamsplayer";
  final LiveStreams? liveStreams;

  LivestreamsPlayer({Key? key, this.liveStreams}) : super(key: key);

  @override
  _VideoViewerScreenState createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<LivestreamsPlayer> {
  BetterPlayerController? _betterPlayerController;
  LiveStreams? currentMedia;
  Future<BetterPlayerController?>? reloadController;

  @override
  void initState() {
    currentMedia = widget.liveStreams;
    reloadController = playVideoStream();
    // The following line will enable the Android and iOS wakelock.
    Wakelock.enable();
    super.initState();
  }

  Future<BetterPlayerController?> playVideoStream() async {
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, currentMedia!.streamUrl!,
        videoFormat: BetterPlayerVideoFormat.hls);
    _betterPlayerController = new BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 3 / 2,
          placeholder: CachedNetworkImage(
            imageUrl: currentMedia!.coverphoto!,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                Center(child: CupertinoActivityIndicator()),
            errorWidget: (context, url, error) => Center(
                child: Icon(
              Icons.error,
              color: Colors.grey,
            )),
          ),
          autoPlay: true,
          allowedScreenSleep: false,
          fullScreenByDefault: true,
          // showControlsOnInitialize: true,
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    // _betterPlayerController.addEventsListener((event) {
    //print("Better player event: ${event.betterPlayerEventType}");
    // });
    return _betterPlayerController;
  }

  @override
  void dispose() {
    // The next line disables the wakelock again.
    Wakelock.disable();
    super.dispose();
  }

  Widget _buildWidgetAlbumCoverBlur() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.rectangle,
        image: DecorationImage(
          image: NetworkImage(currentMedia!.coverphoto!),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.liveStreams!.title!),
      ),
      body: Stack(
        children: <Widget>[
          _buildWidgetAlbumCoverBlur(),
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.5)
              ],
            )),
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: buildVideoContainer(currentMedia!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildVideoContainer(LiveStreams currentMedia) {
    // CRITICAL ROUTING: UnifiedLivePlayer intelligently routes based on stream source
    // - YouTube livestreams (type='youtube') → LiveYoutubePlayerIFrame
    // - HLS/RTMP streams (type='m3u8'/'rtmp') → LiveBetterPlayerWidget
    // - Facebook livestreams (type='facebook') → LiveFacebookPlayer
    // This prevents ExoPlaybackException errors from YouTube content
    return UnifiedLivePlayer(
      media: currentMedia,
      playerKey: UniqueKey(),
    );
  }
}


