import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/audio_player/radio_player.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Radios.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/RadioScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class RadioScreen extends StatefulWidget {
  static const routeName = "/RadioScreen";
  RadioScreen();

  @override
  RadioScreenRouteState createState() => new RadioScreenRouteState();
}

class RadioScreenRouteState extends State<RadioScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RadioScreensModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.radiostreams),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 12),
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
      child: (mediaScreensModel.isError == true && items!.length == 0)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : GridView.builder(
              itemCount: items!.length,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2),
              itemBuilder: (BuildContext context, int index) {
                Radios radios = items![index];
                return InkWell(
                  onTap: () {
                    Media media = new Media(
                        id: radios.id,
                        title: radios.title,
                        coverPhoto: radios.coverPhoto,
                        streamUrl: radios.streamUrl);
                    List<Media> medialist = [];
                    items!.forEach((element) {
                      medialist.add(Media(
                          id: element.id,
                          title: element.title,
                          coverPhoto: element.coverPhoto,
                          streamUrl: element.streamUrl));
                    });
                    Provider.of<AudioPlayerModel>(context, listen: false)
                        .prepareradioplayer(medialist, media);
                    Navigator.of(context).pushNamed(RadioPlayer.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
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
                              Center(child: CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) => Center(
                              child: Icon(
                            Icons.error,
                            color: Colors.grey,
                          )),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 70,
                            //width: double.infinity,
                            color: Colors.black54,
                            padding: EdgeInsets.all(12),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                radios.title!,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
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



