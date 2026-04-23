import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/models/Books.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/ArticleViewer.dart';
import 'package:higherground/screens/ArticlesScreen.dart';
import 'package:higherground/screens/BooksScreen.dart';
import 'package:higherground/screens/BooksViewerScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

class PublicationsPage extends StatefulWidget {
  @override
  State<PublicationsPage> createState() => _PublicationsPageState();
}

class _PublicationsPageState extends State<PublicationsPage> {
  late DashboardModel dashboardModel;
  var titleTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 12, right: 12, top: 12),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Visibility(
                visible: dashboardModel.isFeatureAvailable("books") &&
                    dashboardModel.recentbooks.length > 0,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          t.books,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600),
                        ),
                      ),
                      MaterialButton(
                        elevation: 0,
                        textColor: Colors.white,
                        color: MyColors.mainC0lor,
                        height: 0,
                        child: Icon(Icons.keyboard_arrow_right),
                        minWidth: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(BooksScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: dashboardModel.isFeatureAvailable("books") &&
                      dashboardModel.recentbooks.length > 0,
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (dashboardModel.isFeatureAvailable("articles") &&
                            dashboardModel.recentbooks.length > 0)
                        ? 2
                        : dashboardModel.recentbooks.length,
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(3),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 6.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.8),
                    itemBuilder: (BuildContext context, int index) {
                      Books books = dashboardModel.recentbooks[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, BooksViewerScreen.routeName,
                              arguments: books);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: books.thumbnail!,
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
                                      books.title!,
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
                  )),
              const SizedBox(height: 12.0),
              Visibility(
                visible: dashboardModel.isFeatureAvailable("articles"),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 15, right: 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          t.recentarticles,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600),
                        ),
                      ),
                      MaterialButton(
                        elevation: 0,
                        textColor: Colors.white,
                        color: MyColors.mainC0lor,
                        height: 0,
                        child: Icon(Icons.keyboard_arrow_right),
                        minWidth: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(ArticlesScreen.routeName);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              const SizedBox(height: 10.0),
              Visibility(
                visible: dashboardModel.isFeatureAvailable("articles"),
                child: ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 0, right: 0, top: 4),
                  itemCount: dashboardModel.recentarticles.length,
                  itemBuilder: (context, index) {
                    Articles articles = dashboardModel.recentarticles[index];
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
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



