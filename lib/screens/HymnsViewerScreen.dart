import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:higherground/utils/img.dart';
import 'package:higherground/models/Hymns.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/i18n/strings.g.dart';

class HymnsViewerScreen extends StatefulWidget {
  static const routeName = "/hymnsviewer";
  const HymnsViewerScreen({Key? key, this.hymns}) : super(key: key);
  final Hymns? hymns;

  @override
  _HymnsViewerScreenState createState() => _HymnsViewerScreenState();
}

class _HymnsViewerScreenState extends State<HymnsViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final hymn = widget.hymns!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.hymns,
          style: const TextStyle(
            color: Color(0xFF2A1720),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2A1720)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                        hymn.title!,
                        textAlign: TextAlign.left,
                        style: TextStyles.headline(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: const Color(0xFF2A1720),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: hymn.thumbnail!,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.15),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                            ),
                            placeholder: (context, url) =>
                                const Center(child: CupertinoActivityIndicator()),
                            errorWidget: (context, url, error) => Center(
                              child: Image.asset(
                                Img.get('hymns.jpg'),
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
                    hymn.content!,
                    textStyle: TextStyles.medium(context).copyWith(
                      fontSize: 18,
                      height: 1.55,
                      color: const Color(0xFF3A2A33),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


