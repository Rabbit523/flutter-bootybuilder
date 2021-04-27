import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/pages/about.dart';
import 'package:app/pages/categories.dart';
import 'package:app/pages/my_workouts.dart';
import 'package:app/pages/workouts.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var curPageIndex;
  var pages;

  bool mounted = true;
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    curPageIndex = 0;

    pages = [
      CategoriesPage(),
      WorkoutsPage(),
      MyWorkoutsPage(),
      null,
      AboutPage()
    ];
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceWebView: true, forceSafariVC: true, enableJavaScript: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Bootybuilder.categories), label: "Exercises"),
            BottomNavigationBarItem(
                icon: Icon(Bootybuilder.workouts), label: "Workouts"),
            BottomNavigationBarItem(
                icon: Icon(Bootybuilder.myworkout), label: "My Workouts"),
            BottomNavigationBarItem(
                icon: Icon(Bootybuilder.order), label: "Shop"),
            BottomNavigationBarItem(
                icon: Icon(Bootybuilder.about), label: "About")
          ],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0.0,
          iconSize: 24,
          currentIndex: curPageIndex,
          selectedFontSize: 10.0,
          unselectedFontSize: 10.0,
          selectedItemColor: MyColorStyle.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontFamily: "Visbyround",
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: "Visbyround",
          ),
          onTap: (index) async {
            //Handle button tap
            if (index == 3) {
              await _launchURL('https://bootybuilder.com/shop');
            } else {
              setState(() => {curPageIndex = index});
            }
          },
        ),
        body: SafeArea(
            child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: MyColorStyle.background),
                  child: pages[curPageIndex],
                ),
              ),
              Container(
                height: MySizeStyle.design(40, context),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    vertical: MySizeStyle.design(10, context)),
                decoration: BoxDecoration(
                    color: MyColorStyle.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: MyColorStyle.foreground.withOpacity(0.5),
                        spreadRadius: MySizeStyle.design(-12.0, context),
                        blurRadius: MySizeStyle.design(12.0, context),
                        offset: Offset(
                          0,
                          -MySizeStyle.design(12.0, context),
                        ), // changes position of shadow
                      ),
                    ],
                    border: Border(
                        bottom: BorderSide(
                            width: 1, color: MyColorStyle.background))),
                child: Center(
                  child: Image.asset("assets/images/bb-logo-black.png"),
                ),
              )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.,
            ));
  }
}
