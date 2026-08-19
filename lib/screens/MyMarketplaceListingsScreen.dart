import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/providers/MarketplaceModel.dart';
import 'package:higherground/screens/MarketplaceItemDetailScreen.dart';
import 'package:higherground/screens/MarketplaceSubmitScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyMarketplaceListingsScreen extends StatefulWidget {
  static const routeName = '/marketplace/my-listings';

  const MyMarketplaceListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyMarketplaceListingsScreen> createState() =>
      _MyMarketplaceListingsScreenState();
}

class _MyMarketplaceListingsScreenState
    extends State<MyMarketplaceListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = ['All', 'Pending', 'Active', 'Sold', 'Rejected'];
  static const _statuses = [null, 'pending', 'active', 'sold', 'inactive'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceModel>(context, listen: false).fetchMyListings();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<MarketplaceItem> _filtered(List<MarketplaceItem> all, String? status) {
    if (status == null) return all;
    return all.where((i) => i.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: MyColors.textPrimary),
        title: const Text('My Adverts',
            style: TextStyle(
                color: MyColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: MyColors.primary,
          unselectedLabelColor: MyColors.textSecondary,
          indicatorColor: MyColors.primary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<MarketplaceModel>(builder: (ctx, model, _) {
        if (model.myLoading) {
          return const Center(child: CupertinoActivityIndicator(radius: 18));
        }
        if (model.myError) {
          return _centeredMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load your listings',
            subtitle: 'Check your connection and try again.',
            action: () => model.fetchMyListings(),
            actionLabel: 'Retry',
          );
        }

        return TabBarView(
          controller: _tabCtrl,
          children: List.generate(_tabs.length, (i) {
            final items = _filtered(model.myListings, _statuses[i]);
            if (items.isEmpty) {
              return _emptyTab(_tabs[i], () => Navigator.pushNamed(
                  context, MarketplaceSubmitScreen.routeName));
            }
            return _buildList(items, model.currencySymbol);
          }),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Advert',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () =>
            Navigator.pushNamed(context, MarketplaceSubmitScreen.routeName)
                .then((_) => Provider.of<MarketplaceModel>(context,
                        listen: false)
                    .fetchMyListings()),
      ),
    );
  }

  Widget _buildList(List<MarketplaceItem> items, String currency) {
    return RefreshIndicator(
      color: MyColors.primary,
      onRefresh: () =>
          Provider.of<MarketplaceModel>(context, listen: false)
              .fetchMyListings(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: items.length,
        itemBuilder: (ctx, i) =>
            _MyListingRow(item: items[i], currency: currency),
      ),
    );
  }

  Widget _emptyTab(String tab, VoidCallback onPost) {
    final messages = <String, String>{
      'Pending': 'No listings awaiting review.',
      'Active': 'You have no active listings.',
      'Sold': 'No items marked as sold yet.',
      'Rejected': 'No rejected listings.',
    };
    return _centeredMessage(
      icon: Icons.inbox_outlined,
      title: messages[tab] ?? 'No adverts yet',
      subtitle: 'Post your first advert to get started.',
      action: onPost,
      actionLabel: 'Post Advert',
    );
  }

  Widget _centeredMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback action,
    required String actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: MyColors.textSecondary)),
          const SizedBox(height: 20),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: MyColors.primary),
            onPressed: action,
            child: Text(actionLabel),
          ),
        ]),
      ),
    );
  }
}

// ─── My listing row ───────────────────────────────────────────────────────────

class _MyListingRow extends StatelessWidget {
  final MarketplaceItem item;
  final String currency;

  const _MyListingRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, MarketplaceItemDetailScreen.routeName,
          arguments: item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Row(children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.coverImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: const Color(0xFFF1F5F9)),
                      errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.image_rounded,
                              color: Color(0xFFCBD5E1))),
                    )
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.storefront_outlined,
                          color: Color(0xFFCBD5E1))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MyColors.textPrimary)),
                const SizedBox(height: 4),
                item.isFree
                    ? const Text('Free',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669)))
                    : Text(
                        '$currency${NumberFormat('#,##0.00').format(item.price)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: MyColors.primary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statusBadge(item.status),
                    const Spacer(),
                    if (item.createdAt != null) _dateLabel(item.createdAt!),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ]),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final config = <String, Map<String, dynamic>>{
      'pending': {
        'label': 'Pending',
        'bg': const Color(0xFFFEF3C7),
        'fg': const Color(0xFF92400E)
      },
      'active': {
        'label': 'Active',
        'bg': const Color(0xFFD1FAE5),
        'fg': const Color(0xFF065F46)
      },
      'inactive': {
        'label': 'Rejected',
        'bg': const Color(0xFFFEE2E2),
        'fg': const Color(0xFF991B1B)
      },
      'sold': {
        'label': 'Sold',
        'bg': const Color(0xFFDBEAFE),
        'fg': const Color(0xFF1E40AF)
      },
    };
    final c = config[status] ?? config['pending']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: c['bg'] as Color,
          borderRadius: BorderRadius.circular(20)),
      child: Text(c['label'] as String,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c['fg'] as Color)),
    );
  }

  Widget _dateLabel(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      return Text(DateFormat('d MMM yy').format(dt),
          style: const TextStyle(
              fontSize: 11, color: MyColors.textSecondary));
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
