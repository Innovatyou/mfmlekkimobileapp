import 'package:flutter/material.dart';
import 'package:higherground/bible/BibleSearchScreen.dart';
import 'package:higherground/bible/BibleVersionsScreen.dart';
import 'package:higherground/bible/BibleViewScreen.dart';
import 'package:higherground/providers/BibleModel.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:higherground/i18n/strings.g.dart';

class BibleScreen extends StatefulWidget {
  static const routeName = "/biblescreen";

  @override
  _BibleScreenState createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  @override
  Widget build(BuildContext context) {
    BibleModel bibleModel = Provider.of<BibleModel>(context);
    int bibleversionsize = bibleModel.downloadedBibleList.length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        title: Text(t.biblebooks),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              //color: MyColors.mainC0lor,
              onPressed: () {
                Navigator.of(context).pushNamed(BibleSearchScreen.routeName);
              },
              icon: Icon(Icons.search),
              iconSize: 25,
            ),
          )
        ],
      ),
      body: bibleversionsize == 0 ? EmptyLayout() : BibleViewScreen(),
    );
  }
}

class EmptyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(BibleVersionsScreen.routeName);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Lottie.asset("assets/lottie/bible.json",
                      height: 200, width: 200),
                ),
                Container(height: 0),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(t.nobibleversionshint,
                      textAlign: TextAlign.center,
                      style: TextStyles.medium(context).copyWith()),
                ),
                Container(height: 5),
                Container(
                  width: 180,
                  height: 40,
                  child: ElevatedButton(
                    child: Text(t.downloadbible,
                        style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: MyColors.mainC0lor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(BibleVersionsScreen.routeName);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



