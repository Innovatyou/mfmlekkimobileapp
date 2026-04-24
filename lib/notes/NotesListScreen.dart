import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/notes/NotesEditorScreen.dart';
import 'package:higherground/providers/NotesProvider.dart';
import 'package:higherground/utils/Alerts.dart';
import 'package:higherground/utils/TimUtil.dart';
import 'package:higherground/utils/my_colors.dart';
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
    setState(() {
      showClear = hasTerm;
    });
  }

  void _clearSearch() {
    inputController.clear();
    notesProvider!.getNotes();
    setState(() {
      showClear = false;
    });
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DCE3)),
      ),
      child: TextField(
        controller: inputController,
        keyboardType: TextInputType.text,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search notes',
          hintStyle: const TextStyle(
            color: Color(0xFF8A7D86),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF8A7D86),
          ),
          suffixIcon: showClear
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF8A7D86),
                  ),
                )
              : null,
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
          colors: [Color(0xFF7C355E), Color(0xFFA64878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
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
            child: const Icon(
              Icons.sticky_note_2_rounded,
              color: Colors.white,
            ),
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
                    color: Colors.white.withValues(alpha: 0.9),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9DEE5)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 44,
            color: Color(0xFF9C8D97),
          ),
          SizedBox(height: 12),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A1A24),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tap the + button to create your first note.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF7D7079),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notesProvider = Provider.of<NotesProvider>(context);
    List<Notes> items = notesProvider!.notesList;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F5),
      appBar: AppBar(
        title: Text(
          t.notes,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        return ItemTile(
                          object: items[index],
                          notesProvider: notesProvider,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        child: FloatingActionButton.extended(
          backgroundColor: MyColors.mainC0lor,
          onPressed: () {
            Navigator.of(context).pushNamed(NewNotesScreen.routeName);
          },
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            t.newnote,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        duration: const Duration(milliseconds: 120),
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
    final String noteText = _extractPlainText();

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(NotesEditorScreen.routeName,
            arguments: ScreenArguements(
              position: 0,
              items: object,
              itemsList: [],
            ));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8DEE5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4ECF8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    TimUtil.formatMilliSecondsFullDatestamp(object.date!),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A6B75),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  TimUtil.formatMilliSecondsFullDTime(object.date!),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D8089),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              object.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF2A1A24),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noteText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF6F616A),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                _ActionButton(
                  icon: Icons.share_rounded,
                  color: const Color(0xFF3A7BD5),
                  onTap: () async {
                    await Share.share(
                      noteText,
                      subject: object.title,
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.content_copy_rounded,
                  color: const Color(0xFFE58D17),
                  onTap: () {
                    FlutterClipboard.copy(noteText).then(
                      (value) => Alerts.show(context, '', t.copiedtoclipboard),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.delete_forever_rounded,
                  color: const Color(0xFFD64848),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(t.deletenote),
                        content: Text(t.deletenotehint),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              t.cancel,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              notesProvider!.deleteNote(object);
                              Navigator.of(context).pop();
                            },
                            child: Text(t.ok),
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
    );
  }

  String _extractPlainText() {
    if (object.content != null && object.content!.isNotEmpty) {
      try {
        return Document.fromJson(jsonDecode(object.content!)).toPlainText();
      } catch (_) {}
    }
    return Bidi.stripHtmlIfNeeded(object.plaincontent ?? '');
  }
}

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
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: color, size: 19),
        ),
      ),
    );
  }
}



