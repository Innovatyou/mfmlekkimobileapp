import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/Groups.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/providers/GroupsScreensModel.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/screens/MyGroupsScreen.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';

class GroupsScreen extends StatefulWidget {
  static const routeName = "/GroupsScreen";
  GroupsScreen();

  @override
  PrayersScreenRouteState createState() => new PrayersScreenRouteState();
}

class PrayersScreenRouteState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupsScreensModel(ApiUrl.FETCH_GROUPS),
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.groups),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 12),
          child: AudioScreenBody(),
        ),
      ),
    );
  }
}

class AudioScreenBody extends StatefulWidget {
  @override
  MediaScreenRouteState createState() => new MediaScreenRouteState();
}

class MediaScreenRouteState extends State<AudioScreenBody> {
  late GroupsScreensModel mediaScreensModel;
  List<Groups>? items;

  void _onRefresh() async {
    mediaScreensModel.loadItems();
  }

  void _onLoading() async {
    mediaScreensModel.loadMoreItems();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () {
      Provider.of<GroupsScreensModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaScreensModel = Provider.of<GroupsScreensModel>(context);
    items = mediaScreensModel.itemList;

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text(t.pulluploadmore);
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text(t.loadfailedretry);
          } else if (mode == LoadStatus.canLoading) {
            body = Text(t.releaseloadmore);
          } else {
            body = Text(t.nomoredata);
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: mediaScreensModel.refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: (mediaScreensModel.isError == true && items!.length == 0)
          ? NoitemScreen(
              title: t.oops, message: t.dataloaderror, onClick: _onRefresh)
          : ListView.builder(
              itemCount: (items!.length + 1),
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(3),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return InkWell(
                    child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      child: ListTile(
                        contentPadding: EdgeInsets.fromLTRB(20, 5, 10, 5),
                        leading: Container(
                          width: 40,
                          height: 40,
                          color: MyColors.white,
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.peopleGroup,
                              color: MyColors.mainC0lor,
                            ),
                          ),
                        ),
                        title: Text(
                          t.groupsibelongto,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.navigate_next_outlined),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(MyGroupsScreen.routeName);
                    },
                  );
                } else {
                  Groups groups = items![index - 1];
                  return ItemTile(index: index, groups: groups);
                }
              },
            ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Groups groups;
  final int index;

  const ItemTile({
    Key? key,
    required this.index,
    required this.groups,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashboardModel dashboardModel = Provider.of<DashboardModel>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        elevation: 0.9,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: <Widget>[
              Container(width: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(groups.title!,
                    maxLines: 2,
                    style: TextStyles.subhead(context)
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
              Container(height: 5),
              Row(
                children: <Widget>[
                  Container(width: 6),
                  Text(groups.leader!,
                      style: TextStyles.subhead(context).copyWith())
                ],
              ),
              Container(height: 20),
              Row(
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(30),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(
                        Icons.info_outline,
                      ),
                    ),
                  )),
                  Container(width: 15),
                  Expanded(
                    child: Text(
                      groups.description!,
                      maxLines: 3,
                      style: TextStyles.subhead(context)
                          .copyWith(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              Container(height: 10),
              Row(
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(30),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(
                        Icons.location_city,
                      ),
                    ),
                  )),
                  Container(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(groups.location!,
                          maxLines: 2,
                          style: TextStyles.subhead(context)
                              .copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Spacer(),
                ],
              ),
              Container(height: 10),
              Row(
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(30),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(
                        Icons.calendar_month,
                      ),
                    ),
                  )),
                  Container(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 200,
                        padding: EdgeInsets.only(right: 30),
                        child: Text(groups.time!,
                            maxLines: 2,
                            style: TextStyles.subhead(context)
                                .copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
              Container(height: 10),
              Row(
                children: <Widget>[
                  ClipOval(
                      child: Container(
                    color:
                        Theme.of(context).colorScheme.secondary.withAlpha(30),
                    width: 50.0,
                    height: 50.0,
                    child: IconButton(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () {},
                      icon: Icon(
                        Icons.people,
                      ),
                    ),
                  )),
                  Container(width: 15),
                  Expanded(
                    child: Text(
                      groups.members!.toString() + " " + t.member,
                      style: TextStyles.subhead(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              Container(height: 10),
              Visibility(
                visible: !groups.ismember &&
                    (dashboardModel.data['join_groups'] as bool),
                child: InkWell(
                  onTap: () async {
                    Userdata? userdata =
                        await SQLiteDbProvider.db.getUserData();
                    if (userdata == null) {
                      Navigator.of(context)
                          .pushNamed(AuthPage.routeName, arguments: true);
                    } else {
                      Provider.of<GroupsScreensModel>(context, listen: false)
                          .joingroup(context, groups.id!);
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      ClipOval(
                          child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(30),
                        width: 50.0,
                        height: 50.0,
                        child: IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          onPressed: () {},
                          icon: Icon(
                            Icons.add_home_work,
                          ),
                        ),
                      )),
                      Container(width: 15),
                      Expanded(
                        child: Text(
                          t.join,
                          style: TextStyles.subhead(context).copyWith(
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              color: Colors.blue[700]),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              /*Container(height: 10),
              Visibility(
                visible: groups.ismember,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        GroupEventsListScreen.routeName,
                        arguments: groups);
                  },
                  child: Row(
                    children: <Widget>[
                      ClipOval(
                          child: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(30),
                        width: 50.0,
                        height: 50.0,
                        child: IconButton(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          onPressed: () {},
                          icon: Icon(
                            Icons.group_work,
                          ),
                        ),
                      )),
                      Container(width: 15),
                      Expanded(
                        child: Text(
                          t.groupevents,
                          style: TextStyles.subhead(context).copyWith(
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              color: Colors.blue[700]),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}



