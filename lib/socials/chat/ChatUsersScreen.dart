import 'package:higherground/utils/TimUtil.dart';
import 'package:flutter/rendering.dart';
import 'package:higherground/models/Chats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/ChatManager.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'package:higherground/utils/my_colors.dart';
import 'SelectChatPeople.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/models/UserEvents.dart';
import 'ChatConversations.dart';

class ChatUsersScreen extends StatefulWidget {
  static const routeName = "/ChatUsersScreen";
  ChatUsersScreen();

  @override
  ChatUsersScreenRouteState createState() => new ChatUsersScreenRouteState();
}

class ChatUsersScreenRouteState extends State<ChatUsersScreen> {
  late ChatManager chatManager;
  late List<Chats?> items;
  late ScrollController controller;
  bool fabIsVisible = true;

  void _onRefresh() async {
    chatManager.loadItems();
  }

  void _onLoading() async {
    chatManager.loadMoreItems();
  }

  @override
  void initState() {
    controller = ScrollController();
    controller.addListener(() {
      setState(() {
        fabIsVisible =
            controller.position.userScrollDirection == ScrollDirection.forward;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    chatManager = Provider.of<ChatManager>(context);
    items = chatManager.userChatsList;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Color(0xFF0f172a),
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
      ),
      backgroundColor: const Color(0xFFF7F2F5),
      body: SmartRefresher(
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
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: chatManager.refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: (chatManager.isError == true || items.length == 0)
            ? EmptyListScreen(
                message: t.nochatsavailable,
              )
            : ListView.separated(
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (BuildContext context, int index) {
                  return _ChatItem(
                    key: UniqueKey(),
                    index: index,
                    chats: items[index],
                  );
                },
              ),
      ),
      floatingActionButton: AnimatedOpacity(
        child: FloatingActionButton(
          backgroundColor: MyColors.mainC0lor,
          onPressed: () {
            Navigator.of(context).pushNamed(SelectChatPeople.routeName);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
        duration: const Duration(milliseconds: 100),
        opacity: fabIsVisible ? 1 : 0,
      ),
    );
  }

}

class _ChatItem extends StatelessWidget {
  final Key? key;
  final Chats? chats;
  final int? index;
  _ChatItem({this.chats, this.index, this.key}) : super(key: key);

  Widget _activeIcon(isActive) {
    if (isActive) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3),
          width: 16,
          height: 16,
          color: Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Color(0xff43ce7d), // flat green
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        eventBus.fire(StartPartnerChatEvent(chats!.partner));
        Navigator.pushNamed(
          context,
          ChatConversations.routeName,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECE1E8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      eventBus.fire(StartPartnerChatEvent(chats!.partner));
                      Navigator.pushNamed(
                        context,
                        ChatConversations.routeName,
                      );
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFF1E5EC),
                      backgroundImage: (chats!.partner!.photo ?? '').isNotEmpty
                          ? NetworkImage(chats!.partner!.photo!)
                          : null,
                      child: (chats!.partner!.photo ?? '').isEmpty
                          ? const Icon(Icons.person, color: Color(0xFF8A7D86))
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _activeIcon(chats!.isOnline == 0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chats!.partner!.name!,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF0f172a),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      chats!.isTyping
                          ? Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Text(
                                t.typing,
                                style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF7B6D76),
                                ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: chats!.chatMessages!.length > 0
                                  ? (chats!.chatMessages![0].message != "")
                                      ? Text(chats!.chatMessages![0].message!,
                                          style: const TextStyle(
                                            color: Color(0xFF7B6D76),
                                            fontSize: 14,
                                            height: 1.15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)
                                      : Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.photo,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              t.photo,
                                              style: const TextStyle(fontSize: 14),
                                            )
                                          ],
                                        )
                                  : Text(chats!.partner!.gender!,
                                      style: const TextStyle(
                                        color: Color(0xFF7B6D76),
                                        fontSize: 14,
                                        height: 1.15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                            )
                    ],
                  )),
            ),
            Column(
              children: <Widget>[
                chats!.chatMessages!.length > 0
                    ? Text(
                        TimUtil.timeAgoSinceDate(chats!.chatMessages![0].date!),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12))
                    : const SizedBox.shrink(),
                _UnreadIndicator(chats!.unseen),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  final int? unread;

  _UnreadIndicator(this.unread);

  @override
  Widget build(BuildContext context) {
    if (unread == 0) {
      return const SizedBox.shrink();
    } else {
      return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 26,
                color: const Color(0xFFD74A62),
                width: 26,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: Text(
                  unread! > 9 ? "9+" : unread.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )));
    }
  }
}



