import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PrayerViewer extends StatefulWidget {
  static const routeName = 'PrayerViewer';

  PrayerViewer({this.prayers});
  final Prayers? prayers;

  @override
  State<PrayerViewer> createState() => _PrayerViewerState();
}

class _PrayerViewerState extends State<PrayerViewer> {
  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayers!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.Prayerrequests,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF23141D),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share(
                Bidi.stripHtmlIfNeeded(prayer.content!),
                subject: prayer.title,
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
                    prayer.title!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF23141D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${prayer.date!} ${t.by} ${prayer.requester!}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A6B75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        Img.get('prayer.jpg'),
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
                prayer.content!,
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
