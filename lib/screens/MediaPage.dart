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
        final dynamic res = jsonDecode(response.data);
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
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            _buildLivestreamSlider(),
            const SizedBox(height: 12.0),
            _buildListItems(),
            SizedBox(
              height: 10,
            ),
            const SizedBox(height: 6.0),
          ],
        ),
      ),
    );
  }

  Widget _buildListItems() {
    final List<Items> mediaItems = [];

    if (dashboardModel.isFeatureAvailable('videomessages')) {
      mediaItems.add(
        Items(1,
            title: t.videos,
            description: t.videoshint,
            photo: '',
            icon: Icons.ondemand_video_rounded),
      );
    }
    if (dashboardModel.isFeatureAvailable('audiomessages')) {
      mediaItems.add(
        Items(2,
            title: t.audios,
            description: t.audioshint,
            photo: '',
            icon: Icons.headphones_rounded),
      );
    }

    mediaItems.addAll(dashboardModel.listthree);

    return Container(
      //color: Colors.black,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: mediaItems.length,
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          Items itms = mediaItems[index];
          return Card(
            elevation: 0.5,
            margin: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 4,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(itms.icon!),
              ),
              title: Text(itms.title!),
              subtitle: Text(itms.description!),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                onItemClick(itms.position!);
              },
            ),
          );
          /* return InkWell(
            onTap: () {
              //print(itms.position!);
              onItemClick(itms.position!);
            },
            child: Card(
              elevation: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //color: Colors.white,
                ),
                width: double.infinity,
                height: 70,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 6),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(width: 1, color: MyColors.mainC0lor),
                      // ),
                      child: Icon(itms.icon),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            itms.title!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(itms.description!,
                              style:
                                  TextStyle(fontSize: 13, letterSpacing: .3)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );*/
        },
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
          color: const Color(0xFFF5ECF2),
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
              Text(
                'Latest Live Streams',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A1A24),
                ),
              ),
              const Spacer(),
              TextButton(
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
                            color: const Color(0xFFF1E6EC),
                            child: const Center(
                                child: CupertinoActivityIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF1E6EC),
                            child: const Icon(Icons.live_tv_rounded,
                                color: Color(0xFF8A7D86), size: 36),
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
                    ? const Color(0xFF8F3E88)
                    : const Color(0xFFD8C5D3),
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



