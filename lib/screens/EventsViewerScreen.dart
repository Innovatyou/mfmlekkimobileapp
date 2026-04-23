import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/utils/img.dart';
import 'package:higherground/models/Events.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'NoitemScreen.dart';
import 'package:intl/intl.dart';
import 'package:higherground/i18n/strings.g.dart';

class EventsViewerScreen extends StatefulWidget {
  static const routeName = "/eventsviewer";
  const EventsViewerScreen({Key? key, this.events}) : super(key: key);
  final Events? events;

  @override
  _BranchesPageBodyState createState() => _BranchesPageBodyState();
}

class _BranchesPageBodyState extends State<EventsViewerScreen> {
  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    /*Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.4,
        title: Text(t.events),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12),
        child: SingleChildScrollView(
          child: getEventsBody(),
        ),
      ),
    );
  }

  Widget getEventsBody() {
    if (isLoading) {
      return Container(
        height: 600,
        child: Center(
          child: CupertinoActivityIndicator(
            radius: 20,
          ),
        ),
      );
    } else if (isError || widget.events == null) {
      return Container(
        height: 600,
        child: Center(
          child: NoitemScreen(
              title: t.oops,
              message: t.dataloaderror,
              onClick: () {
                //loadItems();
              }),
        ),
      );
    } else
      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.events!.title!,
                  textAlign: TextAlign.start,
                  style: TextStyles.headline(context)
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            Container(height: 20),
            Container(
              height: 200,
              //margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: CachedNetworkImage(
                  imageUrl: widget.events!.thumbnail!,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  DateFormat('EEE, MMM d, yyyy', 'en_US').format(
                      new DateFormat("yyyy-MM-dd").parse(widget.events!.date!)),
                  textAlign: TextAlign.start,
                  style: TextStyles.headline(context).copyWith(fontSize: 18)),
            ),
            Container(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.events!.time!,
                  textAlign: TextAlign.start,
                  style: TextStyles.headline(context).copyWith(fontSize: 18)),
            ),
            Container(height: 5),
            Container(height: 20),
            HtmlWidget(
              widget.events!.details!,
              textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
              factoryBuilder: () => _WidgetFactory(
                webView: true,
                webViewJs: true,
              ),
              //rebuildTriggers: [true, true],
            ),
            Container(
              height: 20,
            ),
          ],
        ),
      );
  }
}

class _WidgetFactory extends WidgetFactory {
  @override
  final bool webView;

  @override
  final bool webViewJs;

  _WidgetFactory({
    required this.webView,
    required this.webViewJs,
  });
}


