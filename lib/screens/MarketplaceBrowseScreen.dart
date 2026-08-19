import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/providers/MarketplaceModel.dart';
import 'package:higherground/screens/MarketplaceItemDetailScreen.dart';
import 'package:higherground/screens/MarketplaceSubmitScreen.dart';
import 'package:higherground/screens/MyMarketplaceListingsScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MarketplaceBrowseScreen extends StatefulWidget {
  static const routeName = '/marketplace';

  const MarketplaceBrowseScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceBrowseScreen> createState() =>
      _MarketplaceBrowseScreenState();
}

class _MarketplaceBrowseScreenState extends State<MarketplaceBrowseScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isGridView = true;

  // Filter state
  int? _selectedCategoryId;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<MarketplaceModel>(context, listen: false);
      model.fetchCategories();
      model.fetchListings(refresh: true);
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        Provider.of<MarketplaceModel>(context, listen: false).fetchListings();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final model = Provider.of<MarketplaceModel>(context, listen: false);
    int? tmpCat = _selectedCategoryId;
    String? tmpCond = _selectedCondition;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Listings',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {
                        setS(() {
                          tmpCat = null;
                          tmpCond = null;
                        });
                      },
                      child: Text('Reset',
                          style: TextStyle(color: MyColors.mainC0lor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Category',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _filterChip(
                        label: 'All',
                        selected: tmpCat == null,
                        onTap: () => setS(() => tmpCat = null)),
                    ...model.categories.map((c) => _filterChip(
                          label: c.name,
                          selected: tmpCat == c.id,
                          onTap: () => setS(() => tmpCat = c.id),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Condition',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip(
                        label: 'All',
                        selected: tmpCond == null,
                        onTap: () => setS(() => tmpCond = null)),
                    _filterChip(
                        label: 'New',
                        selected: tmpCond == 'new',
                        onTap: () => setS(() => tmpCond = 'new')),
                    _filterChip(
                        label: 'Used',
                        selected: tmpCond == 'used',
                        onTap: () => setS(() => tmpCond = 'used')),
                    _filterChip(
                        label: 'Free',
                        selected: tmpCond == 'free',
                        onTap: () => setS(() => tmpCond = 'free')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: MyColors.mainC0lor,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      setState(() {
                        _selectedCategoryId = tmpCat;
                        _selectedCondition = tmpCond;
                      });
                      model.browseCategoryId = tmpCat;
                      model.fetchListings(refresh: true);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _filterChip(
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? MyColors.mainC0lor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? MyColors.mainC0lor : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF475569),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Marketplace',
            style: TextStyle(
                color: MyColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                color: MyColors.textSecondary),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_rounded,
                color: MyColors.textSecondary),
            tooltip: 'My Adverts',
            onPressed: () => Navigator.pushNamed(
                context, MyMarketplaceListingsScreen.routeName),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyColors.mainC0lor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Sell / Post Advert',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () =>
            Navigator.pushNamed(context, MarketplaceSubmitScreen.routeName),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) {
                  Provider.of<MarketplaceModel>(context, listen: false)
                      .setSearchFilter(v.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Search listings…',
                  hintStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF94A3B8), size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            Provider.of<MarketplaceModel>(context,
                                    listen: false)
                                .setSearchFilter('');
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Color(0xFF94A3B8), size: 18))
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openFilterSheet,
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color:
                    (_selectedCategoryId != null || _selectedCondition != null)
                        ? MyColors.primary
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(Icons.tune_rounded,
                  color: (_selectedCategoryId != null ||
                          _selectedCondition != null)
                      ? Colors.white
                      : MyColors.textSecondary,
                  size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<MarketplaceModel>(builder: (ctx, model, _) {
      if (model.browseLoading && model.listings.isEmpty) {
        return const Center(child: CupertinoActivityIndicator(radius: 18));
      }

      if (model.browseError && model.listings.isEmpty) {
        return _emptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load listings',
          subtitle: 'Check your connection and try again.',
          action: () => model.fetchListings(refresh: true),
          actionLabel: 'Retry',
        );
      }

      if (!model.browseLoading && model.listings.isEmpty) {
        return _emptyState(
          icon: Icons.storefront_outlined,
          title: 'No listings yet',
          subtitle: 'Be the first to post an advert!',
          action: () =>
              Navigator.pushNamed(context, MarketplaceSubmitScreen.routeName),
          actionLabel: 'Post Advert',
        );
      }

      return _isGridView ? _buildGrid(model) : _buildList(model);
    });
  }

  Widget _buildGrid(MarketplaceModel model) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: model.listings.length + (model.hasMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i >= model.listings.length) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return _ListingCard(
            item: model.listings[i], currency: model.currencySymbol);
      },
    );
  }

  Widget _buildList(MarketplaceModel model) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: model.listings.length + (model.hasMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i >= model.listings.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        return _ListingRow(
            item: model.listings[i], currency: model.currencySymbol);
      },
    );
  }

  Widget _emptyState(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback action,
      required String actionLabel}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: MyColors.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: MyColors.textSecondary)),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MyColors.mainC0lor),
            onPressed: action,
            child: Text(actionLabel),
          ),
        ]),
      ),
    );
  }
}

// ─── Grid card ────────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final MarketplaceItem item;
  final String currency;

  const _ListingCard({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, MarketplaceItemDetailScreen.routeName,
          arguments: item.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8DDE4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover photo
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: item.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                                child: Icon(Icons.image_rounded,
                                    color: Color(0xFFCBD5E1), size: 32))),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: MyColors.textPrimary)),
                    const Spacer(),
                    _priceBadge(),
                    const SizedBox(height: 4),
                    Row(children: [
                      _conditionChip(),
                      const Spacer(),
                      if (item.categoryName != null)
                        Flexible(
                          child: Text(item.categoryName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: MyColors.textSecondary)),
                        ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      _sellerDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10, color: MyColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
          child: Icon(Icons.storefront_outlined,
              color: Color(0xFFCBD5E1), size: 32)));

  Widget _priceBadge() {
    if (item.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('Free',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF065F46))),
      );
    }
    return Text(
      '$currency${NumberFormat('#,##0.00').format(item.price)}',
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w800, color: MyColors.primary),
    );
  }

  Widget _conditionChip() {
    final isNew = item.itemCondition == 'new';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: isNew ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        isNew ? 'New' : 'Used',
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isNew ? const Color(0xFF0C4A6E) : MyColors.textSecondary),
      ),
    );
  }

  String _sellerDate() {
    final seller = item.sellerName?.split(' ').first ?? '';
    if (item.createdAt == null) return seller;
    try {
      final dt = DateTime.parse(item.createdAt!);
      return '$seller · ${DateFormat('d MMM').format(dt)}';
    } catch (_) {
      return seller;
    }
  }
}

// ─── List row ─────────────────────────────────────────────────────────────────

class _ListingRow extends StatelessWidget {
  final MarketplaceItem item;
  final String currency;

  const _ListingRow({required this.item, required this.currency});

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
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
                  Row(children: [
                    if (item.categoryName != null)
                      Text(item.categoryName!,
                          style: const TextStyle(
                              fontSize: 11, color: MyColors.textSecondary)),
                    if (item.categoryName != null)
                      const Text(' · ',
                          style: TextStyle(color: MyColors.textSecondary)),
                    Text(item.itemCondition == 'new' ? 'New' : 'Used',
                        style: const TextStyle(
                            fontSize: 11, color: MyColors.textSecondary)),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
