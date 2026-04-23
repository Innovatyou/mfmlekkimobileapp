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
        coverphoto: json['cover_photo'] as String?,
        type: json['source'] as String?,
        description: json['description'] as String?,
        streamUrl: json['link'] as String?);
  }
}

