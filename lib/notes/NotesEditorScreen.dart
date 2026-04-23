import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';
import 'note_scaffold.dart';

class NotesEditorScreen extends StatefulWidget {
  static const routeName = "/noteditor";
  const NotesEditorScreen({Key? key, this.notes}) : super(key: key);
  final Notes? notes;
  @override
  _NotesEditorPageState createState() => _NotesEditorPageState();
}

class _NotesEditorPageState extends State<NotesEditorScreen> {
  late QuillController _controller;
  bool _edit = false;

  @override
  Widget build(BuildContext context) {
    return NoteScaffold(
      content: widget.notes!.content,
      builder: _buildContent,
      showToolbar: _edit == true,
      floatingActionButton: FloatingActionButton.small(
          backgroundColor: MyColors.mainC0lor,
          //label: Text(_edit == true ? t.done : t.edit),
          onPressed: _toggleEdit,
          child: Icon(_edit == true ? Icons.check : Icons.edit)),
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    _controller = controller!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: _edit
            ? QuillEditor.basic(
                controller: _controller,
              )
            : SingleChildScrollView(
                child: Text(_controller.document.toPlainText()),
              ),
      ),
    );
  }

  void _toggleEdit() {
    if (_edit) {
      String? name = widget.notes == null ? "" : widget.notes!.title;
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                t.savenotetitle,
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(
                    t.cancel,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text(
                    t.ok,
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    if (name != "") {
                      Provider.of<NotesProvider>(context, listen: false)
                          .saveNote(
                        new Notes(
                          title: name,
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          content: jsonEncode(
                              _controller.document.toDelta().toJson()),
                          plaincontent: _controller.document.toPlainText(),
                          date: widget.notes!.date,
                          id: widget.notes!.id,
                        ),
                      );
                      // Navigator.pop(context);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
              content: TextField(
                controller: TextEditingController(
                    text: widget.notes == null ? "" : widget.notes!.title),
                autofocus: true,
                onChanged: (text) {
                  name = text;
                },
                // cursorColor: Colors.black,
              ),
            );
          }).then((val) {
        setState(() {
          _edit = false;
        });
      });
    } else {
      setState(() {
        _edit = !_edit;
      });
    }
  }
}



