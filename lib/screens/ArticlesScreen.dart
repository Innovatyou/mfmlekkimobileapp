import 'package:flutter/material.dart';
import 'package:higherground/providers/ArticlesScreensModel.dart';
import 'package:higherground/screens/ArticleViewer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class ArticlesScreen extends StatefulWidget {
  static const routeName = "/ArticlesScreen";
  ArticlesScreen();

  @override
  ArticlesScreenRouteState createState() => new ArticlesScreenRouteState();
}

class ArticlesScreenRouteState extends State<ArticlesScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArticlesScreensModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(t.articles),
          elevation: 1,
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 5),
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
  late ArticlesScreensModel mediaScreensModel;
  List<Articles>? items;
  var titleTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );

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
      Provider.of<ArticlesScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<ArticlesScreensModel>(context);
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
          : ListView.separated(
              itemCount: items!.length,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                Articles articles = items![index];
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, ArticleViewer.routeName,
                        arguments: articles);
                  },
                  title: Text(
                    articles.title!,
                    maxLines: 2,
                    style: titleTextStyle,
                  ),
                  subtitle: Text(articles.date! + " | " + articles.author!),
                  trailing: Container(
                    width: 80.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(articles.thumbnail!),
                          fit: BoxFit.cover,
                        )),
                  ),
                );
              },
            ),
    );
  }
}



