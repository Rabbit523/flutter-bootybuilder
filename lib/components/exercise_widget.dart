import 'dart:async';
import 'package:app/components/backend.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:video_player/video_player.dart';
import 'loading_widget.dart';

class ExerciseWidget extends StatefulWidget {
  final String title;
  final String description;
  final String file;
  final String video;
  final String tag;

  final onTap;

  ExerciseWidget(
      {Key key,
      @required this.title,
      @required this.description,
      @required this.tag,
      @required this.file,
      this.video,
      this.onTap})
      : super(key: key);

  @override
  _ExerciseWidgetState createState() => _ExerciseWidgetState();
}

class _ExerciseWidgetState extends State<ExerciseWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  VideoPlayerController _vcontroller;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 1000),
      lowerBound: 0.0,
      upperBound: 0.02,
    )..addListener(() {
        setState(() {});
      });
  }

  void play() {
    if (_vcontroller == null) {
      if (widget.video != null) {
        _vcontroller =
            VideoPlayerController.network(APIManager().getPath(widget.video))
              ..initialize().then((_) {
                _vcontroller.setVolume(0.0);
                _vcontroller.setLooping(true);
                _vcontroller.play();
                setState(() {
                  isLoading = false;
                });
              });
        setState(() {
          isLoading = true;
        });
      }
      return;
    }
    if (_vcontroller.value.initialized) {
      setState(() {
        _vcontroller.play();
      });
    }
  }

  void pause() {
    if (_vcontroller == null) {
      return;
    }

    if (_vcontroller.value.initialized) {
      setState(() {
        _vcontroller.pause();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    if (_vcontroller != null) {
      _vcontroller.dispose();
      _vcontroller = null;
    }

    super.dispose();
  }

  _togglePlay() {
    if (_vcontroller != null && _vcontroller.value.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  @override
  Widget build(BuildContext context) {
    double _scale = 1 - _controller.value;
    const constHeight = 210;

    return GestureDetector(
      child: Transform.scale(
        scale: _scale,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: MyColorStyle.whiteColor, boxShadow: [
                BoxShadow(
                  color: MyColorStyle.secondaryColor.withOpacity(0.5),
                  spreadRadius: MySizeStyle.design(-12.0, context),
                  blurRadius: MySizeStyle.design(12.0, context),
                  offset: Offset(
                    0,
                    MySizeStyle.design(12.0, context),
                  ), // changes position of shadow
                ),
              ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    _vcontroller != null && _vcontroller.value.initialized
                        ? Container(
                        width: double.infinity,
                        height: MySizeStyle.design(constHeight, context),
                        child: Center(
                          child: AspectRatio(
                              aspectRatio: _vcontroller.value.aspectRatio,
                              child: VideoPlayer(_vcontroller)),
                        ))
                        : CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: MySizeStyle.design(constHeight, context),
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: MyColorStyle.secondaryColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                MyColorStyle.primaryColor),
                          ),
                        ),
                      ),
                      imageUrl: APIManager().getPath(widget.file),
                      imageBuilder: (context, imageProvider) => Container(
                        width: double.infinity,
                        height: MySizeStyle.design(constHeight, context),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                          "assets/images/placeholder.jpg",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: MySizeStyle.design(constHeight, context)),
                    ),
                    Container(
                      width: double.infinity,
                      height: MySizeStyle.design(constHeight, context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoading
                              ? LoadingWidget()
                              : GestureDetector(
                            onTap: _togglePlay,
                            child: Container(
                              height: MySizeStyle.design(50, context),
                              width: MySizeStyle.design(50, context),
                              decoration: BoxDecoration(
                                  color: MyColorStyle.whiteColor
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          MySizeStyle.design(25, context))),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MyColorStyle.secondaryColor
                                          .withOpacity(0.5),
                                      spreadRadius:
                                      MySizeStyle.design(-12.0, context),
                                      blurRadius:
                                      MySizeStyle.design(12.0, context),
                                      offset: Offset(
                                        0,
                                        MySizeStyle.design(12.0, context),
                                      ), // changes position of shadow
                                    ),
                                  ]),
                              child: Icon(
                                _vcontroller != null &&
                                    _vcontroller.value.isPlaying
                                    ? Icons.stop
                                    : Icons.play_arrow,
                                size: MySizeStyle.design(30, context),
                                color: MyColorStyle.primaryColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ]),
                  SizedBox(
                    height: MySizeStyle.design(10, context),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: MySizeStyle.design(10, context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.widget.title,
                          style: MyTextStyle.tagBoldStyle(context),
                        ),
                        Text(
                          widget.tag,
                          style: MyTextStyle.smallTagStyle(context),
                        ),
                        SizedBox(
                          height: MySizeStyle.design(10, context),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(child: SizedBox())
          ],
        ),
      ),
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
    );
  }

  void onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void onTapCancel() async {
    _controller.reverse();
  }

  void onTapUp(TapUpDetails details) async {
    _controller.reverse();

    if (this.widget.onTap != null) {
      await Future.delayed(Duration(milliseconds: 200));
      this.widget.onTap();
    }
  }
}
