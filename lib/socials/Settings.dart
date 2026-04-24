import 'package:higherground/utils/Utility.dart';

import 'package:higherground/socials/PinnedPosts.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UserProfileScreen.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:higherground/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/TextStyles.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  @override
  SettingsRouteState createState() => new SettingsRouteState();
}

class SettingsRouteState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
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
        if (res == null || res['user'] == null) {
          print('[SettingsScreen] No user settings payload found: ${response.data}');
          return;
        }
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

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems(Provider.of<AppStateManager>(context, listen: false).userdata!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appManager = Provider.of<AppStateManager>(context);
    Userdata userdata = appManager.userdata!;
    final String youVersionLabel = t.youversionbible.trim().isEmpty
        ? 'Use Youversion Bible Reader'
        : t.youversionbible;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          PreferredSize(child: Container(), preferredSize: Size.fromHeight(0)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Card(
                  margin: EdgeInsets.all(0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: CachedNetworkImage(
                      imageUrl: userdata.photo!,
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
                        child: Icon(
                          Icons.error,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  userdata.name!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(t.viewprofile),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    UserProfileScreen.routeName,
                    arguments: ScreenArguements(items: userdata),
                  );
                },
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: Card(
                  margin: EdgeInsets.all(0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Icon(
                      LineAwesomeIcons.pinterest,
                      size: 50,
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  t.mypins,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(t.viewpinnedposts),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pushNamed(context, PinnedPosts.routeName);
                },
              ),
            ),
            Divider(height: 0),
            Container(
              height: 30,
              //color: Colors.grey[200],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text(t.personal,
                      style: TextStyles.subhead(context)
                          .copyWith(fontWeight: FontWeight.bold)),
                  Spacer(),
                  SizedBox(
                    width: 120,
                    height: 35,
                    child: ElevatedButton(
                      child: Text(
                        t.update,
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.mainC0lor,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        updateUserSettings(userdata);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.phonenumber,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(t.showmyphonenumber),
                trailing: Switch(
                  value: phoneSwitch,
                  onChanged: (value) {
                    setState(() {
                      phoneSwitch = value;
                    });
                  },
                    activeThumbColor: MyColors.mainC0lor,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(5),
                title: Text(
                  t.dateofbirth,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(t.showmyfulldateofbirth),
                trailing: Switch(
                  value: dobSwitch,
                  onChanged: (value) {
                    setState(() {
                      dobSwitch = value;
                    });
                  },
                    activeThumbColor: MyColors.mainC0lor,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Container(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text(t.notifications,
                      style: TextStyles.subhead(context)
                          .copyWith(fontWeight: FontWeight.bold)),
                  Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(4),
                title: Text(t.notifywhenuserfollowsme),
                trailing: Switch(
                  value: followSwitch,
                  onChanged: (value) {
                    setState(() {
                      followSwitch = value;
                    });
                  },
                    activeThumbColor: MyColors.mainC0lor,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(4),
                title: Text(t.notifymewhenusercommentsonmypost),
                trailing: Switch(
                  value: commentSwitch,
                  onChanged: (value) {
                    setState(() {
                      commentSwitch = value;
                    });
                  },
                    activeThumbColor: MyColors.mainC0lor,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Divider(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(4),
                title: Text(t.notifymewhenuserlikesmypost),
                trailing: Switch(
                  value: likeSwitch,
                  onChanged: (value) {
                    setState(() {
                      likeSwitch = value;
                    });
                  },
                    activeThumbColor: MyColors.mainC0lor,
                  inactiveThumbColor: Colors.grey,
                ),
                onTap: () {},
              ),
            ),
            Divider(height: 0),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                t.appsettings,
                style: TextStyles.subhead(context)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEADAE3)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A8F3E88),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFFF9EEF5), Color(0xFFFDF7FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEBD8E5)),
                          ),
                          child: Icon(
                            LineAwesomeIcons.cog,
                            size: 22,
                            color: MyColors.mainC0lor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App Experience',
                                style: TextStyle(
                                  color: Color(0xFF23141D),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Customize how scripture opens in the app.',
                                style: TextStyle(
                                  color: Color(0xFF7A6B75),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: appManager.youversionbible
                                ? const Color(0xFFE7F7EF)
                                : const Color(0xFFF3EAF0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            appManager.youversionbible ? 'Enabled' : 'Disabled',
                            style: TextStyle(
                              color: appManager.youversionbible
                                  ? const Color(0xFF167C4A)
                                  : const Color(0xFF7A6B75),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1E6EC)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      onTap: () {
                        appManager.setYouVersionBiblePreference(
                          !appManager.youversionbible,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1E7F7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                LineAwesomeIcons.bible,
                                color: Color(0xFF8F3E88),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    youVersionLabel,
                                    style: const TextStyle(
                                      color: Color(0xFF23141D),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Launch verses in YouVersion for a smoother reading flow.',
                                    style: TextStyle(
                                      color: Color(0xFF7A6B75),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Transform.scale(
                              scale: 0.95,
                              child: Switch.adaptive(
                                value: appManager.youversionbible,
                                activeTrackColor: MyColors.mainC0lor,
                                onChanged: (val) {
                                  appManager.setYouVersionBiblePreference(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}



