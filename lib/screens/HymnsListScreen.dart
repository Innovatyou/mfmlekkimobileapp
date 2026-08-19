import 'package:flutter/material.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/Utility.dart';
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
import 'package:higherground/utils/my_colors.dart';

class HymnsListScreen extends StatefulWidget {
  static const routeName = "/hymnslist";

  @override
  _HymnsListScreenState createState() => _HymnsListScreenState();
}

class _HymnsListScreenState extends State<HymnsListScreen> {
  late BuildContext context;
  bool showClear = false;
  String query = "";
  final TextEditingController inputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: TextField(
            maxLines: 1,
            controller: inputController,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.text,
            onSubmitted: (_query) {
              setState(() {
                query = _query;
                showClear = (_query.isNotEmpty);
              });
            },
            onChanged: (term) {
              setState(() {
                query = term;
                showClear = (term.isNotEmpty);
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: t.hymns,
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.65),
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: <Widget>[
          showClear
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () {
                    inputController.clear();
                    showClear = false;
                    setState(() => query = "");
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.bookmark_outline_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(BookmarkedHymnsListScreen.routeName),
                ),
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
        dynamic res = Utility.decodeResponse(response.data);
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
      header: const WaterDropMaterialHeader(
        backgroundColor: MyColors.primary,
        color: Colors.white,
      ),
      footer: CustomFooter(
        builder: (context, mode) {
          late Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore,
                style: const TextStyle(
                    color: MyColors.textSecondary, fontSize: 12));
          } else if (mode == LoadStatus.loading) {
            body = const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: MyColors.primary));
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry,
                style: const TextStyle(color: MyColors.danger, fontSize: 12));
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore,
                style: const TextStyle(
                    color: MyColors.textSecondary, fontSize: 12));
          } else {
            body = Text(t.nomoredata,
                style: const TextStyle(
                    color: MyColors.textDisabled, fontSize: 12));
          }
          return SizedBox(height: 55, child: Center(child: body));
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
                        const Icon(Icons.search_off_rounded,
                            size: 64, color: MyColors.textDisabled),
                        const SizedBox(height: 16),
                        const Text(
                          'No hymns found',
                          style: TextStyle(
                              fontSize: 18,
                              color: MyColors.textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                              fontSize: 14, color: MyColors.textDisabled),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredItems!.length,
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      duration: Duration(milliseconds: 450 + (widget.index * 60)),
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
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).pushNamed(HymnsViewerScreen.routeName,
                  arguments: ScreenArguements(
                    position: 0,
                    items: widget.object,
                    itemsList: [],
                  ));
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.primaryVeryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Hymn',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MyColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.object.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color(0xFF0f172a),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Bidi.stripHtmlIfNeeded(widget.object.content!),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 13.5,
                        color: MyColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Consumer<HymnsBookmarksModel>(
                          builder: (context, bookmarksModel, child) {
                            bool isBookmarked =
                                bookmarksModel.isHymnBookmarked(widget.object);
                            return _ActionButton(
                              icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              color: isBookmarked ? MyColors.danger : MyColors.textSecondary,
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
                          color: MyColors.success,
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
                          color: MyColors.accent,
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



