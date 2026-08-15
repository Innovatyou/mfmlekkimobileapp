import 'package:flutter/material.dart';
import 'package:higherground/audio_player/player_page.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Downloads.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/providers/DownloadsModel.dart';
import 'package:higherground/screens/AddPlaylistScreen.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/video_player/VideoPlayer.dart';
import 'package:higherground/widgets/MediaPopupMenu.dart';
import 'package:isolated_download_manager/isolated_download_manager.dart';
import 'package:provider/provider.dart';

class Downloader extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform? platform;
  static const routeName = '/DownloadsScreen';
  final Downloads? downloads;

  const Downloader({Key? key, this.downloads, this.platform}) : super(key: key);

  @override
  State<Downloader> createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader> {
  DownloadsModel? downloadsModel;
  final TextEditingController inputController = TextEditingController();
  bool showClear = false;
  String filter = '';

  @override
  void initState() {
    super.initState();
    inputController.addListener(() {
      final value = inputController.text;
      setState(() {
        filter = value;
        showClear = value.trim().isNotEmpty;
      });
    });
    Provider.of<DownloadsModel>(context, listen: false)
        .initDownloads(context, widget.downloads);
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    downloadsModel = Provider.of<DownloadsModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.downloads,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0f172a),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8DDE4)),
              ),
              child: TextField(
                controller: inputController,
                maxLines: 1,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0f172a)),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: t.search,
                  hintStyle:
                      const TextStyle(fontSize: 15.5, color: Color(0xFF8A7B86)),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF8A7B86)),
                  suffixIcon: showClear
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            inputController.clear();
                            setState(() {
                              filter = '';
                              showClear = false;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: BuildBodyPage(downloadsModel: downloadsModel, filter: filter),
          ),
        ],
      ),
    );
  }
}

class BuildBodyPage extends StatelessWidget {
  const BuildBodyPage({
    Key? key,
    required this.downloadsModel,
    required this.filter,
  }) : super(key: key);

  final DownloadsModel? downloadsModel;
  final String filter;

  @override
  Widget build(BuildContext context) {
    final normalizedFilter = filter.trim().toLowerCase();
    final items = downloadsModel!.downloadsList.where((item) {
      if (normalizedFilter.isEmpty) return true;
      final title = item.title?.toLowerCase() ?? '';
      return title.contains(normalizedFilter);
    }).toList();

    if (items.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8DDE4)),
          ),
          child: Text(
            t.noitemstodisplay,
            textAlign: TextAlign.center,
            style: TextStyles.medium(context),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        return ItemTile(
          object: items[index],
          downloadsModel: downloadsModel!,
        );
      },
    );
  }
}

class ItemTile extends StatelessWidget {
  final Downloads object;
  final DownloadsModel downloadsModel;

  const ItemTile({
    Key? key,
    required this.object,
    required this.downloadsModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = Downloads.mapMediaFromDownload(object);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (object.state == DownloadState.finished) {
          _openMedia(context, object, downloadsModel);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverImage(object.coverPhoto),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              TimUtil.timeFormatter(object.duration ?? 0),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${object.viewsCount ?? 0} view(s)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          object.title ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            object.state == DownloadState.finished
                ? _buildFinishedActions(context, media)
                : _buildProgressActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 104,
        height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.music_note_rounded, color: Color(0xFF8A7B86)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 104,
        height: 88,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFinishedActions(BuildContext context, Media media) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AddPlaylistScreen.routeName,
                arguments: ScreenArguements(position: 0, items: object),
              );
            },
            icon: Icon(Icons.playlist_add_rounded, color: Colors.grey[700]),
          ),
          IconButton(
            onPressed: () {
              downloadsModel.deleteExistingMedia(object.id);
            },
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red[700]),
          ),
          Consumer<BookmarksModel>(
            builder: (context, bookmarkModel, child) {
              final isBookmarked = bookmarkModel.isMediaBookmarked(media);
              return IconButton(
                onPressed: () {
                  if (isBookmarked) {
                    bookmarkModel.unBookmarkMedia(media);
                  } else {
                    bookmarkModel.bookmarkMedia(media);
                  }
                },
                icon: Icon(
                  isBookmarked ? Icons.favorite_rounded : Icons.favorite_border,
                  color: isBookmarked ? Colors.pink : Colors.grey[700],
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ShareFile.share(media);
            },
            icon: const Icon(Icons.share_rounded, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressActions() {
    final isQueued = object.state == DownloadState.queued;
    final isPaused = object.state == DownloadState.paused;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 7,
              child: isQueued
                  ? const LinearProgressIndicator(
                      backgroundColor: Colors.orangeAccent,
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                    )
                  : LinearProgressIndicator(value: (object.progress ?? 0) / 100),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: () {
              if (isPaused) {
                downloadsModel.resumeDownload(object);
              } else {
                downloadsModel.pauseDownload(object);
              }
            },
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () async {
              downloadsModel.deleteItem(object);
            },
            icon:
                const Icon(Icons.delete_forever_rounded, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _openMedia(
      BuildContext context, Downloads object, DownloadsModel downloadsModel) {
    if ((object.mediaType ?? '').toLowerCase() == 'audio') {
      Provider.of<AudioPlayerModel>(context, listen: false).preparePlaylist(
        Downloads.mapMediaListFromDownloadList(downloadsModel.downloadsList),
        Downloads.mapMediaFromDownload(object),
      );
      Navigator.of(context).pushNamed(PlayPage.routeName);
      return;
    }

    Navigator.pushNamed(
      context,
      VideoPlayer.routeName,
      arguments: ScreenArguements(
        position: 0,
        items: Downloads.mapMediaFromDownload(object),
        itemsList: Utility.extractMediaByType(
          Downloads.mapMediaListFromDownloadList(downloadsModel.downloadsList),
          object.mediaType,
        ),
      ),
    );
  }
}
