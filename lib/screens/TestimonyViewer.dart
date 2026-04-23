import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Testimony.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TestimonyViewer extends StatefulWidget {
  static const routeName = "TestimonyViewer";
  TestimonyViewer({this.testimony});
  final Testimony? testimony;

  @override
  State<TestimonyViewer> createState() => _TestimonyViewerState();
}

class _TestimonyViewerState extends State<TestimonyViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.testimonies),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await Share.share(
                Bidi.stripHtmlIfNeeded(widget.testimony!.content!),
                subject: widget.testimony!.title,
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
                  Img.get("testimony.jpg"),
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
                      widget.testimony!.title!,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      widget.testimony!.date! +
                          " " +
                          t.by +
                          " " +
                          widget.testimony!.testifier!,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10.0),
                    Divider(),
                    SizedBox(
                      height: 10.0,
                    ),
                    HtmlWidget(
                      widget.testimony!.content!,
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



