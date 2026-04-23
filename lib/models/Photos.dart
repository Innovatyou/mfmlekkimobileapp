class Photos {
  final int? id;
  final String? title, description, date;
  List<dynamic>? media = [];

  Photos({
    this.id,
    this.media,
    this.title,
    this.description,
    this.date,
  });

  factory Photos.fromJson(Map<String, dynamic> data) {
    int id = int.parse(data['id'].toString());
    return Photos(
      id: id,
      media: data['thumbnail'] as List?,
      title: data['title'],
      description: data['description'],
      date: data['date'],
    );
  }
}

