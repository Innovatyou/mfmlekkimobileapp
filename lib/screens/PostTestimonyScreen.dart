import 'package:dio/dio.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/ApiUrl.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/models/Userdata.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';

class PostTestimonyScreen extends StatefulWidget {
  static const routeName = "/PostTestimonyScreen";
  PostTestimonyScreen();

  @override
  PostTestimonyScreenScreenState createState() =>
      new PostTestimonyScreenScreenState();
}

class PostTestimonyScreenScreenState extends State<PostTestimonyScreen> {
  Userdata? userdata;
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
        "testifier": _requester,
        "content": _content,
      });
      try {
        var response = await Utility.getDio().post(ApiUrl.SUBMIT_TESTIMONY, data: formData,
            onSendProgress: (int send, int total) {
          print((send / total) * 100);
        });
        Navigator.of(context).pop();
        print(response.data);
        Alerts.show(context, t.success, t.successtestimonyposting);
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
          backgroundColor: MyColors.primary,
          title: Text(t.addtestimony),
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
                color: Colors.blue[700],
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
                        labelText: t.testimonytitle,
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
                        labelText: t.testimonycontent,
                        labelStyle: labelStyle,
                        enabledBorder: lineStyle1,
                        focusedBorder: lineStyle2,
                      ),
                    ),
                    Container(height: 10),
                  ],
                ),
              )
            ],
          )),
    );
  }
}



