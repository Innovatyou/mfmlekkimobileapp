import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/providers/BookScreensModel.dart';
import 'package:higherground/screens/BooksViewerScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Books.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class BooksScreen extends StatefulWidget {
  static const routeName = "/BooksScreen";
  BooksScreen();

  @override
  BooksScreenRouteState createState() => new BooksScreenRouteState();
}

class BooksScreenRouteState extends State<BooksScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F2F5),
          surfaceTintColor: Colors.transparent,
          title: Text(
            t.books,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF0f172a),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 4),
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
  late BookScreensModel mediaScreensModel;
  List<Books>? items;

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
      Provider.of<BookScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<BookScreensModel>(context);
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
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8),
              itemBuilder: (BuildContext context, int index) {
                final books = items![index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pushNamed(context, BooksViewerScreen.routeName,
                        arguments: books);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
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
                            imageUrl: books.thumbnail!,
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
                              height: 72,
                              color: const Color(0xA60f172a),
                              padding: const EdgeInsets.all(12),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  books.title!,
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
                  ),
                );
              },
            ),
    );
  }
}



