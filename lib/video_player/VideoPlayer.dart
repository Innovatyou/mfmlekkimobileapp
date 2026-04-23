import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/utils/MarqueeWidget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:higherground/widgets/MediaPopupMenu.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'UnifiedVideoPlayer.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:wakelock/wakelock.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:better_player/better_player.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'package:higherground/widgets/VideoItemTile.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/MediaPlayerModel.dart';

class VideoPlayer extends StatefulWidget {
  static const routeName = "/videoplayer";
  VideoPlayer({this.media, this.mediaList});
  final Media? media;
  final List<Media?>? mediaList;

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer>
    with TickerProviderStateMixin {
  Userdata? userdata;
  bool isUserSubscribed = false;
  List<Media?> playlist = [];
  bool expand1 = false;
  late AnimationController controller1;
  Animation<double>? animation1, animation1View;
  BetterPlayerController? _betterPlayerController;
  Media? currentMedia;
  Future<BetterPlayerController?>? reloadController;

  @override
  void initState() {
    Wakelock.enable();
    currentMedia = widget.media;
    userdata = Provider.of<AppStateManager>(context, listen: false).userdata;
    controller1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    animation1 = Tween(begin: 0.0, end: 180.0).animate(controller1);
    animation1View = CurvedAnimation(parent: controller1, curve: Curves.linear);

    playlist =
        Utility.removeCurrentMediaFromList(widget.mediaList!, widget.media);

    // CRITICAL: Only initialize BetterPlayer for non-YouTube videos
    // YouTube videos are handled by UnifiedVideoPlayer → YoutubePlayerIFrame
    // If we initialize BetterPlayer for YouTube IDs, ExoPlayer crashes trying to open them as files
    if (!Utility.isYouTubeVideo(currentMedia!.streamUrl, currentMedia!.videoType)) {
      reloadController = playVideoStream();
    }
    Utility.updatemediatotalviews(currentMedia!.id!);
    super.initState();
  }

  playVideoItem(Media media) {
    setState(() {
      playlist = Utility.removeCurrentMediaFromList(widget.mediaList!, media);
      currentMedia = media;
      _betterPlayerController?.pause();
      if (currentMedia!.videoType == "mp4_video" ||
          currentMedia!.videoType == "video_link" ||
          currentMedia!.videoType == "mpd_video" ||
          currentMedia!.videoType == "m3u8_video") {
        reloadController = playVideoStream();
      }
    });
    Utility.updatemediatotalviews(currentMedia!.id!);
  }

  Future<BetterPlayerController?> playVideoStream() async {
    print("link==" + currentMedia!.streamUrl!);
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        currentMedia!.http!
            ? BetterPlayerDataSourceType.network
            : BetterPlayerDataSourceType.file,
        currentMedia!.streamUrl!);
    _betterPlayerController = new BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 3 / 2,
          placeholder: CachedNetworkImage(
            imageUrl: Utility.convertLocalhostToEmulator(currentMedia!.coverPhoto),
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
          // showControlsOnInitialize: true,
        ),
        betterPlayerDataSource: betterPlayerDataSource);
    _betterPlayerController!.addEventsListener((event) {
      if (!mounted) return;
      print("Better player event: ${event.betterPlayerEventType}");
    });

    return _betterPlayerController;
  }

  void togglePanel1() {
    if (!expand1) {
      controller1.forward();
    } else {
      controller1.reverse();
    }
    expand1 = !expand1;
  }

  @override
  void dispose() {
    controller1.dispose();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MediaPlayerModel(userdata, widget.media),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: MarqueeWidget(child: Text(currentMedia!.title!)),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Video player - Flexible height to prevent overflow
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: buildVideoContainer(currentMedia!),
                ),
              ),
              getInfoContainer(),
              (playlist.length == 0)
                  ? Expanded(
                      child: EmptyListScreen(
                        message: t.emptyplaylist,
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: playlist.length,
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(3),
                        itemBuilder: (BuildContext context, int index) {
                          return VideoItemTile(
                            onclick: playVideoItem,
                            object: playlist[index]!,
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVideoContainer(Media currentMedia) {
    // CRITICAL ROUTING: UnifiedVideoPlayer intelligently routes based on video source
    // - YouTube videos (detected by videoType or URL) → youtube_player_iframe
    // - All others (MP4, HLS, DASH, streams) → BetterPlayer/ExoPlayer
    // This prevents ExoPlaybackException errors from YouTube content reaching BetterPlayer
    return UnifiedVideoPlayer(
      media: currentMedia,
      playerKey: UniqueKey(),
    );
  }

  Widget getInfoContainer() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
      // height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              height: 30,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Visibility(
                    visible: Utility.showDownloadButton(context, currentMedia!),
                    child: Consumer<DownloadsModel>(
                      builder: (context, downloadsModel, child) {
                        Downloads? _dd =
                            downloadsModel.isMediaInDownloads(currentMedia!.id);
                        return _dd != null
                            ? Container()
                            : IconButton(
                                onPressed: () {
                                  Downloads downloads =
                                      Downloads.mapCurrentDownloadMedia(
                                          currentMedia!);
                                  Navigator.pushNamed(
                                      context, Downloader.routeName,
                                      arguments: ScreenArguements(
                                        position: 0,
                                        items: downloads,
                                      ));
                                },
                                icon: Icon(
                                  LineAwesomeIcons.download,
                                  size: 25,
                                  color: Colors.purple[700],
                                ),
                              );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AddPlaylistScreen.routeName,
                        arguments:
                            ScreenArguements(position: 0, items: currentMedia!),
                      );
                    },
                    icon: Icon(
                      Icons.playlist_add_sharp,
                      size: 25,
                      color: Colors.grey[700],
                    ),
                  ),
                  Consumer<BookmarksModel>(
                    builder: (context, bookmarkmodel, child) {
                      bool isBookmarked =
                          bookmarkmodel.isMediaBookmarked(currentMedia!);
                      return IconButton(
                        onPressed: () {
                          if (isBookmarked) {
                            bookmarkmodel.unBookmarkMedia(currentMedia!);
                          } else {
                            bookmarkmodel.bookmarkMedia(currentMedia!);
                          }
                        },
                        icon: Icon(
                          isBookmarked
                              ? LineAwesomeIcons.heart_1
                              : LineAwesomeIcons.heart,
                          size: 25,
                          color: isBookmarked ? Colors.pink : Colors.grey[700],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      ShareFile.share(currentMedia!);
                    },
                    icon: Icon(
                      LineAwesomeIcons.share,
                      size: 25,
                      color: Colors.green,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}



