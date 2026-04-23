import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PrayerViewer extends StatefulWidget {
  static const routeName = "PrayerViewer";
  PrayerViewer({this.prayers});
  final Prayers? prayers;

  @override
  State<PrayerViewer> createState() => _PrayerViewerState();
}

class _PrayerViewerState extends State<PrayerViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.Prayerrequests),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.share(
                Bidi.stripHtmlIfNeeded(widget.prayers!.content!),
                subject: widget.prayers!.title,
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
                child: Image.asset(
                  Img.get("prayer.jpg"),
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                  //color: Colors.black26,
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
                      widget.prayers!.title!,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      widget.prayers!.date! +
                          " "+t.by+" " +
                          widget.prayers!.requester!,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10.0),
                    Divider(),
                    SizedBox(
                      height: 10.0,
                    ),
                    HtmlWidget(
                      widget.prayers!.content!,
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



