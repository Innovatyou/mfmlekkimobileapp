import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';
import 'package:higherground/models/UserEvents.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:higherground/socials/chat/ChatConversations.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'utils.dart';

class FollowPeopleSection extends StatefulWidget {
  static const routeName = "/FollowPeopleSection";
  FollowPeopleSection();

  @override
  FollowPeopleSectionRouteState createState() =>
      new FollowPeopleSectionRouteState();
}

class FollowPeopleSectionRouteState extends State<FollowPeopleSection>
    with AutomaticKeepAliveClientMixin {
  List<Userdata>? items = [];
  List<String> followUsers = [];
  bool isError = false;
  // Userdata? userdata;
  late RefreshController refreshController;
  String query = "";
  int page = 0;

  void _onRefresh() async {
    loadItems();
  }

  void _onLoading() async {
    loadMoreItems();
  }

  followunfollowuser(String email, String action) {
    items!.forEach((element) {
      if (element.email == email) {
        element.following = action == "unfollow" ? true : false;
      }
    });
  }

  loadItems() {
    page = 0;
    refreshController.requestRefresh();
    followUsers = [];
    setState(() {});
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  void setItems(List<Userdata>? item) {
    items!.clear();
    items = item;
    refreshController.refreshCompleted();
    isError = false;
    setState(() {});
  }

  void setMoreItems(List<Userdata> item) {
    items!.addAll(item);
    refreshController.loadComplete();
    setState(() {});
  }

  Future<void> fetchItems() async {
    print(query);
    try {
      Userdata? userdata = await SQLiteDbProvider.db.getUserData();
      final response = await Utility.getDio().post(
        ApiUrl.getUsersToFollow,
        data: jsonEncode({
          "data": {
            "email": userdata == null ? "" : userdata.email,
            "page": page.toString(),
            "query": query
          }
        }),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        dynamic res = jsonDecode(response.data);
        List<Userdata>? userList = parseUsers(res);
        if (page == 0) {
          setItems(userList);
        } else {
          setMoreItems(userList!);
        }
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        setFetchError();
      }
    } catch (exception) {
      // I get no exception here
      print(exception);
      setFetchError();
    }
  }

  static List<Userdata>? parseUsers(dynamic res) {
    //final res = jsonDecode(responseBody);
    final parsed = res["users"].cast<Map<String, dynamic>>();
    return parsed.map<Userdata>((json) => Userdata.fromJson2(json)).toList();
  }

  setFetchError() {
    if (page == 0) {
      isError = true;
      refreshController.refreshFailed();
      setState(() {});
    } else {
      refreshController.loadFailed();
      setState(() {});
    }
  }

  @override
  void initState() {
    refreshController = RefreshController(initialRefresh: false);
    Future.delayed(const Duration(milliseconds: 0), () {
      loadItems();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        title: Text(
          t.members,
          style: const TextStyle(
            color: Color(0xFF23141D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F2F5),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFECE1E8)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.search, color: Color(0xFF8B7D86)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      if (value.isEmpty) {
                        query = "";
                        loadItems();
                      }
                    },
                    onSubmitted: (value) {
                      query = value;
                      loadItems();
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration.collapsed(
                      hintStyle: const TextStyle(fontSize: 16),
                      hintText: t.searchforpeople,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text(t.pulluploadmore);
                  } else if (mode == LoadStatus.loading) {
                    body = const CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text(t.loadfailedretry);
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text(t.releaseloadmore);
                  } else {
                    body = Text(t.nomoredata);
                  }
                  return SizedBox(
                    height: 55,
                    child: Center(child: body),
                  );
                },
              ),
              controller: refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: isError
                  ? NoitemScreen(
                      title: t.oops,
                      message: t.dataloaderror,
                      onClick: _onRefresh,
                    )
                  : (items!.isEmpty
                      ? EmptyListScreen(message: t.noitemstodisplay)
                      : ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 8);
                          },
                          itemCount: items!.length,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
                          itemBuilder: (BuildContext context, int index) {
                            return PeopleList(
                              object: items![index],
                              callback: followunfollowuser,
                              isFollowing: followUsers.contains(items![index].email),
                            );
                          },
                        )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PeopleList extends StatefulWidget {
  final Userdata object;
  //final Userdata? userdata;
  final Function callback;
  final bool isFollowing;

  const PeopleList({
    Key? key,
    required this.object,
    //required this.userdata,
    required this.callback,
    required this.isFollowing,
  }) : super(key: key);

  @override
  _PeopleListState createState() => _PeopleListState();
}

class _PeopleListState extends State<PeopleList> {
  bool isFollowing = false;

  Future<void> followUnfollowUser() async {
    try {
      var data = {
        "data": {
          "user": widget.object.email,
          // "follower": widget.userdata!.email,
          "action": isFollowing ? "unfollow" : "follow"
        }
      };
      setState(() {
        isFollowing = isFollowing ? false : true;
        widget.callback(
            widget.object.email, isFollowing ? "unfollow" : "follow");
      });
      print(data);
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
    isFollowing = widget.object.following;
    print("is following = " + isFollowing.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Userdata? userdata = Provider.of<AppStateManager>(context).userdata;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE1E8)),
      ),
      child: ListTile(
        leading: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: SizedBox(
            height: 50,
            width: 50,
            child: CachedNetworkImage(
              imageUrl: widget.object.photo ?? '',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) =>
                  const Center(child: CupertinoActivityIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  Icons.person,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        title: getUserName(context, widget.object),
        subtitle: Text(
          widget.object.gender!,
          style: const TextStyle(color: Color(0xFF7B6D76), fontSize: 13),
        ),
        trailing: (userdata != null && userdata.email == widget.object.email)
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  if (userdata == null) {
                    Navigator.pushNamed(context, AuthPage.routeName,
                        arguments: true);
                  } else {
                    eventBus.fire(StartPartnerChatEvent(widget.object));
                    Navigator.pushReplacementNamed(
                      context,
                      ChatConversations.routeName,
                    );
                  }
                },
                icon: Icon(
                  FontAwesomeIcons.comment,
                  color: MyColors.mainC0lor,
                )),
        onTap: () {},
      ),
    );
  }
}



