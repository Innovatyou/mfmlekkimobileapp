import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebPage extends StatefulWidget {
  const InAppWebPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<InAppWebPage> createState() => _InAppWebPageState();
}

class _InAppWebPageState extends State<InAppWebPage> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;

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
              _hasError = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Open Link'),
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 42,
                      color: Color(0xFF8A7D86),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load this page right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.url,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                        });
                        _controller.loadRequest(Uri.parse(widget.url));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (!_hasError && _loadingProgress < 100)
            LinearProgressIndicator(value: _loadingProgress / 100),
        ],
      ),
    );
  }
}
