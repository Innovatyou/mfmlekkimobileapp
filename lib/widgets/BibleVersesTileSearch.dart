import 'package:flutter/material.dart';
import 'package:higherground/bible/BibleTranslator.dart';
import 'package:higherground/bible/BibleVerseCompare.dart';
// import 'package:higherground/providers/AppStateManager.dart'; // unused
import 'package:highlight_text/highlight_text.dart';
import 'package:provider/provider.dart';
import 'package:higherground/providers/BibleModel.dart';
import 'package:higherground/models/ScreenArguements.dart';
import 'package:higherground/models/Bible.dart';
import 'package:higherground/utils/TextStyles.dart';

class BibleVersesTileSearch extends StatefulWidget {
  final Bible object;
  final String query;

  const BibleVersesTileSearch({
    Key? key,
    required this.object,
    required this.query,
  }) : super(key: key);

  @override
  _BibleVersesTileState createState() => _BibleVersesTileState();
}

class _BibleVersesTileState extends State<BibleVersesTileSearch> {
  late Map<String, HighlightedWord> words;

  @override
  void initState() {
    super.initState();
    words = {
      widget.query: HighlightedWord(
        onTap: () {},
        textStyle: TextStyle(
            fontSize: Provider.of<BibleModel>(context, listen: false)
                .selectedFontSize
                .toDouble(),
            color: Colors.red),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    // AppStateManager appStateManager = Provider.of<AppStateManager>(context); // Unused
    BibleModel bibleModel = Provider.of<BibleModel>(context);
    int fontSize = bibleModel.selectedFontSize;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        title: TextHighlight(
          text: widget.object.book! +
              " " +
              widget.object.chapter.toString() +
              " vs" +
              widget.object.verse.toString() +
              ": \n" +
              widget.object.content!,
          words: words,
          matchCase: false,
          textStyle: TextStyle(
              fontSize: fontSize.toDouble(),
              color:  Colors.black),
        ),

        /*RichText(
          text: TextSpan(
              style: TextStyles.subhead(context).copyWith(
                  //color: MyColors.grey_80,
                  fontWeight: FontWeight.w500),
              children: <TextSpan>[
                TextSpan(
                  text: widget.object.book +
                      " " +
                      widget.object.chapter +
                      " vs" +
                      widget.object.verse +
                      ": ",
                  style: TextStyle(fontSize: fontSize.toDouble()),
                ),
                TextSpan(
                  text: widget.object.content,
                  style: TextStyle(fontSize: fontSize.toDouble()),
                )
              ]),
        ),*/
        subtitle: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Row(
            children: <Widget>[
              Spacer(),
              Visibility(
                visible: bibleModel.downloadedBibleList.length > 1,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BibleVerseCompare.routeName,
                        arguments: ScreenArguements(
                          position: 0,
                          items: widget.object,
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "compare",
                      style: TextStyles.caption(context).copyWith(fontSize: 15),
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, BibleTranslator.routeName,
                      arguments: ScreenArguements(
                        position: 0,
                        items: widget.object,
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "translate",
                    style: TextStyles.caption(context).copyWith(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



