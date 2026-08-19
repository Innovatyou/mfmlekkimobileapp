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
        backgroundColor: const Color(0xFFF7F2F5),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F2F5),
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.books!.title!,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0f172a),
            ),
          ),
        ),
        body: SfPdfViewer.network(
          widget.books!.link!,
          key: _pdfViewerKey,
          scrollDirection: PdfScrollDirection.horizontal,
        ));
  }
}



