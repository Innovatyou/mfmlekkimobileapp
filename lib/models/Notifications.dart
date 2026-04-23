import 'UserPosts.dart';

class Notifications {
  int? id = 0;
  int? itmId = 0;
  String? email = "";
  String? name = "";
  String? avatar = "", coverPhoto = "", title = "", message = "";
  String? type = "";
  int? timestamp = 1;
  UserPosts? userPosts;

  Notifications(
      {this.id,
      this.itmId,
      this.email,
      this.name,
      this.coverPhoto,
      this.avatar,
      this.title,
      this.message,
      this.type,
      this.timestamp,
      this.userPosts});

  factory Notifications.fromJson(Map<String, dynamic> json) {
    int id = int.parse(json['id'].toString());
    int itmId = int.parse(json['itm_id'].toString());
    int timestamp = int.parse(json['timestamp'].toString());
    String? type = json['type'] as String?;
    //print(json);
    return Notifications(
        id: id,
        itmId: itmId,
        name: (json['firstname'] as String?).toString() +
            " " +
            (json['lastname'] as String?).toString(),
        email: json['email'] as String?,
        avatar: json['photo'] as String?,
        coverPhoto: json['coverphoto'] as String?,
        title: json['title'] as String?,
        message: json['message'] as String?,
        type: type,
        timestamp: timestamp,
        userPosts: json.containsKey("post")
            ? UserPosts.fromJson2(json['post'])
            : null);
  }
}

