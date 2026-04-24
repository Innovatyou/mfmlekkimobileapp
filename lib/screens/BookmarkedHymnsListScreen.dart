import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Hymns.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/providers/HymnsBookmarksModel.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'HymnsViewerScreen.dart';

class BookmarkedHymnsListScreen extends StatefulWidget {
  static const routeName = '/bookmarkedhymnslist';

  @override
  _HymnsListScreenState createState() => _HymnsListScreenState();
}

class _HymnsListScreenState extends State<BookmarkedHymnsListScreen> {
  late HymnsBookmarksModel hymnsBookmarksModel;
  bool showClear = false;
  String query = '';
  final TextEditingController inputController = TextEditingController();
  List<Hymns> items = [];

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    hymnsBookmarksModel = Provider.of<HymnsBookmarksModel>(context);
    items = hymnsBookmarksModel.bookmarksList;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE7DDE4)),
          ),
          child: TextField(
            maxLines: 1,
            controller: inputController,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2A1720),
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.text,
            onChanged: (term) {
              setState(() {
                query = term;
                showClear = term.isNotEmpty;
              });
              if (term.isNotEmpty) {
                hymnsBookmarksModel.searchHymns(term);
              } else {
                hymnsBookmarksModel.getBookmarks();
              }
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: t.bookmarks,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8D7D87),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF8D7D87),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1720)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          if (showClear)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF2A1720)),
              onPressed: () {
                inputController.clear();
                setState(() {
                  showClear = false;
                  query = '';
                });
                hymnsBookmarksModel.getBookmarks();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: (items.isEmpty)
            ? EmptyListScreen(message: t.noitemstodisplay)
            : ListView.builder(
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                itemBuilder: (BuildContext context, int index) {
                  return ItemTile(object: items[index]);
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
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).pushNamed(
          HymnsViewerScreen.routeName,
          arguments: ScreenArguements(
            position: 0,
            items: object,
            itemsList: [],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9DFE5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBF1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Bookmarked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A4B63),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                object.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Color(0xFF251620),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Bidi.stripHtmlIfNeeded(object.content ?? ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                  color: Color(0xFF6F616A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Consumer<HymnsBookmarksModel>(
                    builder: (context, bookmarksModel, child) {
                      final isBookmarked =
                          bookmarksModel.isHymnBookmarked(object);
                      return _ActionButton(
                        icon: isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: isBookmarked ? Colors.redAccent : Colors.grey,
                        onTap: () {
                          if (isBookmarked) {
                            bookmarksModel.unBookmarkHymn(object);
                          } else {
                            bookmarksModel.bookmarkHymn(object);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.share_outlined,
                    color: Colors.blue,
                    onTap: () async {
                      await Share.share(
                        object.content ?? '',
                        subject: object.title,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.content_copy_outlined,
                    color: Colors.orange,
                    onTap: () {
                      FlutterClipboard.copy(object.content ?? '').then(
                        (value) => Alerts.showToast(context, t.copiedtoclipboard),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}
