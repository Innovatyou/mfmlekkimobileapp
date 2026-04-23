import 'package:flutter/material.dart';
import 'package:higherground/models/Books.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BooksViewerScreen extends StatefulWidget {
  static const routeName = "/BooksViewerScreen";
  final Books? books;
  BooksViewerScreen({this.books});

  @override
  State<BooksViewerScreen> createState() => _BooksViewerScreenState();
}

class _BooksViewerScreenState extends State<BooksViewerScreen> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.books!.title!),
        ),
        body: SfPdfViewer.network(
          widget.books!.link!,
          key: _pdfViewerKey,
          scrollDirection: PdfScrollDirection.horizontal,
        ));
  }
}



