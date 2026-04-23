import 'package:flutter/material.dart';
import 'package:higherground/utils/Alerts.dart';

class Toasts {
  static info(BuildContext context, String title, String message) {
    Alerts.showCupertinoAlert(context, title, message);
  }
}



