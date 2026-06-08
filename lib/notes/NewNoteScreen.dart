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
  late FocusNode _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode = FocusNode();
    _loadNote();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
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
      return const Scaffold(
        backgroundColor: Color(0xFFF7F2F5),
        body: Center(child: Text('Loading...')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2F5),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF2A1720)),
        centerTitle: false,
        title: Text(
          t.createnote,
          style: const TextStyle(
            color: Color(0xFF2A1720),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A3F60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              onPressed: () {
                saveNoteDialog(context);
              },
            ),
          )
        ],
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7A3F60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              saveNoteDialog(context);
            },
            icon: const Icon(Icons.save_outlined, size: 20),
            label: const Text(
              'Save Note',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9DEE5)),
                ),
                child: QuillEditor.basic(
                  controller: _controller!,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void saveNoteDialog(BuildContext _context) {
    // Default the title to the first non-empty line of the note so the user
    // can save straight away without being forced to type a separate title.
    final String defaultTitle = _controller!.document
        .toPlainText()
        .split('\n')
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '')
        .trim();
    String name = defaultTitle;
    final titleController = TextEditingController(text: defaultTitle);
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
              style: const TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  t.cancel,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
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
                  // Fall back to a sensible title when left blank so Save
                  // always works.
                  final String title =
                      name.trim().isEmpty ? 'Untitled note' : name.trim();
                  Provider.of<NotesProvider>(context, listen: false).saveNote(
                    Notes(
                        title: title,
                        color: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)],
                        content: jsonEncode(
                            _controller!.document.toDelta().toJson()),
                        plaincontent: _controller!.document.toPlainText(),
                        date: DateTime.now().millisecondsSinceEpoch),
                  );
                  Navigator.of(context).pop(true);
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
        }).then((saved) {
      titleController.dispose();
      // Only leave the editor when the note was actually saved.
      if (saved == true) {
        Navigator.pop(_context);
      }
    });
  }
}



