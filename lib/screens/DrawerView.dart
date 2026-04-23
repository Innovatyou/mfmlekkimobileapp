import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/utils/img.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class DrawerView extends StatelessWidget {
  final Function(String)? onItemClick;

  const DrawerView({Key? key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: Image.asset(Img.get("logo.png")).image,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  t.appname,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  t.churchmotto,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ...[
                  Menu(LineAwesomeIcons.chrome, t.website),
                  Menu(LineAwesomeIcons.tags, t.terms),
                  Menu(LineAwesomeIcons.th_list, t.privacy),
                  Menu(LineAwesomeIcons.info, t.about),
                  Menu(LineAwesomeIcons.app_store, t.rateapp),
                ]
                    .map((menu) => _SliderMenuItem(
                        title: menu.title,
                        iconData: menu.iconData,
                        onTap: onItemClick))
                    .toList(),
              ],
            ),
          ),
          Container(
            height: 30,
            child: Text(t.appname + " V2.3.0"),
          ),
          Container(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class _SliderMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Function(String)? onTap;

  const _SliderMenuItem(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title,
            style: const TextStyle(
              color: Colors.black,
            )),
        leading: Icon(iconData, color: Colors.black),
        onTap: () => onTap?.call(title));
  }
}

class Menu {
  final IconData iconData;
  final String title;

  Menu(this.iconData, this.title);
}



