import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/livetvplayer/LivestreamsPlayer.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Items.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/screens/AudioScreen.dart';
import 'package:higherground/screens/BookmarkScreen.dart';
import 'package:higherground/screens/Downloader.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/screens/PhotosScreen.dart';
import 'package:higherground/screens/PlaylistsScreen.dart';
import 'package:higherground/screens/RadioScreen.dart';
import 'package:higherground/screens/VideoScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/DashboardModel.dart';

class MediaPage extends StatefulWidget {
  MediaPage();

  @override
  MediaPageRouteState createState() => new MediaPageRouteState();
}

class MediaPageRouteState extends State<MediaPage> {
  late DashboardModel dashboardModel;
  final PageController _slideController = PageController(viewportFraction: 0.92);
  List<LiveStreams> _livestreamSlides = [];
  int _currentSlide = 0;
  bool _isLoadingSlides = false;

  @override
  void initState() {
    super.initState();
    _loadLivestreamSlides();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadLivestreamSlides() async {
    setState(() {
      _isLoadingSlides = true;
    });
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_LIVESTREAMS,
        data: jsonEncode({
          'data': {
            'page': '0',
          }
        }),
      );

      if (response.statusCode == 200) {
        final dynamic res = Utility.decodeResponse(response.data);
        final List<dynamic> raw = (res['livestreams'] ?? []) as List<dynamic>;
        final slides = raw
            .map((e) => LiveStreams.fromJson(e as Map<String, dynamic>))
            .where((e) => (e.type ?? '').isNotEmpty)
            .take(5)
            .toList();
        if (mounted) {
          setState(() {
            _livestreamSlides = slides;
          });
        }
      }
    } catch (_) {
      // Silently fail and keep the media page usable without slider content.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSlides = false;
        });
      }
    }
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);

    return Container(
      color: const Color(0xFFF1F4F9),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            _buildLivestreamSlider(),
            const SizedBox(height: 16.0),
            _buildListItems(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  static const List<Color> _iconColors = [
    Color(0xFF6366f1),
    Color(0xFF0ea5e9),
    Color(0xFF10b981),
    Color(0xFFf59e0b),
    Color(0xFFec4899),
    Color(0xFF8b5cf6),
    Color(0xFFef4444),
    Color(0xFF14b8a6),
  ];

  static const List<Color> _iconBgs = [
    Color(0xFFe0e7ff),
    Color(0xFFe0f2fe),
    Color(0xFFd1fae5),
    Color(0xFFFEF3C7),
    Color(0xFFfce7f3),
    Color(0xFFede9fe),
    Color(0xFFfee2e2),
    Color(0xFFccfbf1),
  ];

  Widget _buildListItems() {
    final List<Items> mediaItems = [];

    if (dashboardModel.isFeatureAvailable('videomessages')) {
      mediaItems.add(Items(1,
          title: t.videos,
          description: t.videoshint,
          photo: '',
          icon: Icons.ondemand_video_rounded));
    }
    if (dashboardModel.isFeatureAvailable('audiomessages')) {
      mediaItems.add(Items(2,
          title: t.audios,
          description: t.audioshint,
          photo: '',
          icon: Icons.headphones_rounded));
    }

    mediaItems.addAll(dashboardModel.listthree);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'LIBRARY',
              style: TextStyle(
                color: Color(0xFF6366f1),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFe2e8f0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: mediaItems.length,
              itemBuilder: (context, index) {
                final Items item = mediaItems[index];
                final Color iconColor =
                    _iconColors[index % _iconColors.length];
                final Color iconBg = _iconBgs[index % _iconBgs.length];
                final bool isLast = index == mediaItems.length - 1;

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.vertical(
                          top: index == 0
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                        onTap: () => onItemClick(item.position!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item.icon,
                                    color: iconColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF0f172a),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF94a3b8),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black.withValues(alpha: 0.20),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 72,
                        endIndent: 0,
                        color: Color(0xFFf1f5f9),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestreamSlider() {
    if (!dashboardModel.isFeatureAvailable('livestreams')) {
      return const SizedBox.shrink();
    }

    if (_isLoadingSlides) {
      return Container(
        height: 186,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFf0f2f5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_livestreamSlides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
          Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            children: [
              const Text(
                'LIVE STREAMS',
                style: TextStyle(
                  color: Color(0xFF6366f1),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6366f1),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
                },
                child: const Text('See all'),
              )
            ],
          ),
        ),
        SizedBox(
          height: 186,
          child: PageView.builder(
            controller: _slideController,
            itemCount: _livestreamSlides.length,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemBuilder: (context, index) {
              final live = _livestreamSlides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      LivestreamsPlayer.routeName,
                      arguments: ScreenArguements(
                        position: 0,
                        items: live,
                        itemsList: [],
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: live.coverphoto ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFf0f2f5),
                            child: const Center(
                                child: CupertinoActivityIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFf0f2f5),
                            child: const Icon(Icons.live_tv_rounded,
                                color: Color(0xFF94a3b8), size: 36),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xAA000000), Color(0x00000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(
                            live.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _livestreamSlides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentSlide == index ? 16 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentSlide == index
                    ? MyColors.primary
                    : const Color(0xFFcbd5e1),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }

  onItemClick(int pos) {
    switch (pos) {
      case 1:
        Navigator.of(context).pushNamed(VideoScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(AudioScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushNamed(PhotosScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushNamed(RadioScreen.routeName);
        break;
      case 5:
        Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
        break;
      case 6:
        Navigator.of(context).pushNamed(BookmarksScreen.routeName);
        break;
      case 7:
        Navigator.of(context).pushNamed(PlaylistsScreen.routeName);
        break;
      case 8:
        Navigator.pushNamed(context, Downloader.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: null,
            ));
        break;
    }
  }
}



