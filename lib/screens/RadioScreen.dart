import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:higherground/audio_player/radio_player.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/models/Radios.dart';
import 'package:higherground/providers/AudioPlayerModel.dart';
import 'package:higherground/providers/RadioScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RadioScreen extends StatefulWidget {
  static const routeName = '/RadioScreen';
  const RadioScreen({Key? key}) : super(key: key);

  @override
  RadioScreenRouteState createState() => RadioScreenRouteState();
}

class RadioScreenRouteState extends State<RadioScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RadioScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.radiostreams,
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
        body: const _RadioBody(),
      ),
    );
  }
}

class _RadioBody extends StatefulWidget {
  const _RadioBody();

  @override
  _RadioBodyState createState() => _RadioBodyState();
}

class _RadioBodyState extends State<_RadioBody> {
  late RadioScreensModel _model;

  void _onRefresh() => _model.loadItems();
  void _onLoading() => _model.loadMoreItems();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<RadioScreensModel>(context, listen: false).loadItems());
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<RadioScreensModel>(context);
    final List<Radios> items = _model.mediaList ?? [];

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
              title: t.oops,
              message: t.dataloaderror,
              onClick: _onRefresh,
            )
          : GridView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final radio = items[index];
                return _RadioCard(
                  radio: radio,
                  onTap: () {
                    final media = Media(
                      id: radio.id,
                      title: radio.title,
                      coverPhoto: radio.coverPhoto,
                      streamUrl: radio.streamUrl,
                    );
                    final mediaList = items
                        .map((e) => Media(
                              id: e.id,
                              title: e.title,
                              coverPhoto: e.coverPhoto,
                              streamUrl: e.streamUrl,
                            ))
                        .toList();
                    Provider.of<AudioPlayerModel>(context, listen: false)
                        .prepareradioplayer(mediaList, media);
                    Navigator.of(context).pushNamed(RadioPlayer.routeName);
                  },
                );
              },
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
// Radio card
// ─────────────────────────────────────────────────────────────────────────────

class _RadioCard extends StatelessWidget {
  final Radios radio;
  final VoidCallback onTap;
  const _RadioCard({required this.radio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFe2e8f0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover image
              (radio.coverPhoto != null && radio.coverPhoto!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: radio.coverPhoto!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: MyColors.primaryVeryLight),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
              // Bottom gradient + title
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xCC0d1117), Color(0x00000000)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  child: Text(
                    radio.title ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              // Play overlay on center
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: MyColors.primary.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.radio_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: MyColors.primaryVeryLight,
        child: const Icon(Icons.radio_rounded,
            color: MyColors.primary, size: 36),
      );
}
