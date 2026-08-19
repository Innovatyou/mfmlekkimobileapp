import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Prayers.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/PrayerScreensModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/PostPrayerScreen.dart';
import 'package:higherground/screens/PrayerViewer.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'package:higherground/utils/my_colors.dart';

class PrayersScreen extends StatefulWidget {
  static const routeName = "/PrayersScreen";
  const PrayersScreen({Key? key}) : super(key: key);

  @override
  PrayersScreenRouteState createState() => PrayersScreenRouteState();
}

class PrayersScreenRouteState extends State<PrayersScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrayerScreensModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F4F9),
        appBar: AppBar(
          title: Text(
            t.Prayerrequests,
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
        body: const _PrayersBody(),
        floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final Userdata? userdata =
                      await SQLiteDbProvider.db.getUserData();
                  if (!context.mounted) return;
                  if (userdata == null) {
                    Navigator.of(context)
                        .pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context).pushNamed(PostPrayerScreen.routeName);
                  }
                },
                backgroundColor: MyColors.primary,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
      ),
    );
  }
}

class _PrayersBody extends StatefulWidget {
  const _PrayersBody();

  @override
  _PrayersBodyState createState() => _PrayersBodyState();
}

class _PrayersBodyState extends State<_PrayersBody> {
  late PrayerScreensModel _model;

  void _onRefresh() => _model.loadItems();
  void _onLoading() => _model.loadMoreItems();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<PrayerScreensModel>(context, listen: false).loadItems());
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<PrayerScreensModel>(context);
    final List<Prayers> items = _model.itemList ?? [];

    if (_model.isLoading && items.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: MyColors.primary));
    }
    if (_model.isError && items.isEmpty) {
      return NoitemScreen(
          title: t.oops, message: t.dataloaderror, onClick: _onRefresh);
    }
    if (items.isEmpty) {
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
      footer: _buildFooter(),
      controller: _model.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.separated(
        itemCount: items.length,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _PrayerTile(prayer: items[index]),
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
// Prayer tile
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerTile extends StatelessWidget {
  final Prayers prayer;
  const _PrayerTile({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.pushNamed(context, PrayerViewer.routeName, arguments: prayer),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFe2e8f0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFe0e7ff),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volunteer_activism_rounded,
                    color: MyColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0f172a),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${prayer.date ?? ''} · ${prayer.requester ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFcbd5e1), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
