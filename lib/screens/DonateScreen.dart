import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:higherground/utils/my_colors.dart';

class DonateScreen extends StatefulWidget {
  static const routeName = '/donate';

  const DonateScreen({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;

  static const _teal = Color(0xFF1E8B72);
  static const _tealDark = Color(0xFF166B57);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
              if (progress > 0) _hasError = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() => _hasError = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _reload() {
    setState(() => _hasError = false);
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.surface,
      appBar: AppBar(
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 17),
            SizedBox(width: 7),
            Text(
              'Give Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
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
      body: Column(
        children: [
          _buildHeroCard(),
          Expanded(child: _buildWebContent()),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _tealDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _teal.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support the Ministry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'God loves a cheerful giver. — 2 Cor 9:7',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_hasError)
            _buildErrorState()
          else
            WebViewWidget(controller: _controller),
          if (!_hasError && _loadingProgress < 100)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress / 100,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(_teal),
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFD7EFE8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: _teal, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load giving form',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: MyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: MyColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: _reload,
            ),
          ],
        ),
      ),
    );
  }
}
