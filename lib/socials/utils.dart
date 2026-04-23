import 'package:flutter/material.dart';
import 'UserProfileScreen.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/providers/events.dart';
import 'package:higherground/models/UserEvents.dart';
import 'chat/ChatConversations.dart';

Widget getUserName(BuildContext context, Userdata userdata,
    {bool isClickable = true}) {
  return InkWell(
    onTap: () {
      if (!isClickable) {
        eventBus.fire(StartPartnerChatEvent(userdata));
        Navigator.pushReplacementNamed(
          context,
          ChatConversations.routeName,
        );
      } else
        Navigator.pushNamed(
          context,
          UserProfileScreen.routeName,
          arguments: ScreenArguements(items: userdata),
        );
    },
    child: Text(
      userdata.name!,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'WorkSans',
          color: Colors.black),
    ),
  );
}


