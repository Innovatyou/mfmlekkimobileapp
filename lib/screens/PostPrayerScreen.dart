import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/models/Userdata.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';

class PostPrayerScreen extends StatefulWidget {
  static const routeName = "/PostPrayerScreen";
  PostPrayerScreen();

  @override
  PostPrayerScreenState createState() => new PostPrayerScreenState();
}

class PostPrayerScreenState extends State<PostPrayerScreen> {
  Userdata? userdata;
  int? public = 1;
  TextStyle textStyle = TextStyle(height: 1.4, fontSize: 16);
  TextStyle labelStyle = TextStyle();
  UnderlineInputBorder lineStyle1 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[800]!, width: 1));
  UnderlineInputBorder lineStyle2 = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[800]!, width: 2));

  TextEditingController titleController = TextEditingController();
  TextEditingController requesterController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  validateandsubmit() async {
    String _title = titleController.text;
    String _requester = requesterController.text;
    String _content = contentController.text;

    if (_title == "" || _requester == "" || _content == "") {
      Alerts.show(context, t.error, t.updateprofileerrorhint);
    } else {
      Alerts.showProgressDialog(context, t.processingpleasewait);
      FormData formData = FormData.fromMap({
        "title": _title,
        "requester": _requester,
        "content": _content,
        "public": public,
        "email": userdata!.email,
      });

      try {
        var response = await Utility.getDio().post(ApiUrl.SUBMIT_PRAYER,
            data: formData, onSendProgress: (int send, int total) {
          print((send / total) * 100);
        });
        Navigator.of(context).pop();
        print(response.data);
        Alerts.show(context, t.success, t.successprayerposting);
        setState(() {
          titleController.text = "";
          contentController.text = "";
        });
      } on DioError catch (e) {
        Navigator.of(context).pop();
        Alerts.show(context, t.error, e.message);
        if (e.response != null) {
          print(e.response!.data);
          print(e.response!.headers);
          //print(e.response.request);
        } else {
          //print(e.request.headers);
          print(e.message);
        }
      }
    }
  }

  @override
  void initState() {
    userdata = Provider.of<AppStateManager>(context, listen: false).userdata;
    if (userdata != null) {
      requesterController.text =
          userdata!.firstname! + " " + userdata!.lastname!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 1,
          //backgroundColor: MyColors.primary,
          title: Text(t.Prayerrequests),
          leading:
              (Provider.of<AppStateManager>(context, listen: false).userdata ==
                      null)
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done_all,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                validateandsubmit();
              },
            ),
          ]),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      style: textStyle,
                      controller: requesterController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.person),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.fullname,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 15),
                    TextField(
                      style: textStyle,
                      controller: titleController,
                      maxLines: 2,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.pink[800],
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.title),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.prayertitle,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                    TextField(
                      style: textStyle,
                      controller: contentController,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Colors.pink[800],
                      maxLines: 10,
                      decoration: InputDecoration(
                        icon: Container(
                            child: Icon(Icons.text_fields_rounded),
                            margin: EdgeInsets.fromLTRB(0, 15, 0, 0)),
                        labelText: t.prayercontent,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Prayer Visibility",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(height: 4),
                    Container(
                      // height: 50,
                      width: double.infinity,
                      child: Wrap(
                        children: <Widget>[
                          Container(width: 0),
                          Container(
                            width: double.infinity,
                            height: 70,
                            child: RadioListTile<int>(
                              title: Text("Public"),
                              subtitle: Text("All members can see request"),
                              value: 0,
                              groupValue: public,
                              onChanged: (int? value) {
                                setState(() {
                                  public = value;
                                });
                              },
                            ),
                          ),
                          Container(width: 0),
                          Container(
                            width: double.infinity,
                            height: 70,
                            child: RadioListTile<int>(
                              title: Text("Private"),
                              subtitle:
                                  Text("Only you & Pastor can see request"),
                              value: 1,
                              groupValue: public,
                              onChanged: (int? value) {
                                setState(() {
                                  public = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 30),
                  ],
                ),
              )
            ],
          )),
    );
  }
}



