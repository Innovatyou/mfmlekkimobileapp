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
  static const routeName = 'itemsViewer';
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
      final data = {'id': widget.id, 'type': widget.type};
      final response = await Utility.getDio().post(
        ApiUrl.getitemdata,
        data: jsonEncode({'data': data}),
      );
      if (response.statusCode == 200) {
        final dynamic res = jsonDecode(response.data);
        setState(() {
          if (widget.type == 'Devotional') {
            devotionals = Devotionals.fromJson(res['devotional']);
          } else if (widget.type == 'Article') {
            articles = Articles.fromJson(res['articles']);
          } else if (widget.type == 'Event') {
            events = Events.fromJson(res['events']);
          }
          isloading = false;
          iserror = false;
        });
      } else {
        setState(() {
          isloading = false;
          iserror = true;
        });
      }
    } catch (exception) {
      print(exception);
      setState(() {
        isloading = false;
        iserror = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.type ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF23141D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: isloading
            ? const SizedBox(
                height: 600,
                child: Center(child: CupertinoActivityIndicator(radius: 20)),
              )
            : iserror
                ? SizedBox(
                    height: 600,
                    child: Center(
                      child: NoitemScreen(
                        title: t.oops,
                        message: t.dataloaderror,
                        onClick: loadItems,
                      ),
                    ),
                  )
                : getContent(),
      ),
    );
  }

  Widget getContent() {
    if (widget.type == 'Devotional') {
      return _detailLayout(
        title: devotionals!.title!,
        subtitle:
            '${devotionals!.author!} • ${DateFormat('EEE, MMM d, yyyy', 'en_US').format(DateFormat('yyyy-MM-dd').parse(devotionals!.date!))}',
        imageUrl: devotionals!.thumbnail!,
        fallbackAsset: 'devotionals.jpg',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HtmlWidget(
              devotionals!.biblereading!,
              textStyle: TextStyles.medium(context).copyWith(fontSize: 17),
            ),
            const SizedBox(height: 12),
            HtmlWidget(
              devotionals!.content!,
              textStyle: TextStyles.medium(context).copyWith(fontSize: 18, height: 1.55),
            ),
            const SizedBox(height: 12),
            HtmlWidget(
              devotionals!.confession!,
              textStyle: TextStyles.medium(context).copyWith(fontSize: 18, height: 1.55),
            ),
            const SizedBox(height: 12),
            HtmlWidget(
              devotionals!.studies!,
              textStyle: TextStyles.medium(context).copyWith(fontSize: 18, height: 1.55),
            ),
          ],
        ),
      );
    }

    if (widget.type == 'Article') {
      return _detailLayout(
        title: articles!.title!,
        subtitle: '${articles!.date!} ${t.by} ${articles!.author!}',
        imageUrl: articles!.thumbnail!,
        fallbackAsset: 'articles.jpg',
        content: HtmlWidget(
          articles!.content!,
          textStyle: TextStyles.medium(context).copyWith(fontSize: 18, height: 1.55),
        ),
      );
    }

    if (widget.type == 'Event') {
      return _detailLayout(
        title: events!.title!,
        subtitle: DateFormat('EEE, MMM d, yyyy', 'en_US')
            .format(DateFormat('yyyy-MM-dd').parse(events!.date!)),
        imageUrl: events!.thumbnail!,
        fallbackAsset: 'event.jpg',
        content: HtmlWidget(
          events!.details!,
          textStyle: TextStyles.medium(context).copyWith(fontSize: 18, height: 1.55),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _detailLayout({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String fallbackAsset,
    required Widget content,
  }) {
    return Padding(
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
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF23141D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
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
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) =>
                          const Center(child: CupertinoActivityIndicator()),
                      errorWidget: (context, url, error) => Center(
                        child: Image.asset(
                          Img.get(fallbackAsset),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
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
            child: content,
          ),
        ],
      ),
    );
  }
}
