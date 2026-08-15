import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:higherground/utils/img.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/socials/chat/ChatConversations.dart';

class UserProfileScreen extends StatefulWidget {
  static String routeName = "/userprofile";
  UserProfileScreen({this.user});
  final Userdata? user;

  @override
  UserProfileScreenRouteState createState() =>
      new UserProfileScreenRouteState();
}

class UserProfileScreenRouteState extends State<UserProfileScreen> {
  bool isError = false;
  bool isLoading = true;
  Userdata? userdata;
  Userdata? _user;
  int postscount = 0;
  int followerscount = 0;
  int followingscount = 0;
  bool isFollowing = false;

  Future<void> fetchItems() async {
    Userdata? userdata = await SQLiteDbProvider.db.getUserData();
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await Utility.getDio().post(
        ApiUrl.userBioInfo,
        data: jsonEncode({
          "data": {
            "email": widget.user!.email,
            "viewer": userdata == null ? "" : userdata.email
          }
        }),
      );
      print(response.data);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        dynamic res = Utility.decodeResponse(response.data);
        _user = Userdata.fromJson2(res['user']);
        postscount = int.parse(res['post_count'].toString());
        followerscount = int.parse(res['followers_count'].toString());
        followingscount = int.parse(res['following_count'].toString());
        isFollowing = int.parse(res['isFollowing'].toString()) == 0;
        isLoading = false;
        isError = false;
        setState(() {});
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        isLoading = false;
        isError = true;
        setState(() {});
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      isLoading = false;
      isError = true;
      setState(() {});
    }
  }

  Future<void> followUnfollowUser() async {
    try {
      var data = {
        "data": {
          "user": _user!.email,
          "follower": userdata == null ? "" : userdata!.email,
          "action": isFollowing ? "unfollow" : "follow"
        }
      };
      setState(() {
        isFollowing = isFollowing ? false : true;
        if (isFollowing)
          followerscount++;
        else
          followerscount--;
      });

      final response = await Utility.getDio().post(
        ApiUrl.followUnfollowUser,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  @override
  void initState() {
    _user = widget.user;
    Future.delayed(const Duration(milliseconds: 0), () {
      fetchItems();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.keyboard_backspace_rounded,
                    color: Colors.white,
                  )),
              expandedHeight: 220.0,
              flexibleSpace: FlexibleSpaceBar(
                background: _user!.coverphoto == ""
                    ? Image.asset(Img.get('cover_photos.jpg'),
                        fit: BoxFit.cover)
                    : InkWell(
                        onTap: () {
                          showImageViewer(
                            context,
                            Image.network(_user!.coverphoto!).image,
                            useSafeArea: true,
                            swipeDismissible: true,
                          );
                        },
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: _user!.coverphoto!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black12, BlendMode.darken)),
                            ),
                          ),
                          placeholder: (context, url) =>
                              Center(child: CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) => Center(
                            child: Image.asset(
                              Img.get('cover_photos.jpg'),
                            ),
                          ),
                        ),
                      ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: Container(
                  //color: Colors.yellow,
                  //width: double.infinity,
                  transform: Matrix4.translationValues(0, 50, 0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: _user!.photo == ""
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage(Img.get("avatar.png")),
                          )
                        : Card(
                            margin: EdgeInsets.all(0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: InkWell(
                              onTap: () {
                                showImageViewer(
                                  context,
                                  Image.network(_user!.photo!).image,
                                  swipeDismissible: true,
                                  useSafeArea: true,
                                );
                              },
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: _user!.photo!,
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
                                      Image.asset(
                                    Img.get('avatar.png'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: getProfileBody(),
      ),
      floatingActionButton: AnimatedOpacity(
        child: FloatingActionButton.small(
          backgroundColor: MyColors.mainC0lor,
          onPressed: () {
            if (userdata == null) {
              Navigator.pushNamed(
                context,
                AuthPage.routeName,
                arguments: true,
              );
            } else {
              eventBus.fire(StartPartnerChatEvent(_user));
              Navigator.pushReplacementNamed(
                context,
                ChatConversations.routeName,
              );
            }
          },
          child: Icon(
            FontAwesomeIcons.comment.data,
            color: Colors.white,
          ),
          //icon: Icon(Icons.add_circle),
          // label: Text(t.newnote),
        ),
        duration: Duration(milliseconds: 100),
        opacity:
            (userdata != null && (_user!.email == userdata!.email)) ? 0 : 1,
      ),
    );
  }

  Widget getProfileBody() {
    if (isLoading) {
      return Container(
        height: 400,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    if (isError) {
      return NoitemScreen(
          title: t.error,
          message: t.pleaseclicktoretry,
          onClick: () {
            fetchItems();
          });
    }
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.person),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.fullname,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.firstname! + " " + _user!.lastname!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(FontAwesomeIcons.info.data),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.aboutme,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.aboutme! == ""
                    ? "----"
                    : Utility.getBase64DecodedString(_user!.aboutme!)),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(FontAwesomeIcons.genderless.data),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.gender,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.gender!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.date_range),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.dateofbirth,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.dob!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.email),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.emailaddress,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.email!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.phone),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.phonenumber,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    _user!.phonenumber == "" ? "-------" : _user!.phonenumber!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Icon(Icons.location_city),
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.address,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_user!.address!),
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                leading: Icon(Icons.work),
                title: Text(
                  t.occupation,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    _user!.occupation == "" ? "-----" : _user!.occupation!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                leading: Icon(LineAwesomeIcons.facebook),
                title: Text(
                  t.facebookprofilelink,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text(_user!.facebook == "" ? "-----" : _user!.facebook!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                leading: Icon(LineAwesomeIcons.twitter),
                title: Text(
                  t.twitterprofilelink,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text(_user!.twitter == "" ? "-----" : _user!.twitter!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                leading: Icon(LineAwesomeIcons.linkedin),
                title: Text(
                  t.linkdln,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    Text(_user!.linkedln == "" ? "-----" : _user!.linkedln!),
              ),
            ),
            Container(height: 35),
          ],
        ),
      ),
    );
  }
}



