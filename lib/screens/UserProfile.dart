import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/screens/UpdateProfile.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/network_image.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserProfile extends StatefulWidget {
  static const routeName = "/UserProfile";
  UserProfile({this.userdata});
  final Userdata? userdata;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 350,
              width: double.infinity,
              child: PNetworkImage(
                widget.userdata!.coverphoto,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(16.0, 190.0, 16.0, 16.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: NetworkImage(widget.userdata!.photo!),
                              fit: BoxFit.cover)),
                      margin: EdgeInsets.only(left: 0.0),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        Divider(),
                        ListTile(
                          title: Text(t.fullname),
                          subtitle: Text(
                              widget.userdata!.firstname!.toTitleCase() +
                                  " " +
                                  widget.userdata!.lastname!.toTitleCase()),
                          leading: Icon(Icons.account_box_outlined),
                        ),
                        ListTile(
                          title: Text(t.gender),
                          subtitle: Text(widget.userdata!.gender!),
                          leading: Icon(FontAwesomeIcons.genderless),
                        ),
                        ListTile(
                          title: Text(t.dateofbirth),
                          subtitle: Text(widget.userdata!.dob!),
                          leading: Icon(FontAwesomeIcons.calendar),
                        ),
                        ListTile(
                          title: Text(t.emailaddress),
                          subtitle: Text(widget.userdata!.email!),
                          leading: Icon(Icons.email),
                        ),
                        ListTile(
                          title: Text(t.phonenumber),
                          subtitle: Text(widget.userdata!.phonenumber!),
                          leading: Icon(Icons.phone),
                        ),
                        ListTile(
                          title: Text(t.address),
                          subtitle: Text(widget.userdata!.address! == ""
                              ? "---"
                              : widget.userdata!.address!),
                          leading: Icon(Icons.web),
                        ),
                        ListTile(
                          title: Text(t.occupation),
                          subtitle: Text(widget.userdata!.occupation! == ""
                              ? "---"
                              : widget.userdata!.occupation!),
                          leading: Icon(Icons.web),
                        ),
                        ListTile(
                          title: Text(t.aboutme),
                          subtitle: Text(widget.userdata!.aboutme! == ""
                              ? "---"
                              : Utility.getBase64DecodedString(
                                  widget.userdata!.aboutme!)),
                          leading: Icon(Icons.person),
                        ),
                        ListTile(
                          title: Text(t.facebookpage),
                          subtitle: Text(widget.userdata!.facebook! == ""
                              ? "---"
                              : widget.userdata!.facebook!),
                          leading: Icon(FontAwesomeIcons.facebook),
                        ),
                        ListTile(
                          title: Text(t.twitterpage),
                          subtitle: Text(widget.userdata!.twitter! == ""
                              ? "---"
                              : widget.userdata!.twitter!),
                          leading: Icon(FontAwesomeIcons.twitter),
                        ),
                        ListTile(
                          title: Text(t.linkdln),
                          subtitle: Text(widget.userdata!.linkedln! == ""
                              ? "---"
                              : widget.userdata!.linkedln!),
                          leading: Icon(FontAwesomeIcons.linkedin),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            AppBar(
              //backgroundColor: Colors.transparent,
              title: Text(
                t.myprofile,
                style: TextStyle(fontSize: 17),
              ),
              elevation: 0,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                          UpdateProfile.routeName,
                          arguments: widget.userdata);
                    },
                    icon: Icon(LineAwesomeIcons.edit_1))
              ],
            )
          ],
        ),
      ),
    );
  }
}



