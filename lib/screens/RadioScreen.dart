import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/audio_player/radio_player.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/models/Radios.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/RadioScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RadioScreen extends StatefulWidget {
  static const routeName = '/RadioScreen';
  RadioScreen();

  @override
  RadioScreenRouteState createState() => RadioScreenRouteState();
}

class RadioScreenRouteState extends State<RadioScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RadioScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F2F5),
          surfaceTintColor: Colors.transparent,
          title: Text(
            t.radiostreams,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF23141D),
            ),
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
  MediaScreenRouteState createState() => MediaScreenRouteState();
}

class MediaScreenRouteState extends State<AudioScreenBody> {
  late RadioScreensModel mediaScreensModel;
  List<Radios>? items;

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
      Provider.of<RadioScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<RadioScreensModel>(context);
    items = mediaScreensModel.mediaList;

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(waterDropColor: Color(0xFF8E5972)),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore);
          } else if (mode == LoadStatus.loading) {
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore);
          } else {
            body = Text(t.nomoredata);
          }
          return SizedBox(height: 55, child: Center(child: body));
        },
      ),
      controller: mediaScreensModel.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (mediaScreensModel.isError == true && items!.isEmpty)
          ? NoitemScreen(
              title: t.oops,
              message: t.dataloaderror,
              onClick: _onRefresh,
            )
          : GridView.builder(
              itemCount: items!.length,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (BuildContext context, int index) {
                final radios = items![index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final media = Media(
                      id: radios.id,
                      title: radios.title,
                      coverPhoto: radios.coverPhoto,
                      streamUrl: radios.streamUrl,
                    );
                    final medialist = <Media>[];
                    for (final element in items!) {
                      medialist.add(
                        Media(
                          id: element.id,
                          title: element.title,
                          coverPhoto: element.coverPhoto,
                          streamUrl: element.streamUrl,
                        ),
                      );
                    }
                    Provider.of<AudioPlayerModel>(context, listen: false)
                        .prepareradioplayer(medialist, media);
                    Navigator.of(context).pushNamed(RadioPlayer.routeName);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8DDE4)),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: radios.coverPhoto!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const Center(child: CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 68,
                            color: const Color(0xA623141D),
                            padding: const EdgeInsets.all(10),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                radios.title!,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
