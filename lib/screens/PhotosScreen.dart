import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:higherground/widgets/ReadMoreText.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Photos.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/PhotosScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class PhotosScreen extends StatefulWidget {
  static const routeName = "/PhotosScreen";
  PhotosScreen();

  @override
  PhotosScreenRouteState createState() => new PhotosScreenRouteState();
}

class PhotosScreenRouteState extends State<PhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PhotosScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.photos,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          backgroundColor: MyColors.navBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 12),
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
  late PhotosScreensModel mediaScreensModel;
  List<Photos>? items;

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
      Provider.of<PhotosScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<PhotosScreensModel>(context);
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
      child: (mediaScreensModel.isError == true && (items?.isEmpty ?? true))
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : ListView.builder(
              itemCount: items!.length,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              itemBuilder: (BuildContext context, int index) {
                List<ImageProvider> links = [];
                for (var itms in items![index].media!) {
                  links.add(
                    Image.network(itms!).image,
                  );
                }
                return RoundedContainer(
                  //height: 50,
                  padding: EdgeInsets.only(top: 12),
                  margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(items![index].title!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(items![index].date!,
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      items![index].description == ""
                          ? Container()
                          : Container(
                              padding: EdgeInsets.all(12),
                              child: ReadMoreText(
                                items![index].description!,
                                style: TextStyle(fontSize: 15),
                                trimLines: 2,
                                colorClickableText: Colors.pink,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: t.readmore,
                                trimExpandedText: t.less,
                              ),
                            ),
                      Container(
                        height: 10,
                      ),
                      GalleryImageView(
                        width: double.infinity,
                        height: 150,
                        imageDecoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        listImage: links,
                        galleryType: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}



