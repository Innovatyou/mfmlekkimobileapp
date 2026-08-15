import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/utils/my_colors.dart';

typedef DemoContentBuilder = Widget Function(
    BuildContext context, QuillController? controller);

class NoteScaffold extends StatefulWidget {
  const NoteScaffold({
    this.content,
    this.builder,
    this.actions,
    this.showToolbar = true,
    this.floatingActionButton,
    Key? key,
  }) : super(key: key);

  final String? content;
  final DemoContentBuilder? builder;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showToolbar;

  @override
  _DemoScaffoldState createState() => _DemoScaffoldState();
}

class _DemoScaffoldState extends State<NoteScaffold> {
  QuillController? _controller;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !_loading) {
      _loading = true;
      _loadFromAssets();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadFromAssets() async {
    try {
      final doc = Document.fromJson(jsonDecode(widget.content!));
      setState(() {
        _controller = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0));
        _loading = false;
      });
    } catch (_) {
      final doc = Document()..insert(0, '');
      setState(() {
        _controller = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0));
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions ?? <Widget>[];
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
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
        title: Text(
          t.notes,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: actions,
      ),
      floatingActionButton: widget.floatingActionButton,
      body: Column(
        children: [
          if (widget.showToolbar && !_loading && _controller != null)
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
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: MyColors.primary))
                : widget.builder!(context, _controller),
          ),
        ],
      ),
    );
  }
}
