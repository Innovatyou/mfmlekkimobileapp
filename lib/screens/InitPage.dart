import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/DashboardModel.dart';
import 'package:higherground/utils/TextStyles.dart';
import 'package:higherground/utils/my_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class InitPage extends StatefulWidget {
  static const routeName = "/InitPage";
  InitPage();

  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  late DashboardModel dashboardModel;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      Provider.of<DashboardModel>(context, listen: false).setContext(context);
      Provider.of<DashboardModel>(context, listen: false).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    dashboardModel = Provider.of<DashboardModel>(context);
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(color: Colors.grey[100])),
        body: dashboardModel.isError ? getErrorView() : getLoaderView()
        //  : getSuccessView(),
        );
  }

  Widget getSuccessView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(35),
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
                              Text("",
                                  style: TextStyles.medium(context).copyWith(
                                      color: MyColors.grey_80,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23)),
                              Container(
                                width: 120,
                                height: 2,
                                // color: MyColors.primary,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 14, bottom: 14),
                                child: Lottie.asset(
                                  "assets/lottie/success.json",
                                  width: 250,
                                  height: 250,
                                ), //Image.asset(Img.get(onboarder.image),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 25),
                                child: Text(t.initappsucess,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ),
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getLoaderView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(35),
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
                              Text("",
                                  style: TextStyles.medium(context).copyWith(
                                      color: MyColors.grey_80,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23)),
                              Container(
                                width: 120,
                                height: 2,
                                // color: MyColors.primary,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 14, bottom: 14),
                                child: Lottie.asset(
                                  "assets/lottie/loader.json",
                                  width: 250,
                                  height: 250,
                                ), //Image.asset(Img.get(onboarder.image),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 25),
                                child: Text(t.initializingapp,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ),
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getErrorView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(35),
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
                              Text("",
                                  style: TextStyles.medium(context).copyWith(
                                      color: MyColors.grey_80,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 23)),
                              Container(
                                width: 120,
                                height: 2,
                                // color: MyColors.primary,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 14, bottom: 14),
                                child: Lottie.asset(
                                  "assets/lottie/error.json",
                                  width: 250,
                                  height: 250,
                                ), //Image.asset(Img.get(onboarder.image),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 25),
                                child: Text(t.errorinitapp,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16)),
                              ),
                            ],
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.mainC0lor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
              ),
              child: Text(t.retry,
                  style: TextStyles.subhead(context).copyWith(
                      color: MyColors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                dashboardModel.loadItems();
              },
            ),
          )
        ],
      ),
    );
  }
}



