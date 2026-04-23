import 'package:flutter/widgets.dart';

class Items {
  final String? title;
  final String? description;
  final IconData? icon;
  final String? photo;
  int? position;

  Items(
    this.position, {
    this.title,
    this.description,
    this.icon,
    this.photo,
  });
}

