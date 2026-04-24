import 'package:higherground/utils/Utility.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:higherground/socials/MakePostScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/UserPosts.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/screens/NoitemScreen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'package:higherground/widgets/UserPostTile.dart';
import 'package:higherground/socials/PinnedPosts.dart';

class UserPostsSection extends StatefulWidget {
  UserPostsSection();

  @override
  UserPostsSectionRouteState createState() => new UserPostsSectionRouteState();
}

class UserPostsSectionRouteState extends State<UserPostsSection>
    with AutomaticKeepAliveClientMixin {
  List<UserPosts>? items = [];
  bool isError = false;
  Userdata? userdata;
  late RefreshController refreshController;
  String query = "";
  int page = 0;

  void _onRefresh() async {
    loadItems();
  }

  void _onLoading() async {
    loadMoreItems();
  }

  loadItems() {
    page = 0;
    refreshController.requestRefresh();
    setState(() {});
    fetchItems();
  }

  loadMoreItems() {
    page = page + 1;
    fetchItems();
  }

  editPostCallback(int index, String text) {
    items![index].content = text;
    setState(() {});
  }

  deletePostCallback(int index) {
    items!.removeAt(index);
    setState(() {});
  }

  likePostCallback(int index, bool isLiked, int likesCount) {
    items![index].isLiked = isLiked;
    items![index].likesCount = likesCount;
  }

  pinPostCallback(int index, bool isPinned) {
    items![index].isPinned = isPinned;
  }

  void setItems(List<UserPosts>? item) {
    items!.clear();
    items = item;
    refreshController.refreshCompleted();
    isError = false;
    setState(() {});
  }

  void setMoreItems(List<UserPosts> item) {
    items!.addAll(item);
    refreshController.loadComplete();
    setState(() {});
  }

  Future<void> fetchItems() async {
    print(query);
    try {
      var data = {
        "data": {
          "email": userdata == null ? "" : userdata!.email,
          "page": page.toString()
        }
      };
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.fetchUserPosts,
        data: jsonEncode(data),
      );
      print(response.data);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print(response.data);
        dynamic res = jsonDecode(response.data);
        List<UserPosts>? postsList = parsePosts(res);
        if (page == 0) {
          setItems(postsList);
        } else {
          setMoreItems(postsList!);
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

  static List<UserPosts>? parsePosts(dynamic res) {
    //final res = jsonDecode(responseBody);
    final parsed = res["posts"].cast<Map<String, dynamic>>();
    return parsed.map<UserPosts>((json) => UserPosts.fromJson(json)).toList();
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
    userdata = Provider.of<AppStateManager>(context).userdata;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            if (userdata != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () async {
                    final dynamic result =
                        await Navigator.pushNamed(context, MakePostScreen.routeName);
                    if (result == true) {
                      loadItems();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE9DCE4)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: SizedBox(
                            height: 38,
                            width: 38,
                            child: CachedNetworkImage(
                              imageUrl: userdata!.photo ?? '',
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  const Center(child: CupertinoActivityIndicator()),
                              errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.person, color: Color(0xFF8A7D86)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 42,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5EEF2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              t.shareyourthoughts,
                              style: const TextStyle(
                                color: Color(0xFF8B7A84),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E6EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.insert_photo_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
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
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
                              itemCount: items!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return UserPostTile(
                                  index: index,
                                  object: items![index],
                                  userdata: userdata,
                                  likePostCallback: likePostCallback,
                                  pinPostCallback: pinPostCallback,
                                  isCommentsSection: false,
                                  editPostCallback: editPostCallback,
                                  deletePostCallback: deletePostCallback,
                                  key: UniqueKey(),
                                );
                              },
                            )),
                ),
              ),
            ),
            if (userdata != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pushNamed(context, PinnedPosts.routeName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE8DDE4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E6EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LineAwesomeIcons.pinterest),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.mypins,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.navigate_next),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}



