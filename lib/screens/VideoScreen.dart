import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/models/Media.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/VideoScreensModel.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/widgets/MediaItemTile.dart';

class VideoScreen extends StatefulWidget {
  static const routeName = "/videoscreen";
  const VideoScreen({Key? key}) : super(key: key);

  @override
  VideoScreenRouteState createState() => VideoScreenRouteState();
}

class VideoScreenRouteState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoScreensModel(
        Provider.of<AppStateManager>(context, listen: false).userdata,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.videos,
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
        body: const _VideoScreenBody(),
      ),
    );
  }
}

class _VideoScreenBody extends StatefulWidget {
  const _VideoScreenBody();

  @override
  _VideoScreenBodyState createState() => _VideoScreenBodyState();
}

class _VideoScreenBodyState extends State<_VideoScreenBody> {
  late VideoScreensModel _model;

  void _onRefresh() => _model.loadItems();
  void _onLoading() => _model.loadMoreItems();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<VideoScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<VideoScreensModel>(context);
    final List<Media> items = _model.mediaList ?? [];

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
          : ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) => ItemTile(
                mediaList: items,
                index: index,
                object: items[index],
              ),
            ),
    );
  }

  CustomFooter _buildFooter() => CustomFooter(
        builder: (context, mode) {
          late Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore,
                style: TextStyle(color: MyColors.textSecondary, fontSize: 12));
          } else if (mode == LoadStatus.loading) {
            body = const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: MyColors.primary),
            );
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry,
                style: TextStyle(color: MyColors.danger, fontSize: 12));
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore,
                style: TextStyle(color: MyColors.textSecondary, fontSize: 12));
          } else {
            body = Text(t.nomoredata,
                style: TextStyle(color: MyColors.textDisabled, fontSize: 12));
          }
          return SizedBox(height: 55, child: Center(child: body));
        },
      );
}
