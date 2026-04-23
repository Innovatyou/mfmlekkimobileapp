class Radios {
  final int? id;
  final String? title, coverPhoto, streamUrl;

  Radios({this.id, this.title, this.coverPhoto, this.streamUrl});

  factory Radios.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Radios(
        id: id,
        title: json['title'] as String?,
        coverPhoto: json['cover_photo'] as String?,
        streamUrl: json['link'] as String?);
  }
}

