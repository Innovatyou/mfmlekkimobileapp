import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/livetvplayer/LivestreamsPlayer.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/LivestreamScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/Utility.dart';

class LivestreamsScreen extends StatefulWidget {
  static const routeName = "/LivestreamsScreen";
  LivestreamsScreen();

  @override
  LivestreamsScreenRouteState createState() =>
      new LivestreamsScreenRouteState();
}

class LivestreamsScreenRouteState extends State<LivestreamsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LivestreamScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          title: Text(
            t.livestreams,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AudioScreenBody(),
        ),
      ),
    );
  }
}

class AudioScreenBody extends StatefulWidget {
  @override
  MediaScreenRouteState createState() => new MediaScreenRouteState();
}

class MediaScreenRouteState extends State<AudioScreenBody> {
  late LivestreamScreensModel mediaScreensModel;
  List<LiveStreams>? items;

  void _onRefresh() async {
    mediaScreensModel.loadItems();
  }

  void _onLoading() async {
    mediaScreensModel.loadMoreItems();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      Provider.of<LivestreamScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<LivestreamScreensModel>(context);
    items = mediaScreensModel.mediaList;

    final bool hasItems = items != null && items!.isNotEmpty;

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore);
          } else {
            body = Text(t.nomoredata);
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: mediaScreensModel.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (mediaScreensModel.isError == true && !hasItems)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : (!hasItems)
              ? _buildEmptyState()
              : ListView.separated(
              itemCount: items!.length,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                LiveStreams liveStreams = items![index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (liveStreams.type == "") {
                    } else {
                      Navigator.of(context)
                          .pushNamed(LivestreamsPlayer.routeName,
                              arguments: ScreenArguements(
                                position: 0,
                                items: liveStreams,
                                itemsList: [],
                              ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8DDE4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: Utility.convertLocalhostToEmulator(liveStreams.coverphoto),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(
                                      Icons.live_tv_rounded,
                                      color: Color(0xFF475569),
                                      size: 34,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Text(
                            liveStreams.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0f172a),
                              fontSize: 16,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.live_tv_rounded,
              size: 42,
              color: Color(0xFF8A7D86),
            ),
            const SizedBox(height: 10),
            Text(
              t.noitemstodisplay,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0f172a),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No current live stream. Pull down to check for newly streamed videos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



