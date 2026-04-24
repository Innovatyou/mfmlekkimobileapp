import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/BookmarksModel.dart';
import 'package:higherground/widgets/MediaItemTile.dart';

class BookmarksScreen extends StatefulWidget {
  static const routeName = "/mybookmarks";
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  BookmarksModel? mediaScreensModel;
  List<Media>? items;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<BookmarksModel>(context);
    items = mediaScreensModel!.bookmarksList;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Text(
          t.bookmarks,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF23141D),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: (items!.isEmpty)
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE8DDE4)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bookmark_border_rounded,
                              size: 42,
                              color: Color(0xFF9D9098),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.noitemstodisplay,
                              textAlign: TextAlign.center,
                              style: TextStyles.medium(context).copyWith(
                                color: const Color(0xFF6F616A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items!.length,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                      itemBuilder: (BuildContext context, int index) {
                        return ItemTile(
                          mediaList: items!,
                          index: index,
                          object: items![index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


