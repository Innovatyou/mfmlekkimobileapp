import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'dart:ui';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/MediaPlayerModel.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/widgets/MarqueeWidget.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'song_list_carousel.dart';
import 'package:provider/provider.dart';
import 'player_carousel.dart';
import 'package:higherground/widgets/MediaPopupMenu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlayPage extends StatefulWidget {
  static const routeName = "/playerpage";
  PlayPage();

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  AnimationController? controllerPlayer;
  late Animation<double> animationPlayer;
  // common tween removed (unused)
  Userdata? userdata;

  @override
  initState() {
    super.initState();
    userdata = Provider.of<AppStateManager>(context, listen: false).userdata;
    controllerPlayer = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    animationPlayer =
        new CurvedAnimation(parent: controllerPlayer!, curve: Curves.linear);
    animationPlayer.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controllerPlayer!.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controllerPlayer!.forward();
      }
    });
  }

  @override
  void dispose() {
    controllerPlayer!.dispose();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIMode([SystemUiOverlay.bottom]);
    AudioPlayerModel audioPlayerModel = Provider.of(context);
    if (audioPlayerModel.remoteAudioPlaying) {
      controllerPlayer!.forward();
    } else {
      controllerPlayer!.stop(canceled: false);
    }
    if (audioPlayerModel.currentMedia == null) {
      Navigator.of(context).pop();
    }
    return audioPlayerModel.currentMedia == null
        ? Container(
            color: Colors.black,
            child: Center(
              child: Text(
                "An Error Happened Here.",
                style: TextStyles.headline(context)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          )
        : ChangeNotifierProvider(
            create: (context) =>
                MediaPlayerModel(userdata, audioPlayerModel.currentMedia),
            child: Scaffold(
              body: Stack(
                children: <Widget>[
                  _buildWidgetAlbumCoverBlur(audioPlayerModel),
                  BuildPlayerBody(
                      userdata: userdata,
                      audioPlayerModel: audioPlayerModel,
                      controllerPlayer: controllerPlayer),
                ],
              ),
            ),
          );
  }

  Widget _buildWidgetAlbumCoverBlur(AudioPlayerModel audioPlayerModel) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.rectangle,
        image: DecorationImage(
          image: NetworkImage(audioPlayerModel.currentMedia!.coverPhoto!),
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
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class BuildPlayerBody extends StatelessWidget {
  const BuildPlayerBody({
    Key? key,
    required this.audioPlayerModel,
    required this.controllerPlayer,
    required this.userdata,
  }) : super(key: key);

  final AudioPlayerModel audioPlayerModel;
  final AnimationController? controllerPlayer;
  final Userdata? userdata;

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.yellow,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 40),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.cancel,
                      size: 30.0,
                      color: Colors.white,
                    ),
                    onPressed: () => {
                      Navigator.pop(context),
                    },
                  ),
                ),
                Container(
                  height: 20,
                ),
                !audioPlayerModel.showList
                    ? Container(
                        margin: EdgeInsets.only(left: 40, right: 40),
                        width: 400,
                        height: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: CachedNetworkImageProvider(
                                audioPlayerModel.currentMedia!.coverPhoto!),
                          ),
                        ),
                      )
                    : SongListCarousel(),
                Container(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: MarqueeWidget(
                      direction: Axis.horizontal,
                      child: Text(
                        audioPlayerModel.currentMedia!.title!,
                        maxLines: 1,
                        style: TextStyles.subhead(context).copyWith(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                Player(),
                Container(
                  height: 20,
                ),
                Container(
                  //color: Colors.yellow,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AddPlaylistScreen.routeName,
                            arguments: ScreenArguements(
                                position: 0,
                                items: audioPlayerModel.currentMedia),
                          );
                        },
                        icon: Icon(
                          Icons.playlist_add_sharp,
                          size: 30,
                          color: Colors.blue[700],
                        ),
                      ),
                      Consumer<BookmarksModel>(
                        builder: (context, bookmarkmodel, child) {
                          bool isBookmarked = bookmarkmodel
                              .isMediaBookmarked(audioPlayerModel.currentMedia);
                          return IconButton(
                            onPressed: () {
                              if (isBookmarked) {
                                bookmarkmodel.unBookmarkMedia(
                                    audioPlayerModel.currentMedia!);
                              } else {
                                bookmarkmodel.bookmarkMedia(
                                    audioPlayerModel.currentMedia!);
                              }
                            },
                            icon: Icon(
                              isBookmarked
                                  ? LineAwesomeIcons.heart_1
                                  : LineAwesomeIcons.heart,
                              size: 30,
                              color: isBookmarked ? Colors.pink : Colors.white,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          ShareFile.share(audioPlayerModel.currentMedia!);
                        },
                        icon: Icon(
                          LineAwesomeIcons.share,
                          size: 30,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () => audioPlayerModel.changeRepeat(),
                        icon: audioPlayerModel.isRepeat == true
                            ? Icon(
                                Icons.repeat_one,
                                size: 30.0,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.repeat,
                                size: 30.0,
                                color: Colors.white,
                              ),
                      ),
                      Visibility(
                        visible: Utility.showDownloadButton(
                            context, audioPlayerModel.currentMedia!),
                        child: Consumer<DownloadsModel>(
                          builder: (context, downloadsModel, child) {
                            Downloads? _dd = downloadsModel.isMediaInDownloads(
                                audioPlayerModel.currentMedia!.id);
                            return _dd != null
                                ? Container()
                                : IconButton(
                                    onPressed: () {
                                      Downloads downloads =
                                          Downloads.mapCurrentDownloadMedia(
                                              audioPlayerModel.currentMedia!);
                                      Navigator.pushNamed(
                                          context, Downloader.routeName,
                                          arguments: ScreenArguements(
                                            position: 0,
                                            items: downloads,
                                          ));
                                    },
                                    icon: Icon(
                                      LineAwesomeIcons.download,
                                      size: 30,
                                      color: Colors.orange[700],
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MediaCommentsLikesContainer extends StatefulWidget {
  const MediaCommentsLikesContainer({
    Key? key,
    required this.context,
    required this.currentMedia,
    required this.audioPlayerModel,
  }) : super(key: key);

  final BuildContext context;
  final Media? currentMedia;
  final AudioPlayerModel audioPlayerModel;

  @override
  _MediaCommentsLikesContainerState createState() =>
      _MediaCommentsLikesContainerState();
}

class _MediaCommentsLikesContainerState
    extends State<MediaCommentsLikesContainer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MediaPlayerModel>(
      builder: (context, mediaPlayerModel, child) {
        return Container(
          height: 50,
          margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              InkWell(
                onTap: () {
                  mediaPlayerModel
                      .likePost(mediaPlayerModel.isLiked! ? "unlike" : "like");
                },
                child: Row(children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
                    child: FaIcon(FontAwesomeIcons.thumbsUp,
                        size: 26,
                        color: mediaPlayerModel.isLiked!
                            ? Colors.pink
                            : Colors.white),
                  ),
                  mediaPlayerModel.likesCount == 0
                      ? Container()
                      : Text(mediaPlayerModel.likesCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                ]),
              ),
              InkWell(
                onTap: () {
                  mediaPlayerModel.navigatetoCommentsScreen(context);
                },
                child: Row(
                  children: <Widget>[
                    Icon(Icons.insert_comment, size: 26, color: Colors.white),
                    mediaPlayerModel.commentsCount == 0
                        ? Container()
                        : Text(mediaPlayerModel.commentsCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.audioPlayerModel.shufflePlaylist();
                  Provider.of<MediaPlayerModel>(context, listen: false)
                      .setMediaLikesCommentsCount(
                          widget.audioPlayerModel.currentMedia!);
                },
                icon: Icon(
                  Icons.shuffle,
                  size: 26.0,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => widget.audioPlayerModel
                    .setShowList(!widget.audioPlayerModel.showList),
                icon: Icon(
                  Icons.playlist_play,
                  size: 27.0,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => widget.audioPlayerModel.changeRepeat(),
                icon: widget.audioPlayerModel.isRepeat == true
                    ? Icon(
                        Icons.repeat_one,
                        size: 26.0,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.repeat,
                        size: 26.0,
                        color: Colors.white,
                      ),
              ),
              MediaPopupMenu(widget.currentMedia),
            ],
          ),
        );
      },
    );
  }
}



