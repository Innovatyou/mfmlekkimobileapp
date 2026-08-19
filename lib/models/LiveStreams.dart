class LiveStreams {
  final int? id;
  final String? title, coverphoto, description, streamUrl, type;

  LiveStreams(
      {this.id,
      this.title,
      this.coverphoto,
      this.type,
      this.description,
      this.streamUrl});

  factory LiveStreams.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return LiveStreams(
        id: id,
        title: json['title'] as String?,
        coverphoto: _resolveCoverPhoto(
          json['cover_photo']?.toString(),
          json['link']?.toString(),
        ),
        type: json['source'] as String?,
        description: json['description'] as String?,
        streamUrl: json['link'] as String?);
  }

  static String _resolveCoverPhoto(String? coverPhoto, String? streamUrl) {
    if (coverPhoto != null && coverPhoto.trim().isNotEmpty) return coverPhoto;
    if (streamUrl == null || streamUrl.trim().isEmpty) return '';
    final uri = Uri.tryParse(streamUrl.trim());
    if (uri == null) return '';
    String? videoId;
    if (uri.host.contains('youtu.be')) {
      videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else if (uri.host.contains('youtube.com') ||
        uri.host.contains('youtube-nocookie.com')) {
      videoId = uri.queryParameters['v'];
      if ((videoId == null || videoId.isEmpty) && uri.pathSegments.length > 1) {
        const supportedPaths = {'embed', 'shorts', 'live'};
        if (supportedPaths.contains(uri.pathSegments.first)) {
          videoId = uri.pathSegments[1];
        }
      }
    }
    return videoId == null || videoId.isEmpty
        ? ''
        : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
  }
}

