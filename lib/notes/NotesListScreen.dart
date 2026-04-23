import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/notes/NotesEditorScreen.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/screens/EmptyListScreen.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/utils/rounded_bordered_container.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'NewNoteScreen.dart';
import 'package:clipboard/clipboard.dart';

class NotesListScreen extends StatefulWidget {
  static const routeName = "/noteslist";
  @override
  NotesListScreenRouteState createState() => NotesListScreenRouteState();
}

class NotesListScreenRouteState extends State<NotesListScreen> {
  NotesProvider? notesProvider;
  ScrollController? controller;
  bool fabIsVisible = true;
  bool showClear = false;
  String query = "";
  final TextEditingController inputController = new TextEditingController();

  @override
  void initState() {
    controller = ScrollController();
    controller!.addListener(() {
      setState(() {
        fabIsVisible =
            controller!.position.userScrollDirection == ScrollDirection.forward;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notesProvider = Provider.of<NotesProvider>(context);
    List<Notes> items = notesProvider!.notesList;

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        // elevation: 0.3,
        title: TextField(
          maxLines: 1,
          controller: inputController,
          style: new TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          keyboardType: TextInputType.text,
          onChanged: (term) {
            if (term.length > 0) {
              notesProvider!.searchNotes(term);
              showClear = true;
            } else if (term.length == 0) {
              showClear = false;
              notesProvider!.getNotes();
            }
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: t.notes,
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          showClear
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed: () {
                    inputController.clear();
                    showClear = false;
                    setState(() {
                      query = "";
                    });
                    notesProvider!.getNotes();
                  },
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12),
        child: (items.length == 0)
            ? EmptyListScreen(message: t.nonotesfound)
            : ListView.separated(
                controller: controller,
                itemCount: items.length,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(3),
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  return ItemTile(
                    object: items[index],
                    notesProvider: notesProvider,
                  );
                },
              ),
      ),
      floatingActionButton: AnimatedOpacity(
        child: FloatingActionButton.small(
          backgroundColor: MyColors.mainC0lor,
          onPressed: () {
            Navigator.of(context).pushNamed(NewNotesScreen.routeName);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          //icon: Icon(Icons.add_circle),
          // label: Text(t.newnote),
        ),
        duration: Duration(milliseconds: 100),
        opacity: fabIsVisible ? 1 : 0,
      ),
    );
  }
}

class ItemTile extends StatelessWidget {
  final Notes object;
  final NotesProvider? notesProvider;

  const ItemTile({
    Key? key,
    required this.object,
    required this.notesProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(NotesEditorScreen.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: object,
              itemsList: [],
            ));
      },
      child: RoundedContainer(
        padding: const EdgeInsets.all(0),
        margin: EdgeInsets.all(5),
        height: 150,
        child: Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      //color: Colors.blue,
                      height: 40,
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Text(
                              TimUtil.formatMilliSecondsFullDatestamp(
                                  object.date!),
                              style: TextStyles.caption(context)
                                  .copyWith(fontSize: 16)
                              //.copyWith(color: MyColors.grey_60),
                              ),
                          Spacer(),
                          Text(
                              TimUtil.formatMilliSecondsFullDTime(object.date!),
                              style: TextStyles.caption(context)
                                  .copyWith(fontSize: 16)
                              //.copyWith(color: MyColors.grey_60),

                              ),
                          Container(
                            width: 12,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        object.title!,
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        Bidi.stripHtmlIfNeeded(object.plaincontent!),
                        overflow: TextOverflow.fade,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                    ),
                    Container(
                      height: 6,
                    ),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        InkWell(
                          child: Icon(Icons.share,
                              color: Colors.lightBlue, size: 21.0),
                          onTap: () async {
                            /*final doc = Document.fromJson(jsonDecode(object.content));
                    QuillController _controller = QuillController(
                        document: doc,
                        selection: const TextSelection.collapsed(offset: 0));*/

                            await Share.share(
                              Document.fromJson(jsonDecode(object.content!))
                                  .toPlainText(),
                              subject: object.title,
                            );
                          },
                        ),
                        Container(width: 15),
                        InkWell(
                          child: Icon(Icons.content_copy,
                              color: Colors.orange, size: 21.0),
                          onTap: () {
                            FlutterClipboard.copy(Document.fromJson(
                                        jsonDecode(object.content!))
                                    .toPlainText())
                                .then((value) => Alerts.show(
                                    context, "", t.copiedtoclipboard));
                          },
                        ),
                        Container(width: 15),
                        InkWell(
                          child: Icon(Icons.delete_forever,
                              color: Colors.red, size: 21.0),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => new CupertinoAlertDialog(
                                title: new Text(t.deletenote),
                                content: new Text(t.deletenotehint),
                                actions: <Widget>[
                                  new TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: new Text(
                                      t.cancel,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  new TextButton(
                                    onPressed: () {
                                      notesProvider!.deleteNote(object);
                                      Navigator.of(context).pop();
                                    },
                                    child: new Text(t.ok),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



