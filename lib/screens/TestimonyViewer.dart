import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Testimony.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class TestimonyViewer extends StatefulWidget {
  static const routeName = 'TestimonyViewer';

  TestimonyViewer({this.testimony});
  final Testimony? testimony;

  @override
  State<TestimonyViewer> createState() => _TestimonyViewerState();
}

class _TestimonyViewerState extends State<TestimonyViewer> {
  @override
  Widget build(BuildContext context) {
    final testimony = widget.testimony!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.testimonies,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0f172a),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share(
                Bidi.stripHtmlIfNeeded(testimony.content!),
                subject: testimony.title,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8DDE4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimony.title!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${testimony.date!} ${t.by} ${testimony.testifier!}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        Img.get('testimony.jpg'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8DDE4)),
              ),
              child: HtmlWidget(
                testimony.content!,
                textStyle: TextStyles.medium(context).copyWith(
                  fontSize: 18,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
