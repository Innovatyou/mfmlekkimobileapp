class Testimony {
  final int? id;
  final String? title, testifier;
  final String? content, date;

  Testimony({this.id, this.title, this.testifier, this.content, this.date});

  factory Testimony.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Testimony(
      id: id,
      title: json['title'] as String?,
      testifier: json['testifier'] as String?,
      content: json['content'] as String?,
      date: json['date'] as String?,
    );
  }
}

