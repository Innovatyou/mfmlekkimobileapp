import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Devotionals.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/img.dart';
import 'package:intl/intl.dart';

class DevotionalViewerScreen extends StatefulWidget {
  static const routeName = '/DevotionalViewerScreen';
  const DevotionalViewerScreen({Key? key, this.devotionals}) : super(key: key);
  final Devotionals? devotionals;

  @override
  _DevotionalScreenState createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final devotional = widget.devotionals!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.devotionals,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF23141D),
          ),
        ),
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
                    devotional.title!,
                    style: TextStyles.headline(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: const Color(0xFF23141D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    devotional.author!,
                    style: TextStyles.subhead(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7A6B75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, MMM d, yyyy', 'en_US')
                        .format(DateFormat('yyyy-MM-dd').parse(devotional.date!)),
                    style: TextStyles.subhead(context).copyWith(
                      fontSize: 14,
                      color: const Color(0xFF7A6B75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: devotional.thumbnail!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.12),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Image.asset(
                            Img.get('devotionals.jpg'),
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
            _contentCard(
              context,
              HtmlWidget(
                devotional.biblereading!,
                textStyle: TextStyles.medium(context).copyWith(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            _contentCard(
              context,
              HtmlWidget(
                devotional.content!,
                textStyle: TextStyles.medium(context).copyWith(
                  fontSize: 18,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _contentCard(
              context,
              HtmlWidget(
                devotional.confession!,
                textStyle: TextStyles.medium(context).copyWith(
                  fontSize: 18,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _contentCard(
              context,
              HtmlWidget(
                devotional.studies!,
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

  Widget _contentCard(BuildContext context, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      child: child,
    );
  }
}
