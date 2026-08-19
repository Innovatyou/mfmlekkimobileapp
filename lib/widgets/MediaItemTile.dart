import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/audio_player/player_page.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/video_player/VideoPlayer.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
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
    final bool isAudio = widget.object.mediaType!.toLowerCase() == 'audio';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (isAudio) {
              Provider.of<AudioPlayerModel>(context, listen: false)
                  .preparePlaylist(
                Utility.extractMediaByType(
                    widget.mediaList, widget.object.mediaType),
                widget.object,
              );
              Navigator.of(context).pushNamed(PlayPage.routeName);
            } else {
              Navigator.pushNamed(
                context,
                VideoPlayer.routeName,
                arguments: ScreenArguements(
                  position: 0,
                  items: widget.object,
                  itemsList: Utility.extractMediaByType(
                      widget.mediaList, widget.object.mediaType),
                ),
              );
            }
          },
          child: Container(
            height: 112,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: MyColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                // Cover thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(9),
                  ),
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: (widget.object.coverPhoto == null ||
                            widget.object.coverPhoto!.isEmpty)
                        ? Container(
                            color: MyColors.primaryVeryLight,
                            alignment: Alignment.center,
                            child: Icon(
                              isAudio
                                  ? LineAwesomeIcons.music
                                  : LineAwesomeIcons.play_circle,
                              color: MyColors.primary,
                              size: 32,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: Utility.convertLocalhostToEmulator(
                                widget.object.coverPhoto),
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: MyColors.surface),
                            errorWidget: (_, __, ___) => Container(
                              color: MyColors.primaryVeryLight,
                              alignment: Alignment.center,
                              child: Icon(
                                isAudio
                                    ? LineAwesomeIcons.music
                                    : LineAwesomeIcons.play,
                                color: MyColors.primary,
                                size: 28,
                              ),
                            ),
                          ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.object.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0f172a),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Duration
                        Text(
                          widget.object.duration != null
                              ? TimUtil.timeFormatter(widget.object.duration!)
                              : '',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Action row
                        Row(
                          children: [
                            Text(
                              '${widget.object.viewsCount ?? 0} views',
                              style: const TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: Utility.showDownloadButton(
                                  context, widget.object),
                              child: Consumer<DownloadsModel>(
                                builder: (context, downloadsModel, child) {
                                  Downloads? dd = downloadsModel
                                      .isMediaInDownloads(widget.object.id);
                                  return dd != null
                                      ? const SizedBox.shrink()
                                      : _ActionIcon(
                                          icon: LineAwesomeIcons.download,
                                          color: MyColors.primary,
                                          onTap: () {
                                            Downloads downloads =
                                                Downloads.mapCurrentDownloadMedia(
                                                    widget.object);
                                            Navigator.pushNamed(
                                              context,
                                              Downloader.routeName,
                                              arguments: ScreenArguements(
                                                position: 0,
                                                items: downloads,
                                              ),
                                            );
                                          },
                                        );
                                },
                              ),
                            ),
                            _ActionIcon(
                              icon: Icons.playlist_add_sharp,
                              color: MyColors.textSecondary,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AddPlaylistScreen.routeName,
                                  arguments: ScreenArguements(
                                      position: 0, items: widget.object),
                                );
                              },
                            ),
                            Consumer<BookmarksModel>(
                              builder: (context, bookmarkmodel, child) {
                                bool isBookmarked =
                                    bookmarkmodel.isMediaBookmarked(widget.object);
                                return _ActionIcon(
                                  icon: isBookmarked
                                      ? LineAwesomeIcons.heart_1
                                      : LineAwesomeIcons.heart,
                                  color: isBookmarked
                                      ? MyColors.danger
                                      : MyColors.textSecondary,
                                  onTap: () {
                                    if (isBookmarked) {
                                      bookmarkmodel
                                          .unBookmarkMedia(widget.object);
                                    } else {
                                      bookmarkmodel.bookmarkMedia(widget.object);
                                    }
                                  },
                                );
                              },
                            ),
                            _ActionIcon(
                              icon: LineAwesomeIcons.share,
                              color: MyColors.success,
                              onTap: () {
                                ShareFile.share(widget.object);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
