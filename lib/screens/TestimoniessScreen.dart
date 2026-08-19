import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Testimony.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/TestimonyScreensModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/PostTestimonyScreen.dart';
import 'package:higherground/screens/TestimonyViewer.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/my_colors.dart';

class TestimoniessScreen extends StatefulWidget {
  static const routeName = "/TestimoniessScreen";
  TestimoniessScreen();

  @override
  TestimoniessScreennRouteState createState() =>
      new TestimoniessScreennRouteState();
}

class TestimoniessScreennRouteState extends State<TestimoniessScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TestimonyScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.testimonies,
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
        body: AudioScreenBody(),
        floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final Userdata? userdata =
                      await SQLiteDbProvider.db.getUserData();
                  if (!context.mounted) return;
                  if (userdata == null) {
                    Navigator.of(context)
                        .pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context)
                        .pushNamed(PostTestimonyScreen.routeName);
                  }
                },
                backgroundColor: MyColors.primary,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
      ),
    );
  }
}

class AudioScreenBody extends StatefulWidget {
  @override
  MediaScreenRouteState createState() => new MediaScreenRouteState();
}

class MediaScreenRouteState extends State<AudioScreenBody> {
  late TestimonyScreensModel mediaScreensModel;
  List<Testimony>? items;
  var titleTextStyle = TextStyle(
    color: Colors.black87,
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );

  void _onRefresh() async {
    mediaScreensModel.loadItems();
  }

  void _onLoading() async {
    mediaScreensModel.loadMoreItems();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      Provider.of<TestimonyScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<TestimonyScreensModel>(context);
    items = mediaScreensModel.itemList;
    final safeItems = items ?? [];

    if (mediaScreensModel.isLoading && safeItems.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: MyColors.primary));
    }
    if (mediaScreensModel.isError && safeItems.isEmpty) {
      return NoitemScreen(
          title: t.oops, message: t.dataloaderror, onClick: _onRefresh);
    }
    if (safeItems.isEmpty) {
      return NoitemScreen(
          title: t.oops, message: t.noitemstodisplay, onClick: _onRefresh);
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropMaterialHeader(
        backgroundColor: MyColors.primary,
        color: Colors.white,
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
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
      controller: mediaScreensModel.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.separated(
        itemCount: safeItems.length,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final testimony = safeItems[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8DDE4)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onTap: () => Navigator.pushNamed(
                  context, TestimonyViewer.routeName,
                  arguments: testimony),
              leading: ClipOval(
                child: Container(
                  color: const Color(0xFFF5EAF1),
                  width: 50.0,
                  height: 50.0,
                  child: const Icon(LineAwesomeIcons.quote_left,
                      color: Color(0xFF6366f1)),
                ),
              ),
              title: Text(
                testimony.title ?? '',
                maxLines: 2,
                style: titleTextStyle,
              ),
              subtitle: Text(
                '${testimony.date ?? ''} | ${testimony.testifier ?? ''}',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
              trailing: const Icon(Icons.navigate_next_rounded),
            ),
          );
        },
      ),
    );
  }
}



