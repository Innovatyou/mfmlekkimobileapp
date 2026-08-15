import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/ArticleViewer.dart';
import 'package:higherground/screens/ArticlesScreen.dart';
import 'package:higherground/screens/BooksScreen.dart';
import 'package:higherground/screens/BooksViewerScreen.dart';
import 'package:provider/provider.dart';

class PublicationsPage extends StatefulWidget {
  @override
  State<PublicationsPage> createState() => _PublicationsPageState();
}

class _PublicationsPageState extends State<PublicationsPage> {
  late DashboardModel dashboardModel;

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      body: Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (dashboardModel.isFeatureAvailable('books') &&
                  dashboardModel.recentbooks.isNotEmpty) ...[
                _sectionHeader(
                  title: t.books,
                  onTap: () =>
                      Navigator.of(context).pushNamed(BooksScreen.routeName),
                ),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (dashboardModel.isFeatureAvailable('articles') &&
                          dashboardModel.recentbooks.isNotEmpty)
                      ? 2
                      : dashboardModel.recentbooks.length,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final books = dashboardModel.recentbooks[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          BooksViewerScreen.routeName,
                          arguments: books,
                        );
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8DDE4)),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: books.thumbnail!,
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
                              errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.error, color: Colors.grey)),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 68,
                                color: const Color(0xA60f172a),
                                padding: const EdgeInsets.all(10),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    books.title!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              if (dashboardModel.isFeatureAvailable('articles')) ...[
                _sectionHeader(
                  title: t.recentarticles,
                  onTap: () =>
                      Navigator.of(context).pushNamed(ArticlesScreen.routeName),
                ),
                const SizedBox(height: 6),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 4, bottom: 10),
                  itemCount: dashboardModel.recentarticles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final articles = dashboardModel.recentarticles[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8DDE4)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ArticleViewer.routeName,
                            arguments: articles,
                          );
                        },
                        title: Text(
                          articles.title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0f172a),
                          ),
                        ),
                        subtitle: Text(
                          '${articles.date!} | ${articles.author!}',
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                        trailing: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            articles.thumbnail!,
                            width: 78,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({required String title, required VoidCallback onTap}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0f172a),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Color(0xFF6366f1),
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
