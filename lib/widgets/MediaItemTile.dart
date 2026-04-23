import 'package:flutter/material.dart';
import 'package:higherground/audio_player/player_page.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:higherground/video_player/VideoPlayer.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/widgets/MediaPopupMenu.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/utils/Utility.dart';

class ItemTile extends StatefulWidget {
  final Media object;
  final List<Media> mediaList;
  final int index;

  const ItemTile({
    Key? key,
    required this.mediaList,
    required this.index,
    required this.object,
  }) : super(key: key);

  @override
  _ItemTileState createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.object.mediaType!.toLowerCase() == "audio") {
          Provider.of<AudioPlayerModel>(context, listen: false).preparePlaylist(
              Utility.extractMediaByType(
                  widget.mediaList, widget.object.mediaType),
              widget.object);
          Navigator.of(context).pushNamed(PlayPage.routeName);
        } else {
          Navigator.pushNamed(context, VideoPlayer.routeName,
              arguments: ScreenArguements(
                position: 0,
                items: widget.object,
                itemsList: Utility.extractMediaByType(
                    widget.mediaList, widget.object.mediaType),
              ));
        }
      },
      child: RoundedContainer(
        padding: const EdgeInsets.all(0),
        margin: EdgeInsets.all(10),
        height: 130,
        child: Row(
          children: <Widget>[
            widget.object.coverPhoto! == ""
                ? Container()
                : Container(
                    width: 130,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: NetworkImage(Utility.convertLocalhostToEmulator(widget.object.coverPhoto)),
                      fit: BoxFit.cover,
                    )),
                  ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      //color: Colors.blue,
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Text(TimUtil.timeFormatter(widget.object.duration!),
                              style: TextStyles.caption(context)
                              //.copyWith(color: MyColors.grey_60),
                              ),
                          Spacer(),
                          Text(
                            widget.object.viewsCount.toString() + " view(s)",
                            style: TextStyles.caption(
                              context,
                            ).copyWith(fontSize: 10),
                          ),
                          Container(
                            width: 12,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.object.title!,
                          overflow: TextOverflow.fade,
                          maxLines: 3,
                          softWrap: true,
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Visibility(
                          visible: Utility.showDownloadButton(
                              context, widget.object),
                          child: Consumer<DownloadsModel>(
                            builder: (context, downloadsModel, child) {
                              Downloads? _dd = downloadsModel
                                  .isMediaInDownloads(widget.object.id);
                              return _dd != null
                                  ? Container()
                                  : IconButton(
                                      onPressed: () {
                                        Downloads downloads =
                                            Downloads.mapCurrentDownloadMedia(
                                                widget.object);
                                        Navigator.pushNamed(
                                            context, Downloader.routeName,
                                            arguments: ScreenArguements(
                                              position: 0,
                                              items: downloads,
                                            ));
                                      },
                                      icon: Icon(
                                        LineAwesomeIcons.download,
                                        size: 20,
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
                              arguments: ScreenArguements(
                                  position: 0, items: widget.object),
                            );
                          },
                          icon: Icon(
                            Icons.playlist_add_sharp,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                        Consumer<BookmarksModel>(
                          builder: (context, bookmarkmodel, child) {
                            bool isBookmarked =
                                bookmarkmodel.isMediaBookmarked(widget.object);
                            return IconButton(
                              onPressed: () {
                                if (isBookmarked) {
                                  bookmarkmodel.unBookmarkMedia(widget.object);
                                } else {
                                  bookmarkmodel.bookmarkMedia(widget.object);
                                }
                              },
                              icon: Icon(
                                isBookmarked
                                    ? LineAwesomeIcons.heart_1
                                    : LineAwesomeIcons.heart,
                                size: 20,
                                color: isBookmarked
                                    ? Colors.pink
                                    : Colors.grey[700],
                              ),
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            ShareFile.share(widget.object);
                          },
                          icon: Icon(
                            LineAwesomeIcons.share,
                            size: 20,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



