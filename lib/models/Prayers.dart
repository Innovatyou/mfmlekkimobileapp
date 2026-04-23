class Prayers {
  final int? id;
  final String? title, requester;
  final String? content, date;

  Prayers({this.id, this.title, this.requester, this.content, this.date});

  factory Prayers.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    return Prayers(
      id: id,
      title: json['title'] as String?,
      requester: json['requester'] as String?,
      content: json['content'] as String?,
      date: json['date'] as String?,
    );
  }
}

