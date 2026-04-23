import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/screens/HomePage.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/models/Userdata.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/utils/img.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

class UpdateProfile extends StatefulWidget {
  static const routeName = "/UpdateProfile";
  UpdateProfile({this.userdata});
  final Userdata? userdata;

  @override
  UpdateUserProfileState createState() => new UpdateUserProfileState();
}

class UpdateUserProfileState extends State<UpdateProfile> {
  Userdata? userdata;
  String? gender = "Male";
  TextStyle textStyle = TextStyle(height: 1.4, fontSize: 16);
  TextStyle labelStyle = TextStyle();
  UnderlineInputBorder lineStyle1 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[800]!, width: 1));
  UnderlineInputBorder lineStyle2 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[800]!, width: 2));
  String? avatar = "";
  String? coverPhoto = "";
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController facebookController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController linkdlnController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2101),
        locale: const Locale('en', 'US'));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dobController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    } else {
      print("picked null" + picked.toString());
    }
  }

  pickImages(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowCompression: true,
      allowMultiple: false,
      withData: false,
      allowedExtensions: ['png', 'PNG', 'JPEG', 'JPG', 'jpg', 'jpeg'],
    );
    if (mounted) {
      if (result != null) {
        PlatformFile file = result.files.first;

        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);

        if (type == "avatar") {
          print("avatar changed");
          setState(() {
            avatar = file.path;
          });
        } else {
          print("coverphoto changed");
          setState(() {
            coverPhoto = file.path;
          });
        }
      }
      setState(() {});
    }
  }

  validateandsubmit() async {
    String _firstname = firstnameController.text;
    String _lastname = lastnameController.text;
    String _phone = phoneController.text;
    String _dob = dobController.text;
    String _address = addressController.text;
    String _occupation = occupationController.text;
    String _about = aboutController.text;
    String _facebook = facebookController.text;
    String _twitter = twitterController.text;
    String _lindln = linkdlnController.text;

    if (userdata!.photo == "" && avatar == "") {
      Alerts.show(context, t.error, t.pleaseselectprofilephoto);
    } else {
      // All profile fields are now optional - no validation required
      // Cover photo is now optional
      SharedPreferences prefs = await SharedPreferences.getInstance();

      uploadFileFromDio(
          _firstname,
          _lastname,
          _dob,
          _phone,
          _address,
          _occupation,
          _about,
          _facebook,
          _twitter,
          _lindln,
          prefs.getString("firebase_token"));
    }
  }

  uploadFileFromDio(
      String firstname,
      String lastname,
      String dob,
      String phone,
      String address,
      String occupation,
      String aboutme,
      String facebook,
      String twitter,
      String linkedln,
      String? token) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    FormData formData = FormData.fromMap({
      "email": userdata!.email,
      "firstname": firstname,
      "lastname": lastname,
      "dob": dob,
      "phone": phone,
      "gender": gender,
      "address": address,
      "occupation": occupation,
      "aboutme": Utility.getBase64EncodedString(aboutme),
      "facebook": facebook,
      "twitter": twitter,
      "linkedln": linkedln,
    });
    /*formData.files.addAll([
      MapEntry("avatar", MultipartFile.fromFileSync(avatar)),
      MapEntry("cover_photo", MultipartFile.fromFileSync(coverPhoto)),
    ]);*/
    if (avatar != "") {
      formData.files.add(
        MapEntry("avatar", MultipartFile.fromFileSync(avatar!)),
      );
    }
    if (coverPhoto != "") {
      formData.files.add(
        MapEntry("cover_photo", MultipartFile.fromFileSync(coverPhoto!)),
      );
    }
    print(formData.files);
    try {
      var response = await Utility.getDio().post(ApiUrl.updateUserProfile,
          data: formData, onSendProgress: (int send, int total) {
        print((send / total) * 100);
      });
      Navigator.of(context).pop();
      print(response.data);
      Map<String, dynamic> res = json.decode(response.data);
      if (res["status"] == "error") {
        Alerts.show(context, t.error, res["msg"]);
        return;
      }

      if (Provider.of<AppStateManager>(context, listen: false).userdata ==
          null) {
        Userdata userdata = Userdata.fromJson(res["user"]);
        Provider.of<AppStateManager>(context, listen: false)
            .setUserData(userdata);
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      } else {
        Userdata userdata = Userdata.fromJson(res["user"]);
        Provider.of<AppStateManager>(context, listen: false)
            .setUserData(userdata);
        Navigator.of(context).pop();
      }
    } on DioError catch (e) {
      Navigator.of(context).pop();
      Alerts.show(context, t.error, e.message);
      if (e.response != null) {
        print(e.response!.data);
        print(e.response!.headers);
        //print(e.response.request);
      } else {
        //print(e.request.headers);
        print(e.message);
      }
    }
  }

  @override
  void initState() {
    userdata = widget.userdata;
    if (userdata!.gender != "") {
      gender = userdata!.gender;
    }
    dobController.text = userdata!.dob!;
    firstnameController.text = userdata!.firstname!;
    lastnameController.text = userdata!.lastname!;
    phoneController.text = userdata!.phonenumber!;
    addressController.text = userdata!.address!;
    occupationController.text = userdata!.occupation!;
    aboutController.text = userdata!.aboutme == ""
        ? ""
        : Utility.getBase64DecodedString(userdata!.aboutme!);
    facebookController.text = userdata!.facebook!;
    twitterController.text = userdata!.twitter!;
    linkdlnController.text = userdata!.linkedln!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: MyColors.mainC0lor,
          title: Text(t.updateprofile),
          leading: IconButton(
            icon: Icon(Icons.close),
            tooltip: "Skip Profile Setup",
            onPressed: () {
              // Allow skipping profile update - navigate to home
              if ((Provider.of<DashboardModel>(context, listen: false)
                  .data['app_login'] as bool)) {
                Navigator.of(context)
                    .pushReplacementNamed(HomePage.routeName);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done_all,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                validateandsubmit();
              },
            ),
          ]),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    height: 280,
                  ),
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.blueGrey,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: coverPhoto != ""
                              ? Image.file(
                                  File.fromUri(Uri.parse(coverPhoto!)),
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : (userdata!.coverphoto != ""
                                  ? CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: userdata!.coverphoto!,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                  Colors.black12,
                                                  BlendMode.darken)),
                                        ),
                                      ),
                                      placeholder: (context, url) => Center(
                                          child: CupertinoActivityIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                        child: Image.asset(
                                          Img.get('cover_photos.jpg'),
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.photo,
                                      size: 200, color: Colors.white)),
                        ),
                        Container(
                          transform: Matrix4.translationValues(0.0, 40.0, 0.0),
                          margin: EdgeInsets.all(15),
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            heroTag: "fab4",
                            backgroundColor: Colors.blueGrey[800],
                            elevation: 3,
                            child: IconButton(
                                onPressed: () {
                                  print("hello 1");
                                  pickImages("coverphoto");
                                  print("hello 4");
                                },
                                icon: Icon(Icons.photo_camera,
                                    color: Colors.white)),
                            onPressed: () {
                              print("hello 2");
                              pickImages("coverphoto");
                              print("hello 3");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80.0),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.blueGrey[300],
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: avatar != ""
                                  ? Image.file(
                                      File.fromUri(Uri.parse(avatar!)),
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : (userdata!.photo != ""
                                      ? CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: userdata!.photo!,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.black12,
                                                      BlendMode.darken)),
                                            ),
                                          ),
                                          placeholder: (context, url) => Center(
                                              child:
                                                  CupertinoActivityIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                            child: Image.asset(
                                              Img.get('cover_photos.jpg'),
                                            ),
                                          ),
                                        )
                                      : Icon(Icons.person,
                                          size: 80, color: Colors.white)),
                            ),
                            Positioned(
                              child: Container(
                                transform:
                                    Matrix4.translationValues(0.0, 0.0, 0.0),
                                margin: EdgeInsets.all(10),
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  heroTag: "fab3",
                                  mini: true,
                                  backgroundColor: Colors.blueGrey[800],
                                  elevation: 3,
                                  child: Icon(Icons.photo_camera,
                                      size: 18, color: Colors.white),
                                  onPressed: () {
                                    pickImages("avatar");
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      style: textStyle,
                      controller: firstnameController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.person),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.firstname,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 15),
                    TextField(
                      style: textStyle,
                      controller: lastnameController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.person),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.lastname,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        t.gender,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(height: 4),
                    Container(
                      height: 50,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(width: 0),
                          Container(
                            width: 150,
                            height: 50,
                            child: RadioListTile<String>(
                              title: Text(t.male),
                              value: "Male",
                              groupValue: gender,
                              onChanged: (String? value) {
                                setState(() {
                                  gender = value;
                                });
                              },
                            ),
                          ),
                          Container(width: 0),
                          Container(
                            width: 150,
                            height: 50,
                            child: RadioListTile<String>(
                              title: Text(t.female),
                              value: "Female",
                              groupValue: gender,
                              onChanged: (String? value) {
                                setState(() {
                                  gender = value;
                                });
                              },
                            ),
                          ),
                          Spacer()
                        ],
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: dobController,
                      enableInteractiveSelection: true,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectDate(context);
                      },
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.date_range),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.dob,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.phone),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.phonenumber,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: addressController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.location_city),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.address,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: occupationController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.work),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.occupation,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: aboutController,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.child_care),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.aboutme,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: facebookController,
                      keyboardType: TextInputType.url,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.facebook),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.facebookprofilelink,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: twitterController,
                      keyboardType: TextInputType.url,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(FontAwesomeIcons.twitter),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.twitterprofilelink,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: linkdlnController,
                      keyboardType: TextInputType.url,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(FontAwesomeIcons.linkedin),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.linkdln,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}



