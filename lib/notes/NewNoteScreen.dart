import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:provider/provider.dart';

class NewNotesScreen extends StatefulWidget {
  static const routeName = "/newnotes";

  @override
  _NewNotesScreenState createState() => _NewNotesScreenState();
}

class _NewNotesScreenState extends State<NewNotesScreen> {
  QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final doc = Document()..insert(0, '');
    setState(() {
      _controller = QuillController(
          document: doc, selection: const TextSelection.collapsed(offset: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: false,
        title: Text(
          t.createnote,
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                saveNoteDialog(context);
              })
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              HardwareKeyboard.instance.isControlPressed &&
              event.logicalKey == LogicalKeyboardKey.keyB) {
            if (_controller!
                .getSelectionStyle()
                .attributes
                .keys
                .contains('bold')) {
              _controller!
                  .formatSelection(Attribute.clone(Attribute.bold, null));
            } else {
              _controller!.formatSelection(Attribute.bold);
            }
          }
        },
        child: _buildWelcomeEditor(context),
      ),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 20,
          ),
          Expanded(
            flex: 15,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: QuillEditor.basic(
                controller: _controller!,
              ),
            ),
          ),
          Container(),
        ],
      ),
    );
  }

  void saveNoteDialog(BuildContext _context) {
    String name = "";
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              t.savenotetitle,
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  t.cancel,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  t.ok,
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  if (name != "") {
                    Provider.of<NotesProvider>(context, listen: false).saveNote(
                      new Notes(
                          title: name,
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          content: jsonEncode(
                              _controller!.document.toDelta().toJson()),
                          plaincontent: _controller!.document.toPlainText(),
                          date: DateTime.now().millisecondsSinceEpoch),
                    );
                    // Navigator.pop(context);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
            content: TextField(
              controller: TextEditingController(text: ""),
              autofocus: true,
              onChanged: (text) {
                name = text;
              },
              // cursorColor: Colors.black,
            ),
          );
        }).then((val) {
      if (name != "") {
        Navigator.pop(_context);
      }
    });
  }
}



