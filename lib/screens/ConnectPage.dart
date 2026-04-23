import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Items.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/BranchesScreen.dart';
import 'package:higherground/screens/GroupsScreen.dart';
import 'package:higherground/screens/PrayersScreen.dart';
import 'package:higherground/screens/TestimoniessScreen.dart';
import 'package:higherground/socials/FollowPeopleSection.dart';
import 'package:higherground/socials/SocialActivity.dart';
import 'package:higherground/socials/UserProfileScreen.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/img.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/widgets/CircleWidget.dart';
import 'package:higherground/widgets/HomeTiles.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/DashboardModel.dart';

class ConnectPage extends StatefulWidget {
  ConnectPage();

  @override
  ConnectPageRouteState createState() => new ConnectPageRouteState();
}

class ConnectPageRouteState extends State<ConnectPage> {
  late DashboardModel dashboardModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              height: 25,
              margin: const EdgeInsets.only(left: 20, right: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      t.members,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  MaterialButton(
                    elevation: 0,
                    textColor: Colors.white,
                    color: MyColors.mainC0lor,
                    height: 0,
                    child: Icon(Icons.keyboard_arrow_right),
                    minWidth: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(FollowPeopleSection.routeName);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 0, left: 12),
              child: Card(
                elevation: 0,
                child: Container(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:
                              dashboardModel.recentmembers.map((userdata) {
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  UserProfileScreen.routeName,
                                  arguments: ScreenArguements(items: userdata),
                                );
                              },
                              child: CircleWidget(
                                height: 70,
                                width: 70,
                                borderRadius: BorderRadius.circular(50),
                                name: userdata.firstname! +
                                    " " +
                                    userdata.lastname!,
                                personImagePath: userdata.photo,
                              ),
                            );
                          }).toList()),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 3,
                right: 3,
                bottom: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    child: HomeTiles(
                      index: 0,
                      height: width > 600 ? 300 : 200,
                      width: (width / 2) - 3,
                      title: t.churchlocation,
                      thumbnail: "assets/images/locations.jpg",
                      color: Colors.red[100]!,
                      onclick: () {
                        Navigator.of(context)
                            .pushNamed(BranchesScreen.routeName);
                      },
                    ),
                  ),
                  Container(
                    width: 0,
                  ),
                  Visibility(
                    visible: dashboardModel.isFeatureAvailable("groups"),
                    child: HomeTiles(
                      index: 1,
                      height: width > 600 ? 300 : 200,
                      width: (width / 2) - 3,
                      title: t.groups,
                      thumbnail: "assets/images/groups.jpg",
                      color: Colors.purple[100]!,
                      onclick: () {
                        Navigator.of(context).pushNamed(GroupsScreen.routeName);
                      },
                    ),
                  ),
                  Container(
                    width: 0,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: false,
              child: InkWell(
                onTap: () async {
                  Userdata? userdata = await SQLiteDbProvider.db.getUserData();
                  if (userdata == null) {
                    Navigator.of(context)
                        .pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context).pushNamed(SocialActivity.routeName);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: AssetImage(Img.get("socials.jpg")),
                          fit: BoxFit.cover)),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(.4),
                              Colors.black.withOpacity(.2),
                            ])),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          t.gosocialehint,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          height: 30,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: Center(
                              child: Text(
                            t.gosocial,
                            style: TextStyle(
                                color: Colors.grey[900],
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            _buildFourthList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFourthList() {
    return Container(
      //color: Colors.black,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dashboardModel.listfour.length,
        padding: EdgeInsets.all(0),
        itemBuilder: (context, index) {
          Items itms = dashboardModel.listfour[index];
          return Card(
            elevation: 0.5,
            margin: EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 4,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(itms.icon!),
              ),
              title: Text(itms.title!),
              subtitle: Text(itms.description!),
              trailing: Icon(Icons.navigate_next),
              onTap: () {
                onItemClick(itms.position!);
              },
            ),
          );
          /* return InkWell(
            onTap: () {
              onItemClick(itms.position!);
            },
            child: Card(
              elevation: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //color: Colors.white,
                ),
                width: double.infinity,
                height: 90,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(right: 6),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(50),
                      //   border: Border.all(width: 1, color: MyColors.mainC0lor),
                      // ),
                      child: Icon(itms.icon),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            itms.title!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(itms.description!,
                              style:
                                  TextStyle(fontSize: 13, letterSpacing: .3)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );*/
        },
      ),
    );
  }

  onItemClick(int pos) {
    switch (pos) {
      case 1:
        Navigator.of(context).pushNamed(GroupsScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(PrayersScreen.routeName);
        break;
      case 3:
        Navigator.of(context).pushNamed(TestimoniessScreen.routeName);
        break;
      case 4:
        Navigator.of(context).pushNamed(BranchesScreen.routeName);
        break;
      case 5:
        final facebook = dashboardModel.data["facebook"];
        if (facebook != null && facebook.toString().isNotEmpty) {
          Utility.openBrowserTab(facebook.toString());
        }
        break;
      case 6:
        final twitter = dashboardModel.data["twitter"];
        if (twitter != null && twitter.toString().isNotEmpty) {
          Utility.openBrowserTab(twitter.toString());
        }
        break;
      case 7:
        final instagram = dashboardModel.data["instagram"];
        if (instagram != null && instagram.toString().isNotEmpty) {
          Utility.openBrowserTab(instagram.toString());
        }
        break;
      case 8:
        final youtube = dashboardModel.data["youtube"];
        if (youtube != null && youtube.toString().isNotEmpty) {
          Utility.openBrowserTab(youtube.toString());
        }
        break;
    }
  }
}



