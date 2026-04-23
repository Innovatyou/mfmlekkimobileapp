import 'package:flutter/foundation.dart';
import 'package:higherground/models/Notes.dart';
import 'package:higherground/database/SQLiteDbProvider.dart';

class NotesProvider with ChangeNotifier {
  List<Notes> notesList = [];

  NotesProvider() {
    getNotes();
  }

  getNotes() async {
    notesList = await SQLiteDbProvider.db.getAllNotes();
    notifyListeners();
  }

  saveNote(Notes notes) async {
    await SQLiteDbProvider.db.saveNote(notes);
    getNotes();
  }

  deleteNote(Notes notes) async {
    await SQLiteDbProvider.db.deleteNote(notes.id);
    getNotes();
  }

  searchNotes(String term) {
    List<Notes> _items = notesList.where((notes) {
      return notes.title!.toLowerCase().contains(term.toLowerCase()) ||
          notes.content!.toLowerCase().contains(term.toLowerCase());
    }).toList();
    notesList = _items;
    notifyListeners();
  }
}


