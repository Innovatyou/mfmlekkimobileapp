import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:flash/flash.dart';

class Alerts {
  static void showToast(BuildContext context, String message) {
    showFlash(
      context: context,
      //persistent: false,
      duration: const Duration(seconds: 3),
      builder: (context, controller) => FlashBar(
        controller: controller,
        iconColor: Colors.grey,
        behavior: FlashBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: Colors.grey,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        margin: const EdgeInsets.all(20.0),
        clipBehavior: Clip.antiAlias,
        //insetAnimationDuration: Duration(milliseconds: 50),
        indicatorColor: Colors.red,
        icon: Icon(Icons.info),
        //title: Text('Flash Title'),
        content: Text(message),
      ),
    );
  }

  static Future<void> show(context, title, message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showCupertinoAlert(context, title, message) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text(title),
              content: new Text(message),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(t.ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  static showProgressDialog(BuildContext context, String title) {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  CupertinoActivityIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                  ),
                  Flexible(
                      flex: 8,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }
}



