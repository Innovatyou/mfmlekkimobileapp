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
  static const routeName = 'articlesviewer';

  ArticleViewer({this.articles});
  final Articles? articles;

  @override
  State<ArticleViewer> createState() => _ArticleViewerState();
}

class _ArticleViewerState extends State<ArticleViewer> {
  @override
  Widget build(BuildContext context) {
    final article = widget.articles!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.articles,
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
                Bidi.stripHtmlIfNeeded(article.content!),
                subject: article.title,
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
                    article.title!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${article.date!} ${t.by} ${article.author!}',
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
                      child: CachedNetworkImage(
                        imageUrl: article.thumbnail!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            Img.get('articles.jpg'),
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
              child: HtmlWidget(
                article.content!,
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
