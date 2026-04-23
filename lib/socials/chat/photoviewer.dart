import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:higherground/models/ChatMessages.dart';
import 'dart:io';
import 'package:higherground/i18n/strings.g.dart';

class PhotoViewer extends StatelessWidget {
  static const routeName = "/chatphotoviewer";
  const PhotoViewer({Key? key, this.chatMessages}) : super(key: key);
  final ChatMessages? chatMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(t.photoviewer),
        ),
        body: Container(
            child: PhotoView(
                imageProvider: (chatMessages!.attachment != ""
                        ? NetworkImage(chatMessages!.attachment!)
                        : FileImage(
                            File.fromUri(Uri.parse(chatMessages!.uploadFile!))))
                    as ImageProvider<Object>?)));
  }
}



