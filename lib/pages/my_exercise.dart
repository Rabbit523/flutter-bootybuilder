import 'dart:async';

import 'package:app/components/alert_helper.dart';
import 'package:app/components/backend.dart';
import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/exercise_model.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/components/repository.dart';
import 'package:app/pages/my_workouts_add.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'package:video_player/video_player.dart';

class MyExercisePage extends StatefulWidget {
  final ExerciseModel exercise;
  MyExercisePage({Key key, @required this.exercise}) : super(key: key);

  @override
  _MyExercisePageState createState() => _MyExercisePageState();
}

class _MyExercisePageState extends State<MyExercisePage> {

  List<GlobalKey<ItemFaderState>> keys;
  VideoPlayerController _vcontroller;

  Timer _timer;
  int seconds = 0;
  int minutes = 0;
  bool _play = false;

  void timeReset() {
    int length = widget.exercise.videoLength - 1;
    seconds = length % 60;
    minutes = length ~/ 60;
  }

  @override
  void initState() {
    super.initState();
    keys = List.generate(5, (_) => GlobalKey<ItemFaderState>());

    timeReset();

    _timer = new Timer.periodic(
        const Duration(seconds: 1), (Timer timer) => _play ? setState(
            () {
          seconds = seconds - 1;
          if (seconds < 0) {
            minutes -= 1;
            if (minutes < 0) {
              timeReset();
            } else {
              seconds = 59;
            }
          }

        }) : 0);

    if (widget.exercise.file != null) {
      _vcontroller = VideoPlayerController.network(APIManager().getPath(widget.exercise.file), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..initialize().then((_) {
          _vcontroller.setVolume(0.0);
          _vcontroller.play();
          setState(() {
            _play = true;
          });
        });
    }


    Future.delayed(Duration(milliseconds: 50), () async {
      await showAll();
    });
  }

  void play() {
    if (_vcontroller == null) {
      return;
    }
    if (_vcontroller.value.initialized) {
      _vcontroller.play();
    }
  }

  void pause() {
    if (_vcontroller == null) {
      return;
    }
    if (_vcontroller.value.initialized) {
      _vcontroller.pause();
    }
  }

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

    _vcontroller?.pause()?.then((_) {
      _vcontroller.dispose();
    });

    _timer?.cancel();

    super.dispose();
  }

  Future showAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.show();
      }
    }
  }

  Future hideAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.hide();
      }
    }
  }

  Future onDelete(id, workout) {
    AlertHelper(
        type: AlertType.delConfirm,
        title: "Are you sure?",
        message: "Do you really want to to delete this workout? This process cannot be undone.",
        confirmFn: () => _onDelete(id, workout)
    ).alertDialog(context);
  }

  Future _onDelete(id, workout) async {
    await Repository().open();
    var db = Repository().db;
    if (db != null) {
      await ExerciseModel.delete(db, id, workout);
    }
    await Repository().close();
    Navigator.of(context).pop("Removed");
  }

  _togglePlay() {
    setState(() {
      _play = !_play;
      if (_vcontroller != null) {
        if (_play && !_vcontroller.value.isPlaying) {
          _vcontroller.play();
        } else {
          _vcontroller.pause();
        }
      }
    });
  }

  fixNumber(val) {
    return val.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    var videoHeight = 205;

    if(widget.exercise.formatID == 2) {
      videoHeight = 456;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(
                    bottom: MySizeStyle.pageVertical(context)),
                child: Column(

                  children: [
                    Stack(
                      children: [
                        ItemFader(
                          key: keys[0],
                          child: _vcontroller != null && _vcontroller.value.initialized ? LayoutBuilder(builder: (context, constraints) {
                            var width = MySizeStyle.fullWidth(context);
                            var height = MySizeStyle.design(videoHeight, context);
                            var hi = width / _vcontroller.value.aspectRatio;
                            var wd = height * _vcontroller.value.aspectRatio;

                            if (hi < height) {
                              width = wd;
                            } else {
                              height = hi;
                            }

                            return GestureDetector(
                              onTap: _togglePlay,
                              child: Stack(
                                children: [
                                  Container(
                                    width: MySizeStyle.fullWidth(context),
                                    height: MySizeStyle.design(videoHeight, context),
                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                            width: width,
                                            height: height,
                                            child: VideoPlayer(_vcontroller)),
                                      ),
                                    ),
                                  ),
                                  _vcontroller.value.isPlaying ? SizedBox() : Container(
                                      width: MySizeStyle.fullWidth(context),
                                      height: MySizeStyle.design(videoHeight, context),
                                      child: Center(
                                        child: Container(
                                          height: MySizeStyle.design(50, context),
                                          width: MySizeStyle.design(50, context),
                                          decoration: BoxDecoration(
                                              color: MyColorStyle.whiteColor.withOpacity(0.7),
                                              borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(25, context))),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: MyColorStyle.secondaryColor,
                                                  spreadRadius: MySizeStyle.design(-12.0, context),
                                                  blurRadius: MySizeStyle.design(12.0, context),
                                                  offset: Offset(0, MySizeStyle.design(12.0, context),), // changes position of shadow
                                                ),
                                              ]
                                          ),
                                          child: Icon(Icons.play_arrow, size: MySizeStyle.design(30, context), color: MyColorStyle.primaryColor,),
                                        ),
                                      )
                                  )
                                ],
                              ),
                            );
                          }) : Stack(
                            children: [
                              Container(
                                  width: MySizeStyle.fullWidth(context),
                                  height: MySizeStyle.design(videoHeight, context)
                              ),
                              _vcontroller != null ? Container(
                                  width: MySizeStyle.fullWidth(context),
                                  height: MySizeStyle.design(videoHeight, context),
                                   child: Center(
                                    child: LoadingWidget(),
                                  ),
                              ): SizedBox()
                            ],
                          ),
                        ),
                        Positioned(
                          right: MySizeStyle.design(10, context),
                          bottom: MySizeStyle.design(10, context),
                          child: ItemFader(
                            key: keys[1],
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: MySizeStyle.design(10, context)
                              ),
                              decoration: BoxDecoration(
                                  color: MyColorStyle.whiteColor,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          MySizeStyle.design(25, context))),
                                  boxShadow: [
                                    BoxShadow(
                                      color: MyColorStyle.secondaryColor,
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
                              child: Text(
                                  "${fixNumber(minutes)}:${fixNumber(seconds)}",
                                  style: MyTextStyle.textStyle(
                                      context, color: Colors.black, size: 20, sameWidth: true)),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: MySizeStyle.design(30, context),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ItemFader(
                            key: keys[2],
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                  MySizeStyle.pageHorizontal(context)),
                              child: Center(
                                child: Text(
                                  widget.exercise.title,
                                  style: MyTextStyle.textStyle(context, color: Colors.black, size: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(30, context),
                          ),
                        ItemFader(
                          key: keys[3],
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Series",
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    ),
                                    Text(
                                      widget.exercise.series.toString(),
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: MySizeStyle.design(15, context),
                                    horizontal:
                                    MySizeStyle.pageHorizontal(context)),
                                margin: EdgeInsets.only(
                                    bottom: MySizeStyle.design(5, context),
                                    left: MySizeStyle.design(15, context),
                                    right: MySizeStyle.design(15, context)
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Repetitions",
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    ),
                                    Text(
                                      widget.exercise.repetitions.toString(),
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: MySizeStyle.design(15, context),
                                    horizontal:
                                    MySizeStyle.pageHorizontal(context)),
                                margin: EdgeInsets.only(
                                    bottom: MySizeStyle.design(5, context),
                                    left: MySizeStyle.design(15, context),
                                    right: MySizeStyle.design(15, context)
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Time",
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    ),
                                    Text(
                                      widget.exercise.videoLength.toString()+"s",
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                    )
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: MySizeStyle.design(15, context),
                                    horizontal:
                                    MySizeStyle.pageHorizontal(context)),
                                margin: EdgeInsets.only(
                                    left: MySizeStyle.design(15, context),
                                    right: MySizeStyle.design(15, context)
                                ),
                              ),
                            ],
                          ),
                        ),
                          SizedBox(
                            height: MySizeStyle.design(20, context),
                          ),
                          ItemFader(
                            key: keys[4],
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: MySizeStyle.pageHorizontal(context)
                              ),
                              child: MyButton(
                                title: dictionary.removeFromWorkout,
                                onTap: () async => {
                                  await onDelete(widget.exercise.id, widget.exercise.workoutId)
                                },
                              )
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                child: GestureDetector(
                  child: Container(
                    height: MySizeStyle.design(50, context),
                    width: MySizeStyle.design(50, context),
                    child: Center(
                      child: Icon(
                        Bootybuilder.close,
                        size: MySizeStyle.design(18, context),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () => {
                    Navigator.of(context).pop()
                  },
                ),
                right: MySizeStyle.design(10, context),
                top: 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}