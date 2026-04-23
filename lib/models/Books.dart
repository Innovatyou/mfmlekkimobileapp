class Books {
  final int? id;
  final String? title, thumbnail, book;
  final String? author, description, pages, link;

  Books(
      {this.id,
      this.title,
      this.thumbnail,
      this.book,
      this.author,
      this.description,
      this.pages,
      this.link});

  factory Books.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Books(
      id: id,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      book: json['book'] as String?,
      author: json['author'] as String?,
      description: json['description'] as String?,
      pages: json['pages'] as String?,
      link: json['book'] as String?,
    );
  }
}

