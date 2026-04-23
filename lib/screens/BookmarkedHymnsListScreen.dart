import 'package:flutter/material.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/HymnsBookmarksModel.dart';
import 'HymnsViewerScreen.dart';
import 'package:higherground/models/Hymns.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/EmptyListScreen.dart';

class BookmarkedHymnsListScreen extends StatefulWidget {
  static const routeName = "/bookmarkedhymnslist";

  @override
  _HymnsListScreenState createState() => _HymnsListScreenState();
}

class _HymnsListScreenState extends State<BookmarkedHymnsListScreen> {
  late HymnsBookmarksModel hymnsBookmarksModel;
  late BuildContext context;
  bool showClear = false;
  String query = "";
  final TextEditingController inputController = new TextEditingController();
  List<Hymns> items = [];

  @override
  Widget build(BuildContext context) {
    hymnsBookmarksModel = Provider.of<HymnsBookmarksModel>(context);
    items = hymnsBookmarksModel.bookmarksList;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          maxLines: 1,
          controller: inputController,
          style: new TextStyle(fontSize: 18, color: Colors.black),
          keyboardType: TextInputType.text,
          onChanged: (term) {
            if (term.length > 0) {
              hymnsBookmarksModel.searchHymns(term);
              showClear = true;
            } else if (term.length == 0) {
              showClear = false;
              hymnsBookmarksModel.getBookmarks();
            }
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: t.bookmarks,
            hintStyle: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    inputController.clear();
                    showClear = false;
                    setState(() {
                      query = "";
                    });
                    hymnsBookmarksModel.getBookmarks();
                  },
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12),
        child: (items.length == 0)
            ? EmptyListScreen(
                message: t.noitemstodisplay,
              )
            : ListView.builder(
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(3),
                itemBuilder: (BuildContext context, int index) {
                  return ItemTile(
                    object: items[index],
                  );
                },
              ),
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Hymns object;

  const ItemTile({
    Key? key,
    required this.object,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(HymnsViewerScreen.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: object,
              itemsList: [],
            ));
      },
      child: RoundedContainer(
        padding: const EdgeInsets.all(0),
        margin: EdgeInsets.all(5),
        height: 130,
        child: Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 20,
                    ),
                    Flexible(
                      child: Text(
                        object.title!,
                        overflow: TextOverflow.fade,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        Bidi.stripHtmlIfNeeded(object.content!),
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                    ),
                    Container(height: 6,),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        Row(
                          children: <Widget>[
                            Consumer<HymnsBookmarksModel>(
                              builder: (context, bookmarksModel, child) {
                                bool isBookmarked =
                                    bookmarksModel.isHymnBookmarked(object);
                                return InkWell(
                                  child: Icon(Icons.bookmark,
                                      color: isBookmarked
                                          ? Colors.redAccent
                                          : Colors.grey,
                                      size: 20.0),
                                  onTap: () {
                                    if (isBookmarked)
                                      bookmarksModel.unBookmarkHymn(object);
                                    else
                                      bookmarksModel.bookmarkHymn(object);
                                  },
                                );
                              },
                            ),
                            Container(width: 10),
                            InkWell(
                              child: Icon(Icons.share,
                                  color: Colors.lightBlue, size: 20.0),
                              onTap: () async {
                                await Share.share(
                                  object.content!,
                                  subject: object.title,
                                );
                              },
                            ),
                            Container(width: 10),
                            InkWell(
                              child: Icon(Icons.content_copy,
                                  color: Colors.orange, size: 20.0),
                              onTap: () {
                                FlutterClipboard.copy(object.content!).then(
                                    (value) => Alerts.showToast(
                                        context, t.copiedtoclipboard));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



