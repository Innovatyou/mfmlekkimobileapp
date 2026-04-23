import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/utils/img.dart';
import 'package:higherground/models/Devotionals.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:intl/intl.dart';
import 'package:higherground/i18n/strings.g.dart';

class DevotionalViewerScreen extends StatefulWidget {
  static const routeName = "/DevotionalViewerScreen";
  const DevotionalViewerScreen({Key? key, this.devotionals}) : super(key: key);
  final Devotionals? devotionals;

  @override
  _DevotionalScreenState createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalViewerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        title: Text(t.devotionals),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(widget.devotionals!.title!,
                    textAlign: TextAlign.center,
                    style: TextStyles.headline(context)
                        .copyWith(fontWeight: FontWeight.bold)),
                Container(height: 5),
                Text(widget.devotionals!.author!,
                    textAlign: TextAlign.start,
                    style: TextStyles.subhead(context)
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 18)),
                Divider(height: 5),
                Text(
                    DateFormat('EEE, MMM d, yyyy', 'en_US').format(
                        DateFormat("yyyy-MM-dd")
                            .parse(widget.devotionals!.date!)),
                    textAlign: TextAlign.justify,
                    style: TextStyles.subhead(context).copyWith(fontSize: 16)),
                Container(height: 20),
                Container(
                  height: 200,
                  //margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: CachedNetworkImage(
                      imageUrl: widget.devotionals!.thumbnail!,
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
                  widget.devotionals!.biblereading!,
                  
                  textStyle: TextStyles.medium(context).copyWith(fontSize: 17),
                ),
                Container(height: 20),
                HtmlWidget(
                  widget.devotionals!.content!,
                  textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
                ),
                Container(height: 20),
                HtmlWidget(
                  widget.devotionals!.confession!,
                  textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
                ),
                Container(height: 20),
                HtmlWidget(
                  widget.devotionals!.studies!,
                  textStyle: TextStyles.medium(context).copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


