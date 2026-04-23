import 'package:flutter/material.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubePlayerPlaceholder extends StatelessWidget {
  final String? streamUrl;
  final String? title;

  const YoutubePlayerPlaceholder({Key? key, this.streamUrl, this.title})
      : super(key: key);

  void _openYoutubeInBrowser() async {
    final id = Utility.extractYoutubeVideoId(streamUrl ?? '');
    final url = 'https://www.youtube.com/watch?v=$id';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[YoutubePlaceholder] Failed to open url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = Utility.extractYoutubeVideoId(streamUrl ?? '');
    final thumb = id.isNotEmpty
        ? 'https://img.youtube.com/vi/$id/hqdefault.jpg'
        : null;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            child: thumb != null
                ? Image.network(thumb, fit: BoxFit.cover)
                : Center(child: Icon(Icons.ondemand_video, size: 56)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title ?? '',
                    style: Theme.of(context).textTheme.bodyLarge)),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open YouTube'),
                onPressed: _openYoutubeInBrowser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}



