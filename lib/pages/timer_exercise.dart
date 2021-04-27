import 'package:app/components/backend.dart';
import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/circular_button.dart';
import 'package:app/components/dialog_button.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/exercise_model.dart';
import 'package:app/components/models/workout_model.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/pages/my_workouts_add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'package:http/http.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

enum WorkoutAction { PREPARE, WORK1, SWITCH, WORK2, REST }

class TimerExercisePage extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final int work;
  final int rest;
  final int rounds;
  TimerExercisePage({Key key, @required this.exercises, @required this.work, @required this.rest, @required this.rounds}) : super(key: key);

  @override
  _TimerExercisePagePageState createState() => _TimerExercisePagePageState();
}

class _TimerExercisePagePageState extends State<TimerExercisePage> {
  List<GlobalKey<ItemFaderState>> keys;
  VideoPlayerController _vcontroller;
  ExerciseModel _curExercise;
  int _curExIdx = 0;
  Timer _timer;
  int seconds = 0;
  int minutes = 0;

  int _work = 30;
  int _rest = 30;
  int _rounds = 3;
  int _lenOfExercises = 0;
  int _curRound = 1;
  bool _play = false;
  int _counter = 0;
  int _prepare = 10;

  int _totalTime = 0;
  bool videoLoaded = false;

  WorkoutAction _action = WorkoutAction.PREPARE;

  bool mounted = true;
  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  String guideText() {
    if (_action == WorkoutAction.PREPARE) {
      return "Get ready. Your workout is starting.";
    } else if (_action == WorkoutAction.WORK1) {
      return "Get ready. Your resting is starting.";
    } else if (_action == WorkoutAction.SWITCH) {
      return "Get ready. Switch arm or leg.";
    } else if (_action == WorkoutAction.WORK2) {
      return "Get ready. Your resting is starting.";
    }  else if (_action == WorkoutAction.REST) {
      if (_curRound >= _rounds) {
        if (_curExIdx < _lenOfExercises - 1)
          return "Next up: ${widget.exercises[_curExIdx+1].title}";
        else
          return "All exercises are completed.";
      } else {
        return "Get ready. Your next round is starting.";
      }
    }

    return "Unknown Status";
  }

  @override
  void initState() {
    super.initState();

    _work = widget.work;
    _rest = widget.rest;
    _rounds = widget.rounds;

    _lenOfExercises = widget.exercises.length;

    _totalTime = _prepare;
    _counter = _prepare - 1;

    int length = ( _prepare + ( _prepare + _work * 2 + _rest ) * _rounds ) * _lenOfExercises - 1;
    seconds = length % 60;
    minutes = length ~/ 60;


    keys = List.generate(4, (_) => GlobalKey<ItemFaderState>());


    _timer = new Timer.periodic(
      const Duration(seconds: 1), (Timer timer) => _play ? setState(
      () {
        seconds = seconds - 1;
        if (seconds < 0) {
          minutes -= 1;
          if (minutes < 0) {
            minutes = 0;
            seconds = 0;
            _play = false;
            if (_vcontroller != null && _vcontroller.value.isPlaying) {
              _vcontroller.pause();
            }
          } else {
            seconds = 59;
          }
        }

        _counter--;

        if (_action == WorkoutAction.PREPARE && _counter < 0) {
          _totalTime = _work;
          _counter = _work -1;
          _action = WorkoutAction.WORK1;
          _curRound = 1;
          return;
        } else if (_action == WorkoutAction.WORK1 && _counter < 0) {
          _totalTime = _prepare;
          _counter = _prepare - 1;
          _action = WorkoutAction.SWITCH;
          return;
        } else if (_action == WorkoutAction.SWITCH && _counter < 0) {
          _totalTime = _work;
          _counter = _work - 1;
          _action = WorkoutAction.WORK2;
          return;
        } else if (_action == WorkoutAction.WORK2 && _counter < 0) {
          _totalTime = _rest;
          _counter = _rest - 1;
          _action = WorkoutAction.REST;
          return;
        } else if (_action == WorkoutAction.REST && _counter < 0) { // REST
          if (_curRound >= _rounds) {
            if (_curExIdx < _lenOfExercises - 1) {
              _curRound = 1;
              _curExIdx++;
              _curExercise = widget.exercises[_curExIdx];
              _totalTime = _prepare;
              _counter = _prepare - 1;
              _action = WorkoutAction.PREPARE;
            } else {
              _totalTime = _counter = 0;
            }
          } else {
            _curRound++;
            _totalTime = _work;
            _counter = _work - 1;
            _action = WorkoutAction.WORK1;
          }

          return;
        }

      }) : 0);

    _curExercise = widget.exercises[0];

    if (_curExercise.file != null) {
      _vcontroller = VideoPlayerController.network(
          APIManager().getPath(_curExercise.file), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..initialize().then((_) {
          _vcontroller.setVolume(0.0);
          _vcontroller.setLooping(true);
          _vcontroller.play();
          setState(() {
            _play = true;
            videoLoaded = true;
          });
        });
    }

    Future.delayed(Duration(milliseconds: 50), () async {
      await showAll();
    });

    increaseView();
  }

  double getPercent () {
    if (_totalTime == 0 &&  _counter == 0) {
      return 1.0;
    }
    return (_totalTime - _counter) / _totalTime;
  }

  void increaseView() {
    APIManager().increaseView(_curExercise.id);
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

  _stop() {
    if (_vcontroller == null) {
      return;
    }

    setState(() {
      if (_vcontroller != null && _vcontroller.value.isPlaying) {
        _vcontroller.pause();
      }
      _play = false;
    });
  }

  fixNumber(val) {
    return val.toString().padLeft(2, '0');
  }

  void quit(BuildContext ctx) {
    _stop();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MySizeStyle.design(40, context)
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: MySizeStyle.design(20, context),
                      vertical: MySizeStyle.design(30, context),
                    ),
                    decoration: BoxDecoration(
                      color: MyColorStyle.whiteColor,
                      borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dictionary.quickWorkout,
                          textAlign: TextAlign.center,
                          style: MyTextStyle.titleDarkStyle(context),
                        ),
                        SizedBox(
                          height: MySizeStyle.design(5, context),
                        ),
                        Text(
                          dictionary.quickWorkoutContent,
                          textAlign: TextAlign.center,
                          style: MyTextStyle.textStyle(context),
                        ),
                        SizedBox(
                          height: MySizeStyle.design(20, context),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: DialogButton(text: dictionary.yes.toUpperCase(), color: MyColorStyle.primaryColor, onTap: () => { Navigator.of(context).pop(), Navigator.of(ctx).pop() })),
                            SizedBox(width: MySizeStyle.design(5, context)),
                            Expanded(child: DialogButton(text: dictionary.no.toUpperCase(), color: MyColorStyle.foreground, onTap: () => Navigator.of(context).pop()))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  nextExercise() async {
    if (videoLoaded && _curExIdx < _lenOfExercises - 1) {
      setState(() {
        int length = ( _prepare + ( _prepare + _work * 2 + _rest ) * _rounds ) * (_lenOfExercises - _curExIdx - 1) - 1;
        _curExIdx++;
        _curExercise = widget.exercises[_curExIdx];
        _action = WorkoutAction.PREPARE;
        _counter = _prepare - 1;
        _totalTime = _prepare;
        _curRound = 1;
        seconds = length % 60;
        minutes = length ~/ 60;
        _play = false;
        videoLoaded = false;


      });


      if (_curExercise.file != null) {
        await _vcontroller.pause();
        _vcontroller = VideoPlayerController.network(
            APIManager().getPath(_curExercise.file), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
          ..initialize().then((_) {
            _vcontroller.setVolume(0.0);
            _vcontroller.setLooping(true);
            _vcontroller.play();
            setState(() {
              _play = true;
              videoLoaded = true;
            });
          });
      }
    }

  }

  prevExercise() async {
    if (videoLoaded && _curExIdx > 0) {
      setState(() {
        int length = ( _prepare + ( _prepare + _work * 2 + _rest ) * _rounds ) * (_lenOfExercises - _curExIdx + 1) - 1;
        _curExIdx--;
        _curExercise = widget.exercises[_curExIdx];
        _action = WorkoutAction.PREPARE;
        _counter = _prepare - 1;
        _totalTime = _prepare;
        _curRound = 1;
        seconds = length % 60;
        minutes = length ~/ 60;
        _play = false;
        videoLoaded = false;


      });


      if (_curExercise.file != null) {
        await _vcontroller.pause();
        _vcontroller = VideoPlayerController.network(
            APIManager().getPath(_curExercise.file), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
          ..initialize().then((_) {
            _vcontroller.setVolume(0.0);
            _vcontroller.setLooping(true);
            _vcontroller.play();
            setState(() {
              _play = true;
              videoLoaded = true;
            });
          });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var videoHeight = 205;

    if (_curExercise.formatID == 2) {
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
                          child: _vcontroller != null &&
                              _vcontroller.value.initialized
                              ? LayoutBuilder(builder: (context, constraints) {
                            var width = MySizeStyle.fullWidth(context);
                            var height =
                            MySizeStyle.design(videoHeight, context);
                            var hi =
                                width / _vcontroller.value.aspectRatio;
                            var wd =
                                height * _vcontroller.value.aspectRatio;

                            if (hi < height) {
                              width = wd;
                            } else {
                              height = hi;
                            }

                            return Container(
                              width: MySizeStyle.fullWidth(context),
                              height: MySizeStyle.design(
                                  videoHeight, context),
                              child: SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                      width: width,
                                      height: height,
                                      child: VideoPlayer(
                                          _vcontroller)),
                                ),
                              ),
                            );
                          })
                              : Stack(
                            children: [
                              Container(
                                  width: MySizeStyle.fullWidth(context),
                                  height: MySizeStyle.design(
                                      videoHeight, context)),
                              _vcontroller != null
                                  ? Container(
                                width:
                                MySizeStyle.fullWidth(context),
                                height: MySizeStyle.design(
                                    videoHeight, context),
                                child: Center(
                                  child: LoadingWidget(),
                                ),
                              )
                                  : SizedBox()
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
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _curExercise.title,
                                      style: MyTextStyle.textStyle(context, color: Colors.black, size: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: MySizeStyle.design(10, context),),
                                    Text(
                                      guideText(),
                                      style: MyTextStyle.textStyle(context),
                                    ),
                                    SizedBox(height: MySizeStyle.design(20, context)),
                                    Stack(
                                      children: [
                                        SizedBox(
                                            width: MySizeStyle.design(80, context),
                                            height: MySizeStyle.design(80, context),
                                            child: CircularProgressIndicator(
                                                backgroundColor: Colors.black12,
                                                valueColor: new AlwaysStoppedAnimation<Color>(MyColorStyle.primaryColor),
                                                strokeWidth: MySizeStyle.design(6, context),
                                                value: getPercent()
                                            )
                                        ),
                                        SizedBox(
                                          width: MySizeStyle.design(80, context),
                                          height: MySizeStyle.design(80, context),
                                          child: Center(
                                            child: Text(
                                              _counter.toString().padLeft(2, "0"),
                                              style: MyTextStyle.textStyle(context, color: Colors.black, size: 40, sameWidth: true),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: MySizeStyle.design(20, context)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MyCircularButton(
                                          icon: Icon(Icons.skip_previous,
                                              size: MySizeStyle.design(25, context)),
                                          onTap: prevExercise,
                                          size: 50,
                                        ),
                                        MyCircularButton(
                                          icon: Icon( !videoLoaded ? Icons.access_time_sharp :( _play ? Icons.pause : Icons.play_arrow ),
                                              color: Colors.white,
                                              size: MySizeStyle.design(30, context)),
                                          onTap: videoLoaded ? _togglePlay : null,
                                          size: 60,
                                          color: _play ? Colors.black : Colors.orange,
                                        ),
                                        MyCircularButton(
                                          icon: Icon(Icons.skip_next,
                                              size: MySizeStyle.design(25, context)),
                                          onTap: nextExercise,
                                          size: 50,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(10, context),
                          ),
                          ItemFader(
                            key: keys[3],
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15)
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Work",
                                        style:
                                        MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                      ),
                                      Text(
                                        "${_work}s",
                                        style:
                                        MyTextStyle.textStyle(context, color: Colors.green, size: 17),
                                      )
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: MySizeStyle.design(15, context),
                                      horizontal:
                                      MySizeStyle.pageHorizontal(context)),
                                  margin: EdgeInsets.only(
                                      bottom: MySizeStyle.design(5, context),
                                      top: MySizeStyle.design(20, context),
                                      left: MySizeStyle.design(15, context),
                                      right: MySizeStyle.design(15, context)
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.15)
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rest",
                                        style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                      ),
                                      Text(
                                        "${_rest}s",
                                        style:
                                        MyTextStyle.textStyle(context, color: Colors.red, size: 17),
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
                                      color: Colors.blue.withOpacity(0.15)
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Rounds",
                                        style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                      ),
                                      Text(
                                        "${_curRound} of ${_rounds}",
                                        style:
                                        MyTextStyle.textStyle(context, color: Colors.blue, size: 17),
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
                                      color: Colors.orange.withOpacity(0.15)
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Exercises",
                                        style: MyTextStyle.textStyle(context, color: Colors.black, size: 17),
                                      ),
                                      Text(
                                        "${_curExIdx + 1} of ${_lenOfExercises}",
                                        style:
                                        MyTextStyle.textStyle(context, color: Colors.orange, size: 17),
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
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: MySizeStyle.design(10, context),
                          // ),
                          // ItemFader(
                          //   key: keys[4],
                          //   child: Padding(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal:
                          //         MySizeStyle.pageHorizontal(context)),
                          //     child: MyButton(
                          //       title: dictionary.addToMyWorkout,
                          //       onTap: () => {
                          //         Navigator.of(context).push(
                          //             Transition.createHomePageRoute(
                          //                 MyWorkoutsForAddPage(
                          //                     exercise: _curExercise)))
                          //       },
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                child: GestureDetector(
                  child: SizedBox(
                    height: MySizeStyle.design(50, context),
                    width: MySizeStyle.design(50, context),
                    child: Center(
                      child: Icon(
                        Bootybuilder.close,
                        size: MySizeStyle.design(18, context),
                        color: MyColorStyle.whiteColor,
                      ),
                    ),
                  ),
                  onTap: () => quit(context),
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
