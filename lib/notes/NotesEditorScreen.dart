import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:provider/provider.dart';

class NotesEditorScreen extends StatefulWidget {
  static const routeName = "/noteditor";
  const NotesEditorScreen({Key? key, this.notes}) : super(key: key);
  final Notes? notes;

  @override
  _NotesEditorPageState createState() => _NotesEditorPageState();
}

class _NotesEditorPageState extends State<NotesEditorScreen> {
  QuillController? _controller;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _edit = false;

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
    Document doc;
    try {
      doc = Document.fromJson(jsonDecode(widget.notes?.content ?? '[]'));
    } catch (_) {
      doc = Document()..insert(0, '');
    }
    setState(() {
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    });
  }

  void _toggleEdit() {
    if (_edit) {
      _triggerSave();
    } else {
      setState(() {
        _edit = true;
        _controller!.readOnly = false;
      });
    }
  }

  void _triggerSave() {
    String name = widget.notes?.title ?? '';
    final titleController = TextEditingController(text: name);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            hintStyle: const TextStyle(color: MyColors.textDisabled),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: MyColors.primary),
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
                    content: jsonEncode(
                        _controller!.document.toDelta().toJson()),
                    plaincontent: _controller!.document.toPlainText(),
                    date: widget.notes!.date,
                    id: widget.notes!.id,
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
      if (mounted) setState(() {
        _edit = false;
        _controller!.readOnly = true;
      });
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
        title: Text(
          t.notes,
          style: const TextStyle(
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: _edit
            ? [
                IconButton(
                  icon: const Icon(Icons.save_rounded,
                      color: Colors.white, size: 26),
                  tooltip: 'Save note',
                  onPressed: _triggerSave,
                ),
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _edit ? MyColors.success : MyColors.primary,
        onPressed: _toggleEdit,
        child: Icon(
          _edit ? Icons.check_rounded : Icons.edit_rounded,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Toolbar stays in the tree (maintainState: true) to avoid
          // InheritedElement._dependents assertion when toggling edit mode.
          Visibility(
            visible: _edit,
            maintainState: true,
            child: Container(
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 10,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: QuillEditor(
                    controller: _controller!,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: const QuillEditorConfig(
                      scrollable: true,
                      expands: true,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
