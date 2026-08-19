import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

class NewNotesScreen extends StatefulWidget {
  static const routeName = "/newnotes";

  @override
  _NewNotesScreenState createState() => _NewNotesScreenState();
}

class _NewNotesScreenState extends State<NewNotesScreen> {
  QuillController? _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
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
        backgroundColor: Color(0xFFF1F4F9),
        body: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: MyColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Create Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => _saveNoteDialog(context),
            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 26),
            tooltip: 'Save note',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveNoteDialog(context),
        backgroundColor: MyColors.primary,
        icon: const Icon(Icons.save_outlined, color: Colors.white),
        label: const Text('Save',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: QuillSimpleToolbar(
              controller: _controller!,
              config: const QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                showSubscript: false,
                showSuperscript: false,
                showInlineCode: false,
                showCodeBlock: false,
                showListCheck: false,
                showSearchButton: false,
                showDividers: false,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ],
                ),
                child: QuillEditor(
                  controller: _controller!,
                  scrollController: _editorScrollController,
                  focusNode: _editorFocusNode,
                  config: const QuillEditorConfig(
                    scrollable: true,
                    autoFocus: true,
                    expands: true,
                    placeholder: 'Write your note here...',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNoteDialog(BuildContext outerContext) {
    String name = "";
    final titleController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.savenotetitle,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: MyColors.textPrimary)),
        content: TextField(
          controller: titleController,
          autofocus: true,
          cursorColor: MyColors.primary,
          onChanged: (text) => name = text,
          decoration: InputDecoration(
            hintText: 'Note title',
            hintStyle:
                const TextStyle(color: MyColors.textDisabled),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: MyColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFe2e8f0)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel,
                style: const TextStyle(color: MyColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MyColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (name.isNotEmpty) {
                Provider.of<NotesProvider>(context, listen: false).saveNote(
                  Notes(
                    title: name,
                    color: Colors.primaries[
                        Random().nextInt(Colors.primaries.length)],
                    content:
                        jsonEncode(_controller!.document.toDelta().toJson()),
                    plaincontent: _controller!.document.toPlainText(),
                    date: DateTime.now().millisecondsSinceEpoch,
                  ),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(t.ok),
          ),
        ],
      ),
    ).then((_) {
      final saved = name.isNotEmpty;
      if (saved && mounted) Navigator.pop(outerContext);
    });
  }
}
