class Userdata {
  String? email = "", name = "";
  String? firstname = "";
  String? lastname = "";
  String? photo = "", gender = "", aboutme = "", coverphoto = "";
  String? dob = "",
      phonenumber = "",
      address = "",
      occupation = "",
      facebook = "",
      twitter = "",
      linkedln = "";
  bool following = false;
  // Bearer token for the Marketplace/Partnership/Counseling/MemberCare mobile
  // endpoints — returned by loginapp/createaccount, persisted locally.
  String? apiToken;

  static const String TABLE = "userdata";
  static final columns = [
    "email",
    "firstname",
    "lastname",
    "aboutme",
    "coverphoto",
    "photo",
    "gender",
    "dob",
    "phonenumber",
    "address",
    "occupation",
    "facebook",
    "twitter",
    "linkedln",
    "apiToken",
  ];

  Userdata({
    this.email,
    this.name,
    this.firstname,
    this.lastname,
    this.aboutme,
    this.coverphoto,
    this.photo,
    this.gender,
    this.dob,
    this.phonenumber,
    this.address,
    this.occupation,
    this.facebook,
    this.twitter,
    this.linkedln,
    this.following = false,
    this.apiToken,
  });

  factory Userdata.fromJson(Map<String, dynamic> json) {
    //print(json);
    final firstname = json['firstname'] as String?;
    final lastname = json['lastname'] as String?;
    final nameStr = (firstname != null && firstname.isNotEmpty ? firstname : "") +
        (lastname != null && lastname.isNotEmpty ? " " + lastname : "");

    return Userdata(
      firstname: firstname,
      lastname: lastname,
      name: nameStr.isNotEmpty ? nameStr : "",
      aboutme: json['aboutme'] as String?,
      coverphoto: json['coverphoto'] as String?,
      email: json['email'] as String?,
      photo: json['thumbnail'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      phonenumber: json['phonenumber'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      linkedln: json['linkedln'] as String?,
      apiToken: json['api_token'] as String?,
    );
  }

  factory Userdata.fromMembersJson(Map<String, dynamic> json) {
    //print(json);
    return Userdata(
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      name: (json['firstname'] as String?).toString() +
          " " +
          (json['lastname'] as String?).toString(),
      email: json['email'] as String?,
      photo: json['thumbnail'] as String?,
      aboutme: "",
      coverphoto: json['coverphoto'] as String?,
      gender: "",
      dob: "",
      phonenumber: "",
      address: "",
      occupation: "",
      facebook: "",
      twitter: "",
      linkedln: "",
    );
  }

  factory Userdata.fromFCMJson(Map<String, dynamic> json) {
    return Userdata(
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      name: (json['firstname'] as String?).toString() +
          " " +
          (json['lastname'] as String?).toString(),
      email: json['email'] as String?,
      photo: json['thumbnail'] as String?,
      aboutme: "",
      coverphoto: "",
      gender: "",
      dob: "",
      phonenumber: "",
      address: "",
      occupation: "",
      facebook: "",
      twitter: "",
      linkedln: "",
    );
  }

  factory Userdata.fromJson2(Map<String, dynamic> json) {
    int following = 0;
    return Userdata(
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      name: (json['firstname'] as String?).toString() +
          " " +
          (json['lastname'] as String?).toString(),
      email: json['email'] as String?,
      aboutme: json['aboutme'] as String?,
      coverphoto: json['coverphoto'] as String?,
      photo: json['photo'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      phonenumber: json['phonenumber'] as String?,
      address: json['address'] as String?,
      occupation: json['occupation'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      linkedln: json['linkedln'] as String?,
      following: following == 0,
    );
  }

  factory Userdata.fromMap(Map<String, dynamic> data) {
    return Userdata(
      firstname: data['firstname'],
      lastname: data['lastname'],
      name: (data['firstname']) + " " + (data['lastname']),
      email: data['email'],
      aboutme: data['aboutme'],
      coverphoto: data['coverphoto'],
      photo: data['photo'],
      gender: data['gender'],
      dob: data['dob'],
      phonenumber: data['phonenumber'],
      address: data['address'],
      occupation: data['occupation'],
      facebook: data['facebook'],
      twitter: data['twitter'],
      linkedln: data['linkedln'],
      apiToken: data['apiToken'],
    );
  }

  Map<String, dynamic> toMap() => {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "aboutme": aboutme,
        "coverphoto": coverphoto,
        "photo": photo,
        "gender": gender,
        "dob": dob,
        "phonenumber": phonenumber,
        "address": address,
        "occupation": occupation,
        "facebook": facebook,
        "twitter": twitter,
        "linkedln": linkedln,
        "apiToken": apiToken,
      };
}

