import 'package:flutter/material.dart';
import 'package:higherground/models/LiveStreams.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lightweight placeholder for YouTube iframe player.
/// To avoid API mismatches during migration, this widget opens the
/// YouTube livestream in the external browser. Replace with a proper
/// iframe/player implementation when ready.
class LiveYoutubePlayerIFrame extends StatelessWidget {
  final LiveStreams media;

  const LiveYoutubePlayerIFrame({Key? key, required this.media}) : super(key: key);

  void _openYoutubeInBrowser() async {
    final id = media.streamUrl ?? '';
    // Attempt to open the original stream URL or fallback to YouTube watch URL
    final uri = Uri.tryParse(id) ?? Uri.parse('https://www.youtube.com');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text('Open livestream'),
        onPressed: _openYoutubeInBrowser,
      ),
    );
  }
}



