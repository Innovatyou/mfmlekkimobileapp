import 'package:higherground/utils/Alerts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:higherground/models/CommentsArguement.dart';
import 'package:higherground/socials/PostCommentsScreen.dart';
import 'package:higherground/socials/likesPostPeople.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/UserPosts.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/socials/PostImageViewer.dart';
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/widgets/ReadMoreText.dart';
import 'package:higherground/socials/PostVideoPlayer.dart';
import 'package:higherground/utils/img.dart';
import 'package:higherground/socials/utils.dart';
import 'package:higherground/socials/PostPopupMenu.dart';

class UserPostTile extends StatefulWidget {
  final int index;
  final UserPosts object;
  final Userdata? userdata;
  final Function likePostCallback;
  final Function pinPostCallback;
  final Function editPostCallback;
  final Function deletePostCallback;
  final bool isCommentsSection;
  final int? commentsCount;

  const UserPostTile(
      {Key? key,
      required this.index,
      required this.object,
      required this.userdata,
      required this.likePostCallback,
      required this.pinPostCallback,
      required this.editPostCallback,
      required this.deletePostCallback,
      required this.isCommentsSection,
      this.commentsCount})
      : super(key: key);

  @override
  _UserPostTileState createState() => _UserPostTileState();
}

class _UserPostTileState extends State<UserPostTile> {
  bool? isLiked = false;
  bool? isPinned = false;
  int? likesCount = 0;
  int? commentsCount = 0;
  final TextEditingController editController = new TextEditingController();

  final _pageController = PageController();
  int currentPage = 1;

  Future<void> likeposts() async {
    try {
      var data = {
        "data": {
          "id": widget.object.id,
          "user": widget.object.email,
          "email": widget.userdata == null ? "" : widget.userdata!.email,
          "action": isLiked! ? "unlike" : "like"
        }
      };
      setState(() {
        isLiked = isLiked! ? false : true;
        if (isLiked!) {
          likesCount = likesCount! + 1;
        } else {
          likesCount = likesCount! - 1;
        }
        widget.likePostCallback(widget.index, isLiked, likesCount);
      });
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.likeunlikepost,
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

  Future<void> pinpost() async {
    try {
      var data = {
        "data": {
          "id": widget.object.id,
          "email": widget.userdata == null ? "" : widget.userdata!.email,
          "action": isPinned! ? "unpin" : "pin"
        }
      };
      print(data);
      setState(() {
        isPinned = isPinned! ? false : true;
      });
      widget.pinPostCallback(widget.index, isPinned);
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.pinunpinpost,
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

  Future<void> editPost() async {
    editController.text = widget.object.content!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text(Strings.edit_comment_alert),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: editController,
              maxLines: 5,
              minLines: 1,
              autofocus: true,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                child: Text(t.cancel),
                onPressed: () {
                  Navigator.pop(context);
                }),
            ElevatedButton(
                child: Text(t.save),
                onPressed: () {
                  String text = editController.text;
                  if (text != "") {
                    Navigator.of(context).pop();
                    editPostServer(text);
                  }
                }),
          ],
        );
      },
    );
  }

  Future<void> editPostServer(String txt) async {
    try {
      var data = {
        "data": {
          "id": widget.object.id,
          "content": Utility.getBase64EncodedString(txt),
          "visibility": "public"
        }
      };

      widget.editPostCallback(widget.index, txt);
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.editPost,
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

  Future<void> deletePost() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(t.deletepost),
              content: new Text(t.deleteposthint),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: false,
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                    deletePostServer();
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

  Future<void> deletePostServer() async {
    try {
      var data = {
        "data": {
          "id": widget.object.id,
        }
      };

      widget.deletePostCallback(widget.index);
      print(data);
      final response = await Utility.getDio().post(
        ApiUrl.deletePost,
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        //print(response.data);
      }
    } catch (exception) {
      // I get no exception here
      //print(exception);
    }
  }

  @override
  void initState() {
    isLiked = widget.object.isLiked;
    isPinned = widget.object.isPinned;
    likesCount = widget.object.likesCount;
    if (widget.isCommentsSection) {
      commentsCount = widget.commentsCount;
    } else {
      commentsCount = widget.object.commentsCount;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE1E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CachedNetworkImage(
                            imageUrl: widget.object.avatar ?? '',
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
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getUserName(
                              context,
                              new Userdata(
                                  email: widget.object.email,
                                  name: widget.object.name,
                                  photo: widget.object.avatar,
                                  coverphoto: widget.object.coverPhoto)),
                          const SizedBox(height: 2),
                          Text(
                            TimUtil.timeAgo(widget.object.timestamp!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A7D86),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      (widget.userdata != null &&
                              widget.object.email == widget.userdata!.email &&
                              !widget.isCommentsSection)
                          ? PostPopupMenu(widget.object, editPost, deletePost)
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                widget.object.media!.length == 0
                    ? const SizedBox.shrink()
                    : Stack(
                        children: [
                          SizedBox(
                            height: 250,
                            child: PageView.builder(
                              onPageChanged: (int index) {
                                setState(() {
                                  currentPage = index + 1;
                                });
                              },
                              controller: _pageController,
                              itemBuilder: (context, position) {
                                String ext = Utility.getFileExtension(
                                    widget.object.media![position]);
                                if (ext == "mp4")
                                  return PostVideoPlayer(
                                    videoURL: widget.object.media![position],
                                  );
                                else
                                  return PostImageViewer(
                                    imgURL: widget.object.media![position],
                                  );
                              },
                              itemCount:
                                  widget.object.media!.length, // Can be null
                            ),
                          ),
                          widget.object.media!.length < 2
                                ? const SizedBox.shrink()
                              : Positioned(
                                  top: 15,
                                  right: 10,
                                  child: SizedBox(
                                    height: 30,
                                    width: 60,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      margin: EdgeInsets.all(0),
                                      color: Colors.black45,
                                      elevation: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$currentPage/${widget.object.media!.length}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                widget.object.media!.length < 2
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SmoothPageIndicator(
                                controller: _pageController, // PageController
                                count: widget.object.media!.length,
                                effect: WormEffect(
                                    dotHeight: 6,
                                    dotWidth: 6,
                                    dotColor: Colors.grey,
                                    activeDotColor: MyColors.mainC0lor),
                                onDotClicked: (index) {}),
                          ),
                          const Spacer(),
                        ],
                      ),
                widget.object.content == ""
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: ReadMoreText(
                          widget.object.content!,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.35,
                            color: Color(0xFF2B1A24),
                          ),
                          trimLines: 5,
                          colorClickableText: MyColors.mainC0lor,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: t.readmore,
                          trimExpandedText: t.less,
                        ),
                      ),
              ],
            ),
          ),
          Container(
            height: 55,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 14),
                InkWell(
                  onTap: () {
                    if (widget.userdata == null) {
                      Alerts.showToast(context, t.logintolikeapost);
                      return;
                    }
                    likeposts();
                  },
                  child: Icon(
                    LineAwesomeIcons.thumbs_up,
                    size: 28,
                    color: isLiked! ? MyColors.mainC0lor : const Color(0xFF2E1D27),
                  ),
                ),
                const SizedBox(width: 4),
                likesCount == 0
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, LikesPostPeople.routeName,
                              arguments: ScreenArguements(
                                items: widget.object,
                              ));
                        },
                        child: Text(
                          '${likesCount.toString()}${t.likess}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () async {
                    if (!widget.isCommentsSection) {
                      var userPosts = await Navigator.pushNamed(
                        context,
                        PostCommentsScreen.routeName,
                        arguments: CommentsArguement(item: widget.object),
                      );
                      Future.delayed(const Duration(milliseconds: 100), () {
                        setState(() {
                          isLiked = (userPosts as UserPosts).isLiked;
                          isPinned = userPosts.isPinned;
                          likesCount = userPosts.likesCount;
                          commentsCount = userPosts.commentsCount;
                        });
                      });
                    }
                  },
                  child: Icon(LineAwesomeIcons.comment, size: 26),
                ),
                commentsCount == 0
                    ? const SizedBox.shrink()
                    : Text(commentsCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        )),
                const Spacer(),
                InkWell(
                  onTap: () {
                    if (widget.userdata == null) {
                      Alerts.showToast(context, t.logintopinapost);
                      return;
                    }
                    pinpost();
                  },
                  child: Image.asset(
                    Img.get("pins.png"),
                    height: 26,
                    color: isPinned! ? MyColors.mainC0lor : const Color(0xFF2E1D27),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}



