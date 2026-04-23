import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/models/Devotionals.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';

class ItemsViewer extends StatefulWidget {
  static const routeName = "itemsViewer";
  ItemsViewer({this.id, this.type});
  final String? id;
  final String? type;

  @override
  State<ItemsViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ItemsViewer> {
  bool isloading = true;
  bool iserror = false;
  Devotionals? devotionals;
  Articles? articles;
  Events? events;

  Future<void> loadItems() async {
    setState(() {
      isloading = true;
    });
    try {
      var data = {"id": widget.id, "type": widget.type};
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.getitemdata,
        data: jsonEncode({"data": data}),
      );
      print(response.data);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        print(res);
        setState(() {
          if (widget.type == "Devotional") {
            devotionals = Devotionals.fromJson(res['devotional']);
          } else if (widget.type == "Article") {
            articles = Articles.fromJson(res['articles']);
          } else if (widget.type == "Event") {
            events = Events.fromJson(res['events']);
          }
          isloading = false;
          iserror = false;
        });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setState(() {
          isloading = false;
          iserror = true;
        });
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setState(() {
        isloading = false;
        iserror = true;
      });
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.type!),
      ),
      body: SingleChildScrollView(
        child: isloading
            ? Container(
                height: 600,
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 20,
                  ),
                ),
              )
            : iserror
                ? Container(
                    height: 600,
                    child: Center(
                      child: NoitemScreen(
                          title: t.oops,
                          message: t.dataloaderror,
                          onClick: () {
                            loadItems();
                          }),
                    ),
                  )
                : getContent(),
      ),
    );
  }

  Widget getContent() {
    if (widget.type == "Devotional") {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(devotionals!.title!,
                textAlign: TextAlign.center,
                style: TextStyles.headline(context)
                    .copyWith(fontWeight: FontWeight.bold)),
            Container(height: 5),
            Text(devotionals!.author!,
                textAlign: TextAlign.start,
                style: TextStyles.subhead(context)
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 18)),
            Container(height: 20),
            Container(
              height: 200,
              //margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: CachedNetworkImage(
                  imageUrl: devotionals!.thumbnail!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black12, BlendMode.darken)),
                    ),
                  ),
                  placeholder: (context, url) =>
                      Center(child: CupertinoActivityIndicator()),
                  errorWidget: (context, url, error) => Center(
                      child: Image.asset(
                    Img.get('devotionals.jpg'),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    //color: Colors.black26,
                  )),
                ),
              ),
            ),
            Container(height: 20),
            HtmlWidget(
              devotionals!.biblereading!,
              
              textStyle: TextStyles.medium(context).copyWith(fontSize: 17),
            ),
            Container(height: 20),
            HtmlWidget(
              devotionals!.content!,
              
              textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
            ),
            Container(height: 20),
            HtmlWidget(
              devotionals!.confession!,
              
              textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
            ),
            Container(height: 20),
            HtmlWidget(
              devotionals!.studies!,
              
              textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
            ),
          ],
        ),
      );
    }
    if (widget.type == "Article") {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: articles!.thumbnail!,
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
                    articles!.title!,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    articles!.date! + " by " + articles!.author!,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10.0),
                  Divider(),
                  SizedBox(
                    height: 10.0,
                  ),
                  HtmlWidget(
                    articles!.content!,
                    textStyle:
                        TextStyles.medium(context).copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget.type == "Event") {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(events!.title!,
                  textAlign: TextAlign.start,
                  style: TextStyles.headline(context)
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Container(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  DateFormat('EEE, MMM d, yyyy', 'en_US').format(
                      new DateFormat("yyyy-MM-dd").parse(events!.date!)),
                  textAlign: TextAlign.justify,
                  style: TextStyles.subhead(context).copyWith(fontSize: 16)),
            ),
            Container(height: 20),
            Container(
              height: 200,
              //margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: CachedNetworkImage(
                  imageUrl: events!.thumbnail!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black12, BlendMode.darken)),
                    ),
                  ),
                  placeholder: (context, url) =>
                      Center(child: CupertinoActivityIndicator()),
                  errorWidget: (context, url, error) => Center(
                      child: Image.asset(
                    Img.get('event.jpg'),
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                    //color: Colors.black26,
                  )),
                ),
              ),
            ),
            Container(height: 20),
            HtmlWidget(
              events!.details!,
              
              textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
            ),
            Container(height: 20),
          ],
        ),
      );
    }
    return Container();
  }
}



