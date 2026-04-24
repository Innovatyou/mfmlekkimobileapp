import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/providers/NotesProvider.dart';
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
          backgroundColor: const Color(0xFF7A3F60),
          onPressed: _toggleEdit,
          child: Icon(_edit == true ? Icons.check : Icons.edit)),
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    _controller = controller!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9DEE5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: _edit
              ? QuillEditor.basic(
                  controller: _controller,
                )
              : SingleChildScrollView(
                  child: Text(
                    _controller.document.toPlainText(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E2028),
                      height: 1.45,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _toggleEdit() {
    if (_edit) {
      String? name = widget.notes == null ? "" : widget.notes!.title;
      final titleController = TextEditingController(
        text: widget.notes == null ? "" : widget.notes!.title,
      );
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                t.savenotetitle,
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    t.cancel,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7A3F60),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    t.ok,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    if (name != "") {
                      Provider.of<NotesProvider>(context, listen: false)
                          .saveNote(
                        Notes(
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
                controller: titleController,
                autofocus: true,
                onChanged: (text) {
                  name = text;
                },
                decoration: const InputDecoration(
                  hintText: 'Note title',
                ),
              ),
            );
          }).then((val) {
        titleController.dispose();
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



