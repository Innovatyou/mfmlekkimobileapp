import 'package:flutter/material.dart';
import 'dart:math';

class Notes {
  final int? id;
  final Color? color;
  final String? title, content, plaincontent;
  final int? date;

  Notes({this.id, this.title, this.content, this.plaincontent,  this.date, this.color});

  static const String TABLE = "notes";
  static final tableColumns = ["id", "title", "content", "plaincontent", "date"];

  factory Notes.fromMap(Map<String, dynamic> data) {
    return Notes(
        id: data['id'],
        title: data['title'],
        content: data['content'],
        date: data['date'],
        plaincontent: data['plaincontent'],
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "content": content,
        "plaincontent":plaincontent,
        "date": date,
        "color": color
      };
}

