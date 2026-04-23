import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'dart:async';
import 'package:higherground/screens/BookmarkedHymnsListScreen.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/HymnsBookmarksModel.dart';
import 'package:higherground/screens/HymnsViewerScreen.dart';
import 'package:higherground/models/Hymns.dart';
import 'NoitemScreen.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/utils/ApiUrl.dart';

class HymnsListScreen extends StatefulWidget {
  static const routeName = "/hymnslist";

  @override
  _HymnsListScreenState createState() => _HymnsListScreenState();
}

class _HymnsListScreenState extends State<HymnsListScreen> {
  late BuildContext context;
  bool showClear = false;
  String query = "";
  final TextEditingController inputController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: TextField(
            maxLines: 1,
            controller: inputController,
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
            keyboardType: TextInputType.text,
            onSubmitted: (_query) {
              setState(() {
                query = _query;
                showClear = (_query.length > 0);
              });
            },
            onChanged: (term) {
              setState(() {
                query = term;
                showClear = (term.length > 0);
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: t.hymns,
              hintStyle: const TextStyle(fontSize: 16.0, color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: <Widget>[
          showClear
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    inputController.clear();
                    showClear = false;
                    setState(() {
                      query = "";
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(BookmarkedHymnsListScreen.routeName);
                  }),
        ],
      ),
      body: HymnScreenBody(
        query: query,
        key: UniqueKey(),
      ),
    );
  }
}

class HymnScreenBody extends StatefulWidget {
  final String query;

  const HymnScreenBody({
    Key? key,
    required this.query,
  }) : super(key: key);
  @override
  HymnScreenBodyBodyRouteState createState() =>
      new HymnScreenBodyBodyRouteState();
}

class HymnScreenBodyBodyRouteState extends State<HymnScreenBody> {
  List<Hymns>? items = [];
  List<Hymns>? filteredItems = [];
  bool isLoading = false;
  bool isError = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  int page = 0;

  @override
  void didUpdateWidget(HymnScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _filterItems(widget.query);
    }
  }

  void _onRefresh() async {
    loadItems();
  }

  void _onLoading() async {
    loadMoreItems();
  }

  loadItems() {
    refreshController.requestRefresh();
    page = 0;
    setState(() {});
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Hymns>? item) {
    items!.clear();
    items = item;
    filteredItems = item;
    refreshController.refreshCompleted();
    isError = false;
    setState(() {});
  }

  void setMoreItems(List<Hymns> item) {
    refreshController.loadComplete();
    isError = false;
    items!.addAll(item);
    filteredItems = items;
    setState(() {});
  }

  Future<void> fetchItems() async {
    try {
      final response = await Utility.getDio().post(
        ApiUrl.HYMNS,
        data: jsonEncode({
          "data": {"query": widget.query, "page": page.toString()}
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic res = jsonDecode(response.data);
        print(res);
        List<Hymns>? mediaList = parseSliderMedia(res);
        if (page == 0) {
          setItems(mediaList);
        } else {
          setMoreItems(mediaList!);
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setFetchError();
    }
  }

  static List<Hymns>? parseSliderMedia(dynamic res) {
    final parsed = res["hymns"].cast<Map<String, dynamic>>();
    return parsed.map<Hymns>((json) => Hymns.fromJson(json)).toList();
  }

  setFetchError() {
    if (page == 0) {
      setState(() {
        isError = true;
        refreshController.refreshFailed();
      });
    } else {
      setState(() {
        refreshController.loadFailed();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      filteredItems = items;
    } else {
      filteredItems = items!
          .where((hymn) =>
              hymn.title!.toLowerCase().contains(query.toLowerCase()) ||
              hymn.content!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore);
          } else {
            body = Text(t.nomoredata);
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (isError == true && items!.length == 0)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : filteredItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hymns found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredItems!.length,
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemBuilder: (BuildContext context, int index) {
                    return ItemTile(
                      object: filteredItems![index],
                      index: index,
                    );
                  },
                ),
    );
  }
}

class ItemTile extends StatefulWidget {
  final Hymns object;
  final int index;

  const ItemTile({
    Key? key,
    required this.object,
    required this.index,
  }) : super(key: key);

  @override
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Material(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(HymnsViewerScreen.routeName,
                  arguments: ScreenArguements(
                    position: 0,
                    items: widget.object,
                    itemsList: [],
                  ));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.object.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Content Preview
                    Text(
                      Bidi.stripHtmlIfNeeded(widget.object.content!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Consumer<HymnsBookmarksModel>(
                          builder: (context, bookmarksModel, child) {
                            bool isBookmarked =
                                bookmarksModel.isHymnBookmarked(widget.object);
                            return _ActionButton(
                              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.red : Colors.grey,
                              onTap: () {
                                if (isBookmarked)
                                  bookmarksModel.unBookmarkHymn(widget.object);
                                else
                                  bookmarksModel.bookmarkHymn(widget.object);
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
                              widget.object.content!,
                              subject: widget.object.title,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.content_copy_outlined,
                          color: Colors.orange,
                          onTap: () {
                            FlutterClipboard.copy(widget.object.content!).then(
                              (value) => Alerts.showToast(
                                context,
                                t.copiedtoclipboard,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
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



