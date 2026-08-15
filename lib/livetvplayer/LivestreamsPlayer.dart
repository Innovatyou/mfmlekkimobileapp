import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:higherground/screens/LivestreamsScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:wakelock/wakelock.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'UnifiedLivePlayer.dart';

class LivestreamsPlayer extends StatefulWidget {
  static String routeName = "/livestreamsplayer";
  final LiveStreams? liveStreams;

  LivestreamsPlayer({Key? key, this.liveStreams}) : super(key: key);

  @override
  _VideoViewerScreenState createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<LivestreamsPlayer> {
  LiveStreams? currentMedia;
  List<LiveStreams> upNext = [];
  bool loadingUpNext = false;

  @override
  void initState() {
    currentMedia = widget.liveStreams;
    _loadUpNext();
    _toggleWakelock(true);
    super.initState();
  }

  Future<void> _loadUpNext() async {
    setState(() {
      loadingUpNext = true;
    });
    try {
      final response = await Utility.getDio().post(
        ApiUrl.FETCH_LIVESTREAMS,
        data: jsonEncode({
          'data': {'page': '0'}
        }),
      );
      if (response.statusCode == 200) {
        final dynamic res = Utility.decodeResponse(response.data);
        final List<dynamic> raw = (res['livestreams'] ?? []) as List<dynamic>;
        final list = raw
            .map((e) => LiveStreams.fromJson(e as Map<String, dynamic>))
            .where((e) => (e.id != currentMedia?.id) && (e.type ?? '').isNotEmpty)
            .take(8)
            .toList();
        if (mounted) {
          setState(() {
            upNext = list;
          });
        }
      }
    } catch (_) {
      // Keep screen usable even when up-next fetch fails.
    } finally {
      if (mounted) {
        setState(() {
          loadingUpNext = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _toggleWakelock(false);
    super.dispose();
  }

  Future<void> _toggleWakelock(bool enabled) async {
    try {
      await Wakelock.toggle(enable: enabled);
    } catch (e) {
      debugPrint('Wakelock toggle failed: $e');
    }
  }

  Future<void> _shareCurrentStream() async {
    final current = currentMedia;
    if (current == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final shareTitle = t.sharefiletitle + (current.title ?? '');
    await Share.share(
      shareTitle +
          '\n' +
          t.sharefilebody +
          ' http://play.google.com/store/apps/details?id=' +
          packageName,
      subject: shareTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        title: Text(
          t.livestreams,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildVideoContainer(currentMedia!),
            _buildMetaSection(),
            if ((currentMedia?.description ?? '').trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8DDE4)),
                ),
                child: Text(
                  currentMedia!.description!,
                  style: const TextStyle(
                    color: Color(0xFF6F616A),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Text(
                'Up Next',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[900],
                ),
              ),
            ),
            if (loadingUpNext)
              const Center(child: CupertinoActivityIndicator())
            else if (upNext.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8DDE4)),
                    ),
                    child: const Text(
                      'No more streamed videos available right now. Tap to view all streams.',
                      style: TextStyle(color: Color(0xFF475569)),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: upNext.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final live = upNext[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        currentMedia = live;
                        upNext = upNext.where((e) => e.id != live.id).toList();
                      });
                      _loadUpNext();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8DDE4)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 120,
                              height: 68,
                              child: CachedNetworkImage(
                                imageUrl: Utility.convertLocalhostToEmulator(live.coverphoto),
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.live_tv_rounded,
                                  color: Color(0xFF8A7D86),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              live.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0f172a),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildMetaSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentMedia?.title ?? '',
            style: const TextStyle(
              color: Color(0xFF0f172a),
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Text(
                'Streamed video',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF475569),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDE4EA)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(LivestreamsScreen.routeName);
                },
                icon: const Icon(
                  LineAwesomeIcons.list,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _shareCurrentStream,
                icon: const Icon(
                  LineAwesomeIcons.share,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildVideoContainer(LiveStreams currentMedia) {
    // CRITICAL ROUTING: UnifiedLivePlayer intelligently routes based on stream source
    // - YouTube livestreams (type='youtube') → LiveYoutubePlayerIFrame
    // - HLS/RTMP streams (type='m3u8'/'rtmp') → LiveBetterPlayerWidget
    // - Facebook livestreams (type='facebook') → LiveFacebookPlayer
    // This prevents ExoPlaybackException errors from YouTube content
    return UnifiedLivePlayer(
      media: currentMedia,
      playerKey: UniqueKey(),
    );
  }
}


