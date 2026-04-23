import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ArticleViewer extends StatefulWidget {
  static const routeName = "articlesviewer";
  ArticleViewer({this.articles});
  final Articles? articles;

  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.articles),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.share(
                Bidi.stripHtmlIfNeeded(widget.articles!.content!),
                subject: widget.articles!.title,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                height: 300,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.articles!.thumbnail!,
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
                      child: Image.asset(
                    Img.get("articles.jpg"),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    //color: Colors.black26,
                  )),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(16.0, 250.0, 16.0, 16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0)),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.articles!.title!,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      widget.articles!.date! +
                          " " +
                          t.by +
                          " " +
                          widget.articles!.author!,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10.0),
                    Divider(),
                    SizedBox(
                      height: 10.0,
                    ),
                    HtmlWidget(
                      widget.articles!.content!,
                      textStyle:
                          TextStyles.medium(context).copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



