import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/notes/NotesEditorScreen.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/utils/my_colors.dart';
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
  final TextEditingController inputController = TextEditingController();

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
  void dispose() {
    controller?.dispose();
    inputController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String term) {
    final hasTerm = term.trim().isNotEmpty;
    if (hasTerm) {
      notesProvider!.searchNotes(term);
    } else {
      notesProvider!.getNotes();
    }
    setState(() => showClear = hasTerm);
  }

  void _clearSearch() {
    inputController.clear();
    notesProvider!.getNotes();
    setState(() => showClear = false);
  }

  @override
  Widget build(BuildContext context) {
    notesProvider = Provider.of<NotesProvider>(context);
    final List<Notes> items = notesProvider!.notesList;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        title: Text(
          t.notes,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: MyColors.navBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            _buildHeader(items.length),
            const SizedBox(height: 12),
            _buildSearchInput(),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      controller: controller,
                      itemCount: items.length,
                      padding: const EdgeInsets.only(bottom: 90),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) => ItemTile(
                        object: items[index],
                        notesProvider: notesProvider,
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: fabIsVisible ? 1 : 0,
        child: FloatingActionButton.extended(
          backgroundColor: MyColors.primary,
          onPressed: () =>
              Navigator.of(context).pushNamed(NewNotesScreen.routeName),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            t.newnote,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: inputController,
        keyboardType: TextInputType.text,
        onChanged: _onSearchChanged,
        cursorColor: MyColors.primary,
        style: const TextStyle(
          color: MyColors.textBody,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search notes',
          hintStyle: const TextStyle(
            color: MyColors.textDisabled,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: MyColors.textDisabled,
            size: 20,
          ),
          suffixIcon: showClear
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: MyColors.textDisabled,
                    size: 20,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4f46e5), Color(0xFF6366f1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sticky_note_2_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total saved note${total == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFe2e8f0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.edit_note_rounded, size: 48, color: MyColors.textDisabled),
          SizedBox(height: 12),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MyColors.textBody,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap the + button to create your first note.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: MyColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Note tile
// ─────────────────────────────────────────────────────────────────────────────

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
    final String noteText = _extractPlainText();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          NotesEditorScreen.routeName,
          arguments: ScreenArguements(
            position: 0,
            items: object,
            itemsList: [],
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFe2e8f0)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: MyColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      TimUtil.formatMilliSecondsFullDatestamp(object.date!),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MyColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    TimUtil.formatMilliSecondsFullDTime(object.date!),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: MyColors.textDisabled,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                object.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: MyColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              // Preview
              Text(
                noteText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13.5,
                  color: MyColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.share_rounded,
                    color: MyColors.success,
                    onTap: () async => Share.share(noteText, subject: object.title),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.content_copy_rounded,
                    color: MyColors.accent,
                    onTap: () => FlutterClipboard.copy(noteText).then(
                      (_) => Alerts.show(context, '', t.copiedtoclipboard),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: MyColors.danger,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.deletenote,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: MyColors.textPrimary)),
        content: Text(t.deletenotehint,
            style: const TextStyle(color: MyColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel,
                style: const TextStyle(color: MyColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MyColors.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              notesProvider!.deleteNote(object);
              Navigator.of(ctx).pop();
            },
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  String _extractPlainText() {
    if (object.content != null && object.content!.isNotEmpty) {
      try {
        return Document.fromJson(jsonDecode(object.content!)).toPlainText();
      } catch (_) {}
    }
    return object.plaincontent ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
