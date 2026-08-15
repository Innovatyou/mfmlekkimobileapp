import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Playlists.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/providers/PlaylistsModel.dart';
import 'package:higherground/screens/PlaylistMediaScreen.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:provider/provider.dart';

class PlaylistsScreen extends StatefulWidget {
  static const routeName = '/myplaylists';
  @override
  MediaScreenRouteState createState() => MediaScreenRouteState();
}

class MediaScreenRouteState extends State<PlaylistsScreen> {
  late PlaylistsModel playlistsModel;
  late List<Playlists> items;

  void clearPlaylistsMedia(BuildContext context, int? id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(t.clearplaylistmedias),
          actions: <Widget>[
            TextButton(
              child: Text(t.cancel, style: const TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: Text(t.ok, style: const TextStyle(fontSize: 16)),
              onPressed: () {
                playlistsModel.deletePlaylistsMediaList(id);
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text(t.clearplaylistmediashint),
        );
      },
    );
  }

  void deletePlaylist(BuildContext context, int? id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(t.deletePlayList),
          actions: <Widget>[
            TextButton(
              child: Text(t.cancel, style: const TextStyle(fontSize: 16)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: Text(t.ok, style: const TextStyle(fontSize: 16)),
              onPressed: () {
                playlistsModel.deletePlaylists(id);
                Navigator.of(context).pop();
              },
            ),
          ],
          content: Text(t.deletePlayListhint),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    playlistsModel = Provider.of<PlaylistsModel>(context);
    items = playlistsModel.playlistsList;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.myplaylists,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0f172a),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Container(
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
                    )
                  : ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                      itemCount: items.length,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      itemBuilder: (BuildContext context, int index) {
                        final choices = [t.clearplaylistmedias, t.deletePlayList];
                        final playlists = items[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PlaylistMediaScreen.routeName,
                              arguments:
                                  ScreenArguements(position: 0, items: playlists),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE8DDE4)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              leading: SizedBox(
                                width: 44,
                                height: 44,
                                child: FutureBuilder<String?>(
                                  initialData: '',
                                  future: playlistsModel
                                      .getPlayListFirstMediaThumbnail(playlists.id),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String?> value) {
                                    if (value.data == null || value.data == '') {
                                      return Icon(
                                        Icons.music_note_rounded,
                                        size: 30,
                                        color: Colors.primaries[
                                            Random().nextInt(Colors.primaries.length)],
                                      );
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: value.data!,
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CupertinoActivityIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                playlists.title!,
                                maxLines: 1,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: FutureBuilder<int>(
                                initialData: 0,
                                future:
                                    playlistsModel.getPlaylistMediaCount(playlists.id),
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> value) {
                                  return Text(
                                    value.data == null
                                        ? '0 item'
                                        : '${value.data} item(s)',
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (BuildContext context) {
                                  return choices.map((itm) {
                                    return PopupMenuItem(
                                      value: itm,
                                      child: Text(itm),
                                    );
                                  }).toList();
                                },
                                onSelected: (dynamic value) {
                                  switch (choices.indexOf(value)) {
                                    case 0:
                                      clearPlaylistsMedia(context, playlists.id);
                                      break;
                                    case 1:
                                      deletePlaylist(context, playlists.id);
                                      break;
                                    default:
                                  }
                                },
                                icon: Icon(Icons.more_vert, color: Colors.grey[500]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
