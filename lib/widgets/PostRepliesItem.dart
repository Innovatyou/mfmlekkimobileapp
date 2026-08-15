import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/Utility.dart';
import 'package:higherground/models/Replies.dart';
import 'package:higherground/providers/PostRepliesModel.dart';
import 'package:higherground/models/Userdata.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:provider/provider.dart';
import 'package:higherground/socials/utils.dart';

class PostRepliesItem extends StatelessWidget {
  final bool isUser;
  final Replies object;
  final int index;
  final BuildContext context;

  const PostRepliesItem(
      {Key? key,
      required this.isUser,
      required this.index,
      required this.object,
      required this.context})
      : super(key: key);

  reportPost(int id, int index, String reason) {
    Provider.of<PostRepliesModel>(context, listen: false)
        .reportComment(id, index, reason);
  }

  @override
  Widget build(BuildContext context) {
    Userdata? userdata = Provider.of<AppStateManager>(context).userdata;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: IntrinsicHeight(
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            object.avatar == ""
                ? CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Center(
                      child: Text(
                        object.name!.substring(0, 1),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                : Card(
                    margin: EdgeInsets.all(0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Container(
                      height: 40,
                      width: 40,
                      child: CachedNetworkImage(
                        imageUrl: object.avatar!,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black12, BlendMode.darken)),
                          ),
                        ),
                        placeholder: (context, url) =>
                            Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
            Container(width: 10),
            Flexible(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      getUserName(
                          context,
                          new Userdata(
                              email: object.email,
                              name: object.name,
                              photo: object.avatar,
                              coverphoto: object.coverPhoto)),
                      Spacer(),
                      Text(TimUtil.timeAgoSinceDate(object.date!),
                          style: TextStyles.caption(context)
                          //.copyWith(color: MyColors.grey_60),
                          ),
                    ],
                  ),
                  Container(height: 8),
                  Container(
                    width: double.infinity,
                    child: Text(Utility.getBase64DecodedString(object.content!),
                        maxLines: 10,
                        textAlign: TextAlign.left,
                        style: TextStyles.subhead(context).copyWith(
                            //color: MyColors.grey_80,
                            fontWeight: FontWeight.w500)),
                  ),
                  Container(height: 8),
                  Row(
                    children: <Widget>[
                      Spacer(),
                      Row(
                        children: <Widget>[
                          Visibility(
                            visible: isUser ? false : true,
                            child: InkWell(
                              child: Icon(Icons.report,
                                  color: Colors.pink[300], size: 20.0),
                              onTap: () async {
                                if (userdata == null) {
                                  Alerts.showToast(
                                      context, t.logintoreportapost);
                                  return;
                                }
                                await showDialog<void>(
                                    context: context,
                                    barrierDismissible:
                                        false, // user must tap button!
                                    builder: (BuildContext context) {
                                      return ReportCommentDialog(
                                        id: object.id,
                                        index: index,
                                        function: reportPost,
                                      );
                                    });
                              },
                            ),
                          ),
                          Container(width: 10),
                          Visibility(
                            visible: isUser ? true : false,
                            child: InkWell(
                              child: Icon(Icons.edit,
                                  color: Colors.lightBlue, size: 20.0),
                              onTap: () {
                                Provider.of<PostRepliesModel>(context,
                                        listen: false)
                                    .showEditCommentAlert(object.id, index);
                              },
                            ),
                          ),
                          Container(width: 10),
                          Visibility(
                            visible: isUser ? true : false,
                            child: InkWell(
                              child: Icon(Icons.delete_forever,
                                  color: Colors.redAccent, size: 20.0),
                              onTap: () {
                                Provider.of<PostRepliesModel>(context,
                                        listen: false)
                                    .showDeleteCommentAlert(object.id, index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportCommentDialog extends StatefulWidget {
  final id, index;
  final Function? function;
  ReportCommentDialog({Key? key, this.id, this.index, this.function})
      : super(key: key);

  @override
  _ReportCommentDialogState createState() => _ReportCommentDialogState();
}

class _ReportCommentDialogState extends State<ReportCommentDialog> {
  List<String> reportOptions = t.reportCommentsList;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        t.reportcomment,
        style: TextStyles.subhead(context),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.cancel,
            style: TextStyle(color: Colors.red),
          ),
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(t.ok),
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.function!(widget.id, widget.index, reportOptions[_selected]);
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: RadioGroup<int>(
                  groupValue: _selected,
                  onChanged: (int? value) {
                    setState(() {
                      _selected = value ?? _selected;
                    });
                  },
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: reportOptions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return RadioListTile(
                            title: Text(reportOptions[index]), value: index);
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
