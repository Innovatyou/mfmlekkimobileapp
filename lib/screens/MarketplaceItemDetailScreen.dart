import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/MarketplaceItem.dart';
import 'package:higherground/providers/MarketplaceModel.dart';
import 'package:higherground/screens/MarketplaceSubmitScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceItemDetailScreen extends StatefulWidget {
  static const routeName = '/marketplace/item';

  final int itemId;

  const MarketplaceItemDetailScreen({Key? key, required this.itemId})
      : super(key: key);

  @override
  State<MarketplaceItemDetailScreen> createState() =>
      _MarketplaceItemDetailScreenState();
}

class _MarketplaceItemDetailScreenState
    extends State<MarketplaceItemDetailScreen> {
  int _photoIndex = 0;
  String? _myEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await SQLiteDbProvider.db.getUserData();
      if (mounted) setState(() => _myEmail = user?.email);

      Provider.of<MarketplaceModel>(context, listen: false)
          .fetchItem(widget.itemId);
    });
  }

  bool _isOwn(MarketplaceItem item) =>
      _myEmail != null &&
      item.sellerEmail != null &&
      item.sellerEmail!.toLowerCase() == _myEmail!.toLowerCase();

  void _shareItem(MarketplaceItem item) {
    final price = item.isFree
        ? 'Free'
        : '${Provider.of<MarketplaceModel>(context, listen: false).currencySymbol}${NumberFormat('#,##0.00').format(item.price)}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${item.title} — $price'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _confirmDelete(MarketplaceItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Are you sure you want to delete this listing? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: MyColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await Provider.of<MarketplaceModel>(context, listen: false)
                      .deleteListing(item.id);
              if (ok && mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openInquirySheet(MarketplaceItem item) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: _myEmail ?? '');
    final phoneCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Send Inquiry',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Your Name *', TextInputType.name,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null),
              const SizedBox(height: 10),
              _sheetField(emailCtrl, 'Email', TextInputType.emailAddress),
              const SizedBox(height: 10),
              _sheetField(phoneCtrl, 'Phone', TextInputType.phone),
              const SizedBox(height: 10),
              TextFormField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: _sheetDeco('Message *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: MyColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok =
                        await Provider.of<MarketplaceModel>(ctx, listen: false)
                            .submitInquiry(
                                itemId: item.id,
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                message: msgCtrl.text.trim());
                    if (mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Inquiry sent to the seller!'
                          : 'Failed to send inquiry. Try again.'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: const Text('Send Inquiry',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  TextFormField _sheetField(
      TextEditingController ctrl, String label, TextInputType type,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: _sheetDeco(label),
      validator: validator,
    );
  }

  InputDecoration _sheetDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: MyColors.primary, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.surface,
      body: Consumer<MarketplaceModel>(builder: (ctx, model, _) {
        if (model.detailLoading) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator(radius: 18)),
          );
        }
        if (model.detailError || model.currentItem == null) {
          return Scaffold(
            appBar: AppBar(
                backgroundColor: MyColors.surface,
                surfaceTintColor: Colors.transparent),
            body: const Center(
                child: Text('Could not load listing.',
                    style: TextStyle(color: MyColors.textSecondary))),
          );
        }

        final item = model.currentItem!;
        final own = _isOwn(item);
        final photoUrls = item.photos.isNotEmpty
            ? item.photos.map((p) => p.url).toList()
            : (item.coverImageUrl.isNotEmpty
                ? [item.coverImageUrl]
                : <String>[]);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: photoUrls.isNotEmpty ? 280 : 0,
              backgroundColor: MyColors.surface,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: MyColors.textPrimary),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _shareItem(item),
                ),
              ],
              flexibleSpace: photoUrls.isNotEmpty
                  ? FlexibleSpaceBar(
                      background: _buildCarousel(photoUrls),
                    )
                  : null,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge (own listings only)
                    if (own) _statusBadge(item.status),
                    if (own) const SizedBox(height: 12),

                    // Title
                    Text(item.title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: MyColors.textPrimary)),
                    const SizedBox(height: 10),

                    // Price
                    _priceBadge(item, model.currencySymbol),
                    const SizedBox(height: 12),

                    // Chips row
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      _chip(
                          item.itemCondition == 'new' ? 'New' : 'Used',
                          item.itemCondition == 'new'
                              ? const Color(0xFF0C4A6E)
                              : MyColors.textSecondary,
                          item.itemCondition == 'new'
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFFF1F5F9)),
                      if (item.categoryName != null)
                        _chip(item.categoryName!, MyColors.primary,
                            MyColors.primaryVeryLight),
                    ]),

                    // Location
                    if (item.location != null && item.location!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: MyColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(item.location!,
                            style: const TextStyle(
                                fontSize: 14, color: MyColors.textSecondary)),
                      ]),
                    ],

                    // Description
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE8DDE4)),
                      const SizedBox(height: 12),
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: MyColors.textPrimary)),
                      const SizedBox(height: 6),
                      _ExpandableText(item.description!),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFE8DDE4)),
                    const SizedBox(height: 12),

                    // Seller card
                    _buildSellerCard(item),

                    const SizedBox(height: 20),

                    // Inquiry button (non-owner)
                    if (!own)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: MyColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () => _openInquirySheet(item),
                          child: const Text('Send Inquiry',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),

                    // Owner actions
                    if (own) ...[
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: MyColors.primary,
                              side: const BorderSide(color: MyColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                MarketplaceSubmitScreen.routeName,
                                arguments: item,
                              ).then((_) {
                                if (mounted) {
                                  Provider.of<MarketplaceModel>(context,
                                          listen: false)
                                      .fetchItem(widget.itemId);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: FilledButton.styleFrom(
                              backgroundColor: MyColors.danger,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _confirmDelete(item),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCarousel(List<String> urls) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: urls.length,
          onPageChanged: (i) => setState(() => _photoIndex = i),
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: urls[i],
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9)),
            errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image_rounded,
                    color: Color(0xFFCBD5E1), size: 48)),
          ),
        ),
        if (urls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _photoIndex == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _photoIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final config = <String, Map<String, dynamic>>{
      'pending': {
        'label': 'Pending Review',
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: c['bg'] as Color, borderRadius: BorderRadius.circular(20)),
      child: Text(c['label'] as String,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c['fg'] as Color)),
    );
  }

  Widget _priceBadge(MarketplaceItem item, String currency) {
    if (item.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('Free',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF065F46))),
      );
    }
    return Text(
      '$currency${NumberFormat('#,##0.00').format(item.price)}',
      style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w900, color: MyColors.primary),
    );
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _buildSellerCard(MarketplaceItem item) {
    final initials = (item.sellerName ?? '?')
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DDE4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: MyColors.primaryVeryLight,
            child: Text(initials,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: MyColors.primary,
                    fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.sellerName ?? 'Seller',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: MyColors.textPrimary)),
                if (item.sellerEmail != null && item.sellerEmail!.isNotEmpty)
                  Text(item.sellerEmail!,
                      style: const TextStyle(
                          fontSize: 12, color: MyColors.textSecondary)),
              ],
            ),
          ),
          if (item.sellerPhone != null && item.sellerPhone!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_outlined, color: MyColors.primary),
              tooltip: 'Call seller',
              onPressed: () => _launch('tel:${item.sellerPhone}'),
            ),
          if (item.sellerEmail != null && item.sellerEmail!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.email_outlined, color: MyColors.primary),
              tooltip: 'Email seller',
              onPressed: () => _launch('mailto:${item.sellerEmail}'),
            ),
        ],
      ),
    );
  }
}

// ─── Expandable text ──────────────────────────────────────────────────────────

class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText(this.text);

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 5,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14, color: MyColors.textBody, height: 1.55),
          ),
          if (widget.text.length > 200) ...[
            const SizedBox(height: 4),
            Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                  fontSize: 13,
                  color: MyColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
