import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/providers/SearchModel.dart';
import 'package:higherground/widgets/MediaItemTile.dart';
import 'package:higherground/i18n/strings.g.dart';

class SearchScreen extends StatelessWidget {
  static String routeName = "/search";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchModel()),
      ],
      child: SearchScreenBody(),
    );
  }
}

class SearchScreenBody extends StatefulWidget {
  SearchScreenBody();

  @override
  SearchScreenRouteState createState() => new SearchScreenRouteState();
}

class SearchScreenRouteState extends State<SearchScreenBody> {
  bool showClear = false;
  final TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    inputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateManager>(context);
    final searchModel = Provider.of<SearchModel>(context);
    final List<Media> items = searchModel.items;

    void _onLoading() async {
      searchModel.fetchMoreSearch();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        title: const Text(
          'Search Library',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SmartRefresher(
          enablePullDown: false,
          enablePullUp: searchModel.items.length > 20 ? true : false,
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
          controller: searchModel.refreshController,
          onLoading: _onLoading,
          child: buildContent(context, searchModel, appState, items)),
    );
  }

  Widget _buildSearchField(SearchModel searchModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DDE4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        maxLines: 1,
        controller: inputController,
        style: const TextStyle(fontSize: 15, color: Color(0xFF23141D)),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            searchModel.searchArticles(query);
          }
        },
        onChanged: (term) {
          setState(() {
            showClear = term.trim().isNotEmpty;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: t.searchhint,
          hintStyle: const TextStyle(fontSize: 14.5, color: Color(0xFF8A7D86)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8A7D86),
          ),
          suffixIcon: showClear
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF8A7D86),
                  onPressed: () {
                    inputController.clear();
                    setState(() {
                      showClear = false;
                    });
                    searchModel.cancelSearch();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildHeader(AppStateManager appState, int totalResults) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF7F375E), Color(0xFFA84978)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages, Books & Resources',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  totalResults > 0
                      ? '$totalResults result${totalResults == 1 ? '' : 's'} found'
                      : appState.userdata != null
                          ? 'Search across your church media library.'
                          : 'Search public media and resources quickly.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context, SearchModel searchModel,
      AppStateManager appState, List<Media> items) {
    final Widget stateContent;

    if (searchModel.isLoading) {
      stateContent = Container(
        margin: const EdgeInsets.only(top: 26),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoActivityIndicator(radius: 24),
            SizedBox(height: 10),
            Text(
              'Searching library...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6F616A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else if (searchModel.isError) {
      stateContent = Container(
        margin: const EdgeInsets.only(top: 26),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.search_off_rounded,
              size: 42,
              color: Color(0xFF8A7D86),
            ),
            const SizedBox(height: 8),
            Text(
              t.nosearchresult,
              style: TextStyles.caption(context)
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              t.nosearchresulthint,
              textAlign: TextAlign.center,
              style: TextStyles.medium(context).copyWith(fontSize: 13),
            ),
          ],
        ),
      );
    } else if (searchModel.isIdle) {
      stateContent = Container(
        margin: const EdgeInsets.only(top: 26),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.travel_explore_rounded,
              color: Colors.grey[500],
              size: 54,
            ),
            const SizedBox(height: 8),
            const Text(
              'Start typing to search',
              style: TextStyle(
                color: Color(0xFF2A1A24),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Find messages, books, and resources instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D7079),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    } else {
      stateContent = ListView.separated(
        itemCount: items.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 90),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          return ItemTile(
            mediaList: items,
            index: index,
            object: items[index],
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(appState, items.length),
          const SizedBox(height: 12),
          _buildSearchField(searchModel),
          stateContent,
        ],
      ),
    );
  }
}


