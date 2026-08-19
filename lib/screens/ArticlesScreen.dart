import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/providers/ArticlesScreensModel.dart';
import 'package:higherground/screens/ArticleViewer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Articles.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/my_colors.dart';

class ArticlesScreen extends StatefulWidget {
  static const routeName = "/ArticlesScreen";
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  ArticlesScreenRouteState createState() => ArticlesScreenRouteState();
}

class ArticlesScreenRouteState extends State<ArticlesScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArticlesScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.articles,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const _ArticlesBody(),
      ),
    );
  }
}

class _ArticlesBody extends StatefulWidget {
  const _ArticlesBody();

  @override
  _ArticlesBodyState createState() => _ArticlesBodyState();
}

class _ArticlesBodyState extends State<_ArticlesBody> {
  late ArticlesScreensModel _model;

  void _onRefresh() => _model.loadItems();
  void _onLoading() => _model.loadMoreItems();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<ArticlesScreensModel>(context, listen: false).loadItems());
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<ArticlesScreensModel>(context);
    final List<Articles> items = _model.mediaList ?? [];

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropMaterialHeader(
        backgroundColor: MyColors.primary,
        color: Colors.white,
      ),
      footer: _buildFooter(),
      controller: _model.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (_model.isError == true && items.isEmpty)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : ListView.separated(
              itemCount: items.length,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _ArticleTile(article: items[index]),
            ),
    );
  }

  CustomFooter _buildFooter() => CustomFooter(
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
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Article tile
// ─────────────────────────────────────────────────────────────────────────────

class _ArticleTile extends StatelessWidget {
  final Articles article;
  const _ArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.pushNamed(context, ArticleViewer.routeName, arguments: article),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFe2e8f0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(15)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: (article.thumbnail == null || article.thumbnail!.isEmpty)
                      ? Container(
                          color: MyColors.primaryVeryLight,
                          child: const Icon(Icons.article_rounded,
                              color: MyColors.primary, size: 32),
                        )
                      : CachedNetworkImage(
                          imageUrl: article.thumbnail!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: MyColors.surface),
                          errorWidget: (_, __, ___) => Container(
                            color: MyColors.primaryVeryLight,
                            child: const Icon(Icons.article_rounded,
                                color: MyColors.primary, size: 28),
                          ),
                        ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0f172a),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${article.date ?? ''} · ${article.author ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: MyColors.primaryVeryLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Article',
                          style: TextStyle(
                            color: MyColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
