import 'dart:convert';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/providers/events.dart';

import 'package:higherground/utils/my_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/UserProfile.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/TextStyles.dart';
// replaced launch_review plugin usage with direct Play Store URL opener

class SettingsPage extends StatefulWidget {
  static const routeName = "/SettingsPage";
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppStateManager appManager;
  Userdata? userdata;
  bool phoneSwitch = false;
  bool dobSwitch = false, followSwitch = false;
  bool commentSwitch = false, likeSwitch = false;

  Future<void> loadItems(Userdata userdata) async {
    try {
      final response = await Utility.getDio().post(ApiUrl.fetchUserSettings,
          data: jsonEncode({
            "data": {
              "email": userdata.email,
            }
          }));

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        dynamic res = jsonDecode(response.data);
        setState(() {
          phoneSwitch = int.parse(res['user']['show_phone'].toString()) == 0;
          dobSwitch =
              int.parse(res['user']['show_dateofbirth'].toString()) == 0;
          followSwitch =
              int.parse(res['user']['notify_follows'].toString()) == 0;
          commentSwitch =
              int.parse(res['user']['notify_comments'].toString()) == 0;
          likeSwitch = int.parse(res['user']['notify_likes'].toString()) == 0;
        });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
    }
  }

  Future<void> updateUserSettings(Userdata userdata) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      final response = await Utility.getDio().post(
        ApiUrl.updateUserSettings,
        data: jsonEncode({
          "data": {
            "email": userdata.email,
            "show_dateofbirth": dobSwitch ? 0 : 1,
            "show_phone": phoneSwitch ? 0 : 1,
            "notify_follows": followSwitch ? 0 : 1,
            "notify_comments": commentSwitch ? 0 : 1,
            "notify_likes": likeSwitch ? 0 : 1
          }
        }),
      );
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        Map<String, dynamic> res = json.decode(response.data);
        if (res["status"] == "error") {
          Alerts.show(context, t.error, res["msg"]);
        } else {
          print(res["user"]);
          Alerts.show(context, t.success, res["msg"]);
        }
      }
    } catch (exception) {
      // I get no exception here
      Navigator.of(context).pop();
      Alerts.show(context, t.error, exception.toString());
      print(exception);
    }
  }

  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  Future<void> showLogoutAlert() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(t.logoutfromapp),
              content: new Text(t.logoutfromapphint),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                    appManager.unsetUserData();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> showDeleteAccountAlert() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(t.deleteaccount),
              content: new Text(t.deleteaccounthint),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deleteAccountServer(userdata!.email!);
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> deleteAccountServer(String email) async {
    Alerts.showProgressDialog(context, t.processingpleasewait);
    try {
      var data = {
        "email": email,
      };
      final response = await Utility.getDio()
          .post(ApiUrl.DELETE_ACCOUNT, data: jsonEncode({"data": data}));
      Navigator.of(context).pop();
      if (response.statusCode == 200) {
        print(response.data);
        Alerts.show(context, "", t.deleteaccountsuccess);
        appManager.unsetUserData();
      } else {
        Alerts.show(context, "", t.cannotprocess);
      }
    } catch (exception) {
      Navigator.of(context).pop();
      Alerts.show(context, "", exception.toString());
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 0), () {
      Userdata? user =
          Provider.of<AppStateManager>(context, listen: false).userdata;
      if (user != null) {
        loadItems(user);
      }
    });
    eventBus.on<UserLoggedInEvent>().listen((event) {
      print(event);
      loadItems(event.user!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appManager = Provider.of<AppStateManager>(context);
    userdata = appManager.userdata;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appsettings),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              t.account,
              style: headerStyle,
            ),
            const SizedBox(height: 10.0),
            userdata == null
                ? Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 0,
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            child: Icon(LineAwesomeIcons.user),
                          ),
                          title: Text(t.guestuser),
                          subtitle: Text(t.createanaccounthint),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AuthPage.routeName, arguments: true);
                          },
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 0,
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: userdata!.photo! == ""
                              ? CircleAvatar(
                                  radius: 0, child: Icon(LineAwesomeIcons.user))
                              : Card(
                                  margin: EdgeInsets.all(0),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: CachedNetworkImage(
                                      imageUrl: userdata!.photo!,
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
                                              child: Icon(
                                        Icons.error,
                                        color: Colors.grey,
                                      )),
                                    ),
                                  )),
                          title: Text(userdata!.firstname!.toTitleCase() +
                              " " +
                              userdata!.lastname!.toTitleCase()),
                          subtitle: Text(t.viewmyprofile),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                UserProfile.routeName,
                                arguments: userdata);
                          },
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(LineAwesomeIcons.alternate_sign_out),
                          title: Text(t.logoutfromapp),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            showLogoutAlert();
                          },
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: Icon(
                            LineAwesomeIcons.remove_user,
                            color: Colors.red,
                          ),
                          title: Text(t.deletemyaccount),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            showDeleteAccountAlert();
                          },
                        ),
                      ],
                    ),
                  ),
            Visibility(
              visible: userdata != null,
              child: Container(
                height: 30,
                //color: Colors.grey[200],
              ),
            ),
            Visibility(
              visible: userdata != null,
              child: Padding(
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Text(t.personal,
                        style: TextStyles.subhead(context)
                            .copyWith(fontWeight: FontWeight.bold)),
                    Spacer(),
                    Container(
                      height: 35,
                      child: ElevatedButton(
                        child: Text(
                          t.update,
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: MyColors.mainC0lor,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          updateUserSettings(userdata!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: userdata != null,
              child: Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0,
                ),
                child: Column(children: [
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: phoneSwitch,
                    title: Text(
                      t.phonenumber,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(t.showmyphonenumber),
                    onChanged: (value) {
                      setState(() {
                        phoneSwitch = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: dobSwitch,
                    title: Text(
                      t.dateofbirth,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(t.showmyfulldateofbirth),
                    onChanged: (value) {
                      setState(() {
                        dobSwitch = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  /*SwitchListTile(
                    activeColor: Colors.purple,
                    value: followSwitch,
                    title: Text(t.notifywhenuserfollowsme),
                    onChanged: (value) {
                      setState(() {
                        followSwitch = value;
                      });
                    },
                  ),
                  _buildDivider(),*/
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: commentSwitch,
                    title: Text(
                      t.notifymewhenusercommentsonmypost,
                    ),
                    onChanged: (value) {
                      setState(() {
                        commentSwitch = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: likeSwitch,
                    title: Text(
                      t.notifymewhenuserlikesmypost,
                    ),
                    onChanged: (value) {
                      setState(() {
                        likeSwitch = value;
                      });
                    },
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              t.appsettings,
              style: headerStyle,
            ),
            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.youversionbible,
                    title: Text(t.youversionbible),
                    onChanged: (val) {
                      appManager.setYouVersionBiblePreference(val);
                    },
                  ),
                  _buildDivider(),
                ],
              ),
            ),
            /* const SizedBox(height: 10.0),
            Text(
              "App Notifications",
              style: headerStyle,
            ),
            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.inboxnotifications,
                    title: Text(t.recieveinbox),
                    onChanged: (val) {
                      appManager.setInboxNotifications(val);
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.sermonnotifications,
                    title: Text(
                      t.sermonnotification,
                      // style: TextStyle(
                      //     fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (val) {
                      appManager.setSermonNotifications(val);
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.eventnotifications,
                    title: Text(
                      t.recieveevents,
                      // style: TextStyle(
                      //     fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (val) {
                      appManager.setEventNotifications(val);
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.articlesnotifications,
                    title: Text(
                      t.articlenotification,
                      //style:
                      //    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (val) {
                      appManager.setArticleNotifications(val);
                    },
                  ),
                  _buildDivider(),
                  SwitchListTile(
                    activeColor: Colors.purple,
                    value: appManager.devotionalsnotifications,
                    title: Text(
                      t.devotionalnotification,
                      //style:
                      //    TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onChanged: (val) {
                      appManager.setDevotionalNotifications(val);
                    },
                  ),
                  _buildDivider(),
                ],
              ),
            ),*/
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 0,
              ),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      t.appname,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text("V" + appManager.version),
                  ),
                  Visibility(
                    visible: (Provider.of<DashboardModel>(context)
                            .data['website']?.toString() ?? 
                        "") !=
                        "",
                    child: _buildDivider(),
                  ),
                  Visibility(
                    visible: (Provider.of<DashboardModel>(context)
                            .data['website']?.toString() ?? 
                        "") !=
                        "",
                    child: ListTile(
                      leading: Icon(LineAwesomeIcons.chrome),
                      title: Text(t.website),
                      trailing: Icon(Icons.navigate_next),
                      onTap: () {
                        final website = Provider.of<DashboardModel>(context).data['website'];
                        if (website != null) {
                          Utility.openBrowserTab(website.toString());
                        }
                      },
                    ),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.tags),
                    title: Text(t.terms),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      Utility.openBrowserTab(ApiUrl.TERMS);
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.th_list,
                    ),
                    title: Text(t.privacy),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      Utility.openBrowserTab(ApiUrl.PRIVACY);
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.info,
                    ),
                    title: Text(t.about),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      Utility.openBrowserTab(ApiUrl.ABOUT);
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.app_store,
                    ),
                    title: Text(t.rateapp),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () async {
                      Utility.openBrowserTab("https://play.google.com/store/apps/details?id=org.mfmlekki.app");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}



