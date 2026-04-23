import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/models/Onboarder.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/InitPage.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  static const routeName = "/onboarding";
  OnboardingPage();

  @override
  OnboarderPageState createState() => OnboarderPageState();
}

class OnboarderPageState extends State<OnboardingPage> {
  List<Onboarder> onboarderItem = Onboarder.getOnboardingItems(
      t.onboardingpagetitles, t.onboardingpagehints);
  PageController pageController = PageController(
    initialPage: 0,
  );
  int page = 0;
  bool isLast = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(color: Colors.grey[100])),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 10,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: MyColors.grey_40),
                onPressed: () {
                  Provider.of<AppStateManager>(context, listen: false)
                      .setUserSeenOnboardingPage(true);
                  Navigator.of(context)
                      .pushReplacementNamed(InitPage.routeName);
                },
              ),
              Container(
                width: 0,
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                PageView(
                  onPageChanged: onPageViewChange,
                  controller: pageController,
                  children: buildPageViewItem(),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 60,
            child: Row(
              children: [
                Container(
                  width: 15,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    //color: Colors.red,
                    //height: 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: buildDots(context),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isLast
                        ? LineAwesomeIcons.check
                        : Icons.keyboard_arrow_right,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.mainC0lor,
                  ),
                  onPressed: () {
                    if (isLast) {
                      Provider.of<AppStateManager>(context, listen: false)
                          .setUserSeenOnboardingPage(true);
                      Navigator.of(context)
                          .pushReplacementNamed(InitPage.routeName);
                      //Navigator.of(context).pop();
                      return;
                    }
                    pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  },
                ),
                Container(
                  width: 12,
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }

  void onPageViewChange(int _page) {
    page = _page;
    isLast = _page == onboarderItem.length - 1;
    setState(() {});
  }

  List<Widget> buildPageViewItem() {
    List<Widget> widgets = [];
    for (Onboarder onboarder in onboarderItem) {
      Widget wg = Container(
        padding: EdgeInsets.only(left: 12, right: 12),
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: Wrap(
          children: <Widget>[
            Container(
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(onboarder.title,
                            style: TextStyles.medium(context).copyWith(
                                color: MyColors.grey_80,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        Container(
                          width: 120,
                          height: 2,
                          color: MyColors.mainC0lor,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 14, bottom: 14),
                          child: Image.asset(
                            onboarder.image,
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 25),
                          child: Text(onboarder.hint,
                              textAlign: TextAlign.center,
                              style: TextStyles.subhead(context).copyWith(
                                  color: MyColors.grey_60, fontSize: 16)),
                        ),
                      ],
                    )
                  ],
                ))
          ],
        ),
      );
      widgets.add(wg);
    }
    return widgets;
  }

  Widget buildDots(BuildContext context) {
    Widget widget;

    List<Widget> dots = [];
    for (int i = 0; i < onboarderItem.length; i++) {
      Widget w = Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        height: 30,
        width: 3,
        color: page == i ? MyColors.mainC0lor : MyColors.grey_20,
      );
      dots.add(w);
    }
    widget = Row(
      mainAxisSize: MainAxisSize.min,
      children: dots,
    );
    return widget;
  }
}



