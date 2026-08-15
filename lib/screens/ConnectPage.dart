import 'package:flutter/material.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/DashboardModel.dart';
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
import 'package:higherground/widgets/CircleWidget.dart';
import 'package:higherground/widgets/HomeTiles.dart';
import 'package:provider/provider.dart';

class ConnectPage extends StatefulWidget {
  @override
  ConnectPageRouteState createState() => ConnectPageRouteState();
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
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFFF7F2F5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFECE1E8)),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E6EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_alt_outlined,
                      color: Color(0xFF563349),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.members,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0f172a),
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF2E6EC),
                      foregroundColor: const Color(0xFF563349),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: const Size(0, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_right),
                    label: const Text('View'),
                    onPressed: () {
                      Navigator.of(context).pushNamed(FollowPeopleSection.routeName);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6, left: 12, right: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFECE1E8)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: dashboardModel.recentmembers.map((userdata) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
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
                              name: '${userdata.firstname!} ${userdata.lastname!}',
                              personImagePath: userdata.photo,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HomeTiles(
                    index: 0,
                    height: width > 600 ? 300 : 210,
                    width: (width - 32) / 2,
                    title: t.churchlocation,
                    thumbnail: 'assets/images/locations.jpg',
                    color: Colors.red[100]!,
                    onclick: () {
                      Navigator.of(context).pushNamed(BranchesScreen.routeName);
                    },
                  ),
                  const SizedBox(width: 8),
                  if (dashboardModel.isFeatureAvailable('groups'))
                    HomeTiles(
                      index: 1,
                      height: width > 600 ? 300 : 210,
                      width: (width - 32) / 2,
                      title: t.groups,
                      thumbnail: 'assets/images/groups.jpg',
                      color: Colors.purple[100]!,
                      onclick: () {
                        Navigator.of(context).pushNamed(GroupsScreen.routeName);
                      },
                    )
                  else
                    SizedBox(width: (width - 32) / 2),
                ],
              ),
            ),
            Visibility(
              visible: false,
              child: InkWell(
                onTap: () async {
                  Userdata? userdata = await SQLiteDbProvider.db.getUserData();
                  if (userdata == null) {
                    Navigator.of(context).pushNamed(AuthPage.routeName, arguments: true);
                  } else {
                    Navigator.of(context).pushNamed(SocialActivity.routeName);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(Img.get('socials.jpg')),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          t.gosocialehint,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              t.gosocial,
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildFourthList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFourthList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dashboardModel.listfour.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final itms = dashboardModel.listfour[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECE1E8)),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFF2E6EC),
                child: Icon(itms.icon!, color: const Color(0xFF563349)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(itms.title!),
              subtitle: Text(
                itms.description!,
                style: const TextStyle(color: Color(0xFF7A6C75)),
              ),
              trailing: const Icon(Icons.navigate_next),
              onTap: () {
                onItemClick(itms.position!);
              },
            ),
          );
        },
      ),
    );
  }

  void onItemClick(int pos) {
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
        final facebook = dashboardModel.data['facebook'];
        if (facebook != null && facebook.toString().isNotEmpty) {
          Utility.openBrowserTab(
            facebook.toString(),
            context: context,
            title: 'Facebook',
          );
        }
        break;
      case 6:
        final twitter = dashboardModel.data['twitter'];
        if (twitter != null && twitter.toString().isNotEmpty) {
          Utility.openBrowserTab(
            twitter.toString(),
            context: context,
            title: 'Twitter',
          );
        }
        break;
      case 7:
        final instagram = dashboardModel.data['instagram'];
        if (instagram != null && instagram.toString().isNotEmpty) {
          Utility.openBrowserTab(
            instagram.toString(),
            context: context,
            title: 'Instagram',
          );
        }
        break;
      case 8:
        final youtube = dashboardModel.data['youtube'];
        if (youtube != null && youtube.toString().isNotEmpty) {
          Utility.openBrowserTab(
            youtube.toString(),
            context: context,
            title: 'YouTube',
          );
        }
        break;
    }
  }
}
