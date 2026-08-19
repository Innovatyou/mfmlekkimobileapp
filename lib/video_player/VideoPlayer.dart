import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
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
import 'package:higherground/utils/TimUtil.dart';
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
    _toggleWakelock(true);
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
    _toggleWakelock(false);
    super.dispose();
  }

  Future<void> _toggleWakelock(bool enabled) async {
    try {
      await Wakelock.toggle(enable: enabled);
    } catch (e) {
      debugPrint('Wakelock toggle failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MediaPlayerModel(userdata, widget.media),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          title: const Text(
            'Video Player',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildVideoContainer(currentMedia!),
                _buildMetaSection(),
                if ((currentMedia?.description ?? '').trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8DDE4)),
                    ),
                    child: Text(
                      currentMedia!.description!,
                      style: const TextStyle(
                        color: Color(0xFF6F616A),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Text(
                    'Up Next',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                if (playlist.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: EmptyListScreen(message: t.emptyplaylist),
                  )
                else
                  ListView.separated(
                    itemCount: playlist.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final media = playlist[index]!;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => playVideoItem(media),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8DDE4)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 120,
                                  height: 68,
                                  child: CachedNetworkImage(
                                    imageUrl: Utility.convertLocalhostToEmulator(
                                        media.coverPhoto),
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.ondemand_video_rounded,
                                      color: Color(0xFF8A7D86),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  media.title ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0f172a),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
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

  Widget _buildMetaSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            currentMedia?.title ?? '',
            style: const TextStyle(
              color: Color(0xFF0f172a),
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${currentMedia?.viewsCount ?? 0} views',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                TimUtil.timeFormatter(currentMedia?.duration ?? 0),
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF475569),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDE4EA)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: Utility.showDownloadButton(context, currentMedia!),
                child: Consumer<DownloadsModel>(
                  builder: (context, downloadsModel, child) {
                    Downloads? _dd =
                        downloadsModel.isMediaInDownloads(currentMedia!.id);
                    return _dd != null
                        ? const SizedBox.shrink()
                        : IconButton(
                            onPressed: () {
                              Downloads downloads =
                                  Downloads.mapCurrentDownloadMedia(
                                      currentMedia!);
                              Navigator.pushNamed(context, Downloader.routeName,
                                  arguments: ScreenArguements(
                                    position: 0,
                                    items: downloads,
                                  ));
                            },
                            icon: Icon(
                              LineAwesomeIcons.download,
                              size: 24,
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
                    arguments: ScreenArguements(position: 0, items: currentMedia!),
                  );
                },
                icon: Icon(
                  Icons.playlist_add_sharp,
                  size: 24,
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
                      size: 24,
                      color: isBookmarked ? Colors.pink : Colors.grey[700],
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  ShareFile.share(currentMedia!);
                },
                icon: const Icon(
                  LineAwesomeIcons.share,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



