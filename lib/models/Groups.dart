class Groups {
  final int? id;
  final String? title, description;
  final String? leader, time, location;
  final int? members;
  bool ismember = false;

  Groups({
    this.id,
    this.title,
    this.description,
    this.leader,
    this.time,
    this.location,
    this.members,
    this.ismember = false,
  });

  factory Groups.fromJson(Map<String, dynamic> json) {
    //print(json);
    int id = int.parse(json['id'].toString());
    int members = int.parse(json['members'].toString());
    int ismember = int.parse(json['ismember'].toString());
    return Groups(
      id: id,
      title: json['title'] as String?,
      description: json['description'] as String?,
      leader: json['leader'] as String?,
      time: json['time'] as String?,
      location: json['location'] as String?,
      members: members,
      ismember: ismember == 0,
    );
  }
}

