import 'package:app/components/about_widget.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<GlobalKey<ItemFaderState>> keys;

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
    keys = List.generate(6, (_) => GlobalKey<ItemFaderState>());

    onInit();
  }

  void onInit() async {
    showAll();
  }

  void showAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.show();
      } else {
        break;
      }
    }
  }

  void hideAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.hide();
      } else {
        break;
      }
    }
  }

  Future _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: MySizeStyle.pageHorizontal(context),
            vertical: MySizeStyle.pageHorizontal(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemFader(
              key: keys[0],
              child: AboutWidget(
                image: "assets/images/web.jpg",
                onTap: () async =>
                    {await _launchURL('https://bootybuilder.com')},
              ),
            ),
            ItemFader(
              key: keys[1],
              child: AboutWidget(
                image: "assets/images/instagram.jpg",
                onTap: () async => {
                  await _launchURL(
                      'https://www.instagram.com/bootybuilder.official')
                },
              ),
            ),
            ItemFader(
              key: keys[2],
              child: AboutWidget(
                image: "assets/images/tiktok.jpg",
                onTap: () async =>
                    {await _launchURL('https://vm.tiktok.com/ZMJrh4FBP/')},
              ),
            ),
            ItemFader(
              key: keys[3],
              child: AboutWidget(
                image: "assets/images/spotify.jpg",
                onTap: () async => {
                  await _launchURL(
                      'https://open.spotify.com/playlist/5bijSvioWYWdFQRuQARVot?si=SmO2ulZASNqNltPUgwUZmQ')
                },
              ),
            ),
            ItemFader(
              key: keys[4],
              child: AboutWidget(
                image: "assets/images/youtube.jpg",
                onTap: () async => {
                  await _launchURL(
                      'https://www.youtube.com/channel/UCTbhhewrMyqhYmWaVPbzM0A')
                },
              ),
            ),
            ItemFader(
              key: keys[5],
              child: AboutWidget(
                image: "assets/images/facebook.jpg",
                onTap: () async =>
                {
                  if (Platform.isIOS) {
                    await _launchURL('fb://profile/577017302329049')
                  } else if (Platform.isAndroid) {
                    await _launchURL('fb://facewebmodal/f?href=https://www.facebook.com/BootyBuilder')
                  } else {
                    await _launchURL('https://www.facebook.com/BootyBuilder')
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
