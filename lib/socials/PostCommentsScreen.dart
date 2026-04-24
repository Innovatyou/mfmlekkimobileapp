import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/screens/AuthPage.dart';
import 'package:provider/provider.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/widgets/PostCommentsItem.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/models/UserPosts.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/providers/PostsCommentsModel.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/widgets/UserPostTile.dart';
import 'package:higherground/models/Comments.dart';

class PostCommentsScreen extends StatefulWidget {
  static String routeName = "/postcomments";
  final UserPosts? userPosts;

  PostCommentsScreen({Key? key, this.userPosts}) : super(key: key);

  @override
  _PostCommentsScreenState createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateManager>(context);
    Userdata? userdata = appState.userdata;

    return ChangeNotifierProvider(
        create: (context) => PostsCommentsModel(context, widget.userPosts!.id,
            widget.userPosts!.email, userdata, widget.userPosts!.commentsCount),
        child: CommentsSection(widget: widget, userdata: userdata));
  }
}

class CommentsSection extends StatelessWidget {
  const CommentsSection({
    Key? key,
    required this.widget,
    required this.userdata,
  }) : super(key: key);

  final PostCommentsScreen widget;
  final Userdata? userdata;

  @override
  Widget build(BuildContext context) {
    final UserPosts userPosts = widget.userPosts!;
    final Color accentColor = MyColors.mainC0lor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        userPosts.commentsCount =
            Provider.of<PostsCommentsModel>(context, listen: false)
                .totalPostComments;
        Navigator.pop(context, userPosts);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F2F5),
          leading: BackButton(
            onPressed: () {
              userPosts.commentsCount =
                  Provider.of<PostsCommentsModel>(context, listen: false)
                      .totalPostComments;
              Navigator.pop(context, userPosts);
            },
          ),
          title: Text(
            t.postdetails,
            style: const TextStyle(
              color: Color(0xFF20131C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D1626), Color(0xFF563349)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.forum_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.comments,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Join the conversation and share your thoughts.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.78),
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Consumer<PostsCommentsModel>(
                            builder: (context, commentsModel, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Text(
                                  '${commentsModel.totalPostComments ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Consumer<PostsCommentsModel>(
                      builder: (context, commentsModel, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 28,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: UserPostTile(
                              index: 0,
                              object: widget.userPosts!,
                              userdata: userdata,
                              likePostCallback:
                                  (int index, bool isLiked, int likesCount) {
                                userPosts.isLiked = isLiked;
                                userPosts.likesCount = likesCount;
                              },
                              pinPostCallback: (int index, bool isPinned) {
                                userPosts.isPinned = isPinned;
                              },
                              editPostCallback: (_, __) {},
                              deletePostCallback: (_) {},
                              isCommentsSection: true,
                              commentsCount: commentsModel.totalPostComments,
                              key: UniqueKey(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            t.comments,
                            style: const TextStyle(
                              color: Color(0xFF20131C),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Consumer<PostsCommentsModel>(
                            builder: (context, commentsModel, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9DCE4),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${commentsModel.totalPostComments ?? 0}',
                                  style: const TextStyle(
                                    color: Color(0xFF563349),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const CommentsLists(),
                  ],
                ),
              ),
            ),
            const Divider(height: 0, thickness: 1, color: Color(0xFFE8DDE4)),
            userdata == null
                ? SafeArea(
                    top: false,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8DDE4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2E6EC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.lock_open_rounded,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.logintoaddcomment,
                              style: const TextStyle(
                                color: Color(0xFF3C2834),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AuthPage.routeName,
                                arguments: true,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Consumer<PostsCommentsModel>(
                    builder: (context, commentsModel, child) {
                      return SafeArea(
                        top: false,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 42,
                                height: 42,
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2E6EC),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.mode_comment_outlined,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: commentsModel.inputController,
                                  maxLines: 5,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: t.writeamessage,
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9D8C96),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(
                                      bottom: 8,
                                      top: 8,
                                    ),
                                  ),
                                ),
                              ),
                              commentsModel.isMakingComment
                                  ? const SizedBox(
                                      width: 46,
                                      height: 46,
                                      child: Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    )
                                  : IconButton(
                                      style: IconButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.white,
                                        fixedSize: const Size(46, 46),
                                      ),
                                      icon: const Icon(Icons.send_rounded, size: 20),
                                      onPressed: () {
                                        final text = commentsModel.inputController.text;
                                        if (text.trim().isNotEmpty) {
                                          commentsModel.makeComment(text.trim());
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class CommentsLists extends StatelessWidget {
  const CommentsLists({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var commentsModel = Provider.of<PostsCommentsModel>(context);
    List<Comments> commentsList = commentsModel.items;
    if (commentsModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CupertinoActivityIndicator()),
      );
    } else if (commentsList.length == 0) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8DDE4)),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2E6EC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF563349),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.nocomments,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6D5A65),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                commentsModel.loadComments();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF563349),
                side: const BorderSide(color: Color(0xFFD9C4CF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        controller: commentsModel.scrollController,
        itemCount: commentsModel.hasMoreComments!
            ? commentsList.length + 1
            : commentsList.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0 && commentsModel.isLoadingMore) {
            return const SizedBox(
              height: 56,
              child: Center(child: CupertinoActivityIndicator()),
            );
          } else if (index == 0 && commentsModel.hasMoreComments!) {
            return SizedBox(
              height: 44,
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF563349),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.expand_less_rounded, size: 18),
                  label: Text(t.loadmore),
                  onPressed: () {
                    Provider.of<PostsCommentsModel>(context, listen: false)
                        .loadMoreComments();
                  },
                ),
              ),
            );
          } else {
            int _index = index;
            if (commentsModel.hasMoreComments!) _index = index - 1;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEDE2E8)),
              ),
              child: PostCommentsItem(
                isUser: commentsModel.isUser(commentsList[_index].email),
                context: context,
                index: _index,
                object: commentsList[_index],
              ),
            );
          }
        },
      );
    }
  }
}



