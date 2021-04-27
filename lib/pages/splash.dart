import 'package:app/components/mybutton.dart';
import 'package:app/pages/home.dart';
import 'package:app/services/transition.dart';
import 'package:app/components/item_fader.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController _controller;

  List<GlobalKey<ItemFaderState>> keys;

  bool mounted = true;
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    keys = List.generate(2, (_) => GlobalKey<ItemFaderState>());

    _controller = VideoPlayerController.asset('assets/videos/intro.mp4', videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        _controller.setVolume(0.0);
        _controller.setLooping(true);
        _controller.play();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        onInit();
      });
  }

  void onInit() async {
    await Future.delayed(Duration(milliseconds: 2000));
    showAll();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller.value.initialized
            ? LayoutBuilder(builder: (context, constraints) {
                var width = constraints.maxWidth;
                var height = constraints.maxHeight;
                var hi = width / _controller.value.aspectRatio;
                var wd = height * _controller.value.aspectRatio;

                if (hi < height) {
                  width = wd;
                } else {
                  height = hi;
                }

                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                        width: width,
                        height: height,
                        child: VideoPlayer(_controller)),
                  ),
                );
              })
            : Container(
                color: Colors.black,
              ),
        Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Spacer(),
              ItemFader(
                key: keys[0],
                child: MyButton(
                  title: "Get Started",
                  onTap: hideAll,
                  opacity: 0.8,
                ),
              ),
              SizedBox(height: 30),
              ItemFader(
                  key: keys[1],
                  child: Image.asset("assets/images/bb-logo-white.png",
                      height: 20))
            ],
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    mounted = false;

    _controller?.pause()?.then((_) {
      _controller.dispose();
    });
    super.dispose();
  }

  void showAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      key.currentState.show();
    }
  }

  void hideAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      key.currentState.hide();
    }
    await Future.delayed(Duration(milliseconds: 500));
    _controller.pause();

    Navigator.of(context)
        .pushReplacement(Transition.createHomePageRoute(HomePage()));
  }
}
