class Articles {
  final int? id;
  final String? title, content, thumbnail;
  final String? author, date;

  Articles({
    this.id,
    this.title,
    this.author,
    this.thumbnail,
    this.content,
    this.date,
  });

  factory Articles.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Articles(
        id: id,
        title: json['title'] as String?,
        thumbnail: json['thumbnail'] as String?,
        author: json['author'] as String?,
        content: json['content'] as String?,
        date: json['date'] as String?);
  }
}

