import 'dart:async';

import 'package:app/components/alert_helper.dart';
import 'package:app/components/dialog_button.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/exercise_widget.dart';
import 'package:app/components/item_zoom.dart';
import 'package:app/components/models/my_workout_model.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/components/myedittext.dart';
import 'package:app/pages/timer_exercise.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'package:app/pages/home.dart';
import 'my_exercise.dart';

class MyExercisesPage extends StatefulWidget {
  final MyWorkoutModel workout;
  MyExercisesPage({Key key, @required this.workout}) : super(key: key);

  @override
  _MyExercisesPageState createState() => _MyExercisesPageState();
}

class _MyExercisesPageState extends State<MyExercisesPage> {
  Timer _timer;
  int _start = 0;

  var work = 30;
  var rest = 30;
  var rounds = 3;

  GlobalKey<ItemZoomState> timerKey = new GlobalKey<ItemZoomState>();
  GlobalKey<ItemFaderState> timerBKKey = new GlobalKey<ItemFaderState>();

  static var hasError;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _workInput = MyEditText(
      placeholder: "30",
      text: "seconds",
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value.isEmpty) {
          hasError = true;
          return null;
        } else {
          int val = -1;
          try {
            val = int.parse(value.toString());
          } catch (e) {}
          if (val < 1) {
            hasError = true;
            return null;
          }
        }
        return null;
      },
      isSettingWorkout: true,
      textController: TextEditingController());

  final _restInput = MyEditText(
      placeholder: "30",
      text: "seconds",
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value.isEmpty) {
          hasError = true;
          return null;
        } else {
          int val = -1;
          try {
            val = int.parse(value.toString());
          } catch (e) {}
          if (val < 1) {
            hasError = true;
            return null;
          }
        }
        return null;
      },
      isSettingWorkout: true,
      textController: TextEditingController());

  final _roundsInput = MyEditText(
      placeholder: "3 ",
      text: "rounds",
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value.isEmpty) {
          hasError = true;
          return null;
        } else {
          int val = -1;
          try {
            val = int.parse(value.toString());
          } catch (e) {}

          if (val < 1) {
            hasError = true;
            return null;
          }
        }
        return null;
      },
      isSettingWorkout: true,
      textController: TextEditingController());

  bool mounted = true;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    mounted = false;
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void countDown() {
    setState(() {
      _start = _start - 1;
    });

    if (timerKey.currentState != null) {
      timerKey.currentState.zoom();
    }
  }

  void runTimer() {
    _start = 4;
    Future.delayed(Duration(milliseconds: 100), () {
      timerBKKey.currentState.show();
    });

    Future.delayed(Duration(milliseconds: 500), () {
      countDown();
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      } else {
        _timer = new Timer.periodic(
          const Duration(seconds: 1),
          (Timer timer) {
            if (_start <= 1) {
              timer.cancel();
              _timer = null;

              setState(() {
                _start = 0;
              });
              timerBKKey.currentState.hide();

              Navigator.of(context)
                  .push(Transition.createHomePageRoute(TimerExercisePage(
                exercises: widget.workout.exercises,
                work: work,
                rest: rest,
                rounds: rounds,
              )));
            } else {
              countDown();
            }
          },
        );
      }
    });
  }

  void showLevel(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin:
                          EdgeInsets.only(top: MySizeStyle.design(40, context)),
                      padding: EdgeInsets.symmetric(
                        horizontal: MySizeStyle.design(20, context),
                        vertical: MySizeStyle.design(30, context),
                      ),
                      decoration: BoxDecoration(
                        color: MyColorStyle.whiteColor,
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              dictionary.setYourLevel,
                              textAlign: TextAlign.center,
                              style: MyTextStyle.titleDarkStyle(context),
                            ),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(5, context),
                          ),
                          Text(
                            dictionary.selectYourLevelContent,
                            textAlign: TextAlign.center,
                            style: MyTextStyle.textStyle(context),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(20, context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text('Work:',
                                style: MyTextStyle.tagBoldStyle(context)),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(5, context),
                          ),
                          _workInput,
                          SizedBox(
                            height: MySizeStyle.design(10, context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text('Rest:',
                                style: MyTextStyle.tagBoldStyle(context)),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(5, context),
                          ),
                          _restInput,
                          SizedBox(
                            height: MySizeStyle.design(10, context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Rounds:',
                              style: MyTextStyle.tagBoldStyle(context),
                            ),
                          ),
                          SizedBox(
                            height: MySizeStyle.design(5, context),
                          ),
                          _roundsInput,
                          SizedBox(
                            height: MySizeStyle.design(20, context),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: DialogButton(
                                      text: dictionary.iAmReady.toUpperCase(),
                                      color: MyColorStyle.primaryColor,
                                      onTap: () {
                                        hasError = false;
                                        _formKey.currentState.validate();
                                        if (!hasError) {
                                          work = int.parse(
                                              _workInput.textController.text);
                                          rest = int.parse(
                                              _restInput.textController.text);
                                          rounds = int.parse(
                                              _roundsInput.textController.text);

                                          Navigator.of(context).pop();
                                          runTimer();
                                        } else {
                                          AlertHelper(
                                                  type: AlertType.failure,
                                                  title: "Incomplete",
                                                  message:
                                                      "Please fill in inputs with digits.")
                                              .alertDialog(context);
                                        }
                                      })),
                              SizedBox(width: MySizeStyle.design(5, context)),
                              Expanded(
                                  child: DialogButton(
                                      text: dictionary.needTime.toUpperCase(),
                                      color: MyColorStyle.foreground,
                                      onTap: () => Navigator.of(context).pop()))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Future showAll(__keys) async {
    for (GlobalKey<ItemFaderState> key in __keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.show();
      } else {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: MySizeStyle.design(10, context)),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MySizeStyle.design(15, context)),
                                child: Icon(Icons.arrow_back,
                                    size: MySizeStyle.design(30, context),
                                    color: MyColorStyle.secondaryColor),
                              ),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              widget.workout.name,
                              style: MyTextStyle.titleDarkStyle(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(10, context),
                      ),
                      Expanded(
                          child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        margin: EdgeInsets.only(
                          top: MySizeStyle.design(10, context),
                          left: MySizeStyle.design(10, context),
                          right: MySizeStyle.design(10, context),
                        ),
                        child: widget.workout.exercises.length > 0
                            ? GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 14 / 24,
                                mainAxisSpacing: 0,
                                crossAxisSpacing:
                                    MySizeStyle.design(10, context),
                                children: List.generate(
                                    widget.workout.exercises.length,
                                    (index) => LayoutBuilder(
                                            builder: (context, constraints) {
                                          var item =
                                              widget.workout.exercises[index];
                                          var description = item.description;

                                          if (description == null) {
                                            description = "NO DESCRIPTION";
                                          } else if (description.length > 50) {
                                            description =
                                                description.substring(0, 50) +
                                                    "...";
                                          }

                                          var tag =
                                              "${item.repetitions} REP | ${item.series} SERIES";
                                          return ExerciseWidget(
                                            title: item.title,
                                            description: description,
                                            tag: tag,
                                            file: item.thumbnail,
                                            video: item.file,
                                            onTap: () async {
                                              var removed =
                                                  await Navigator.of(context)
                                                      .push(Transition
                                                          .createHomePageRoute(
                                                              MyExercisePage(
                                                                  exercise:
                                                                      item)));
                                              if (removed == "Removed") {
                                                setState(() {
                                                  widget.workout.exercises
                                                      .removeAt(index);
                                                });
                                              }
                                            },
                                          );
                                        })),
                              )
                            : Column(
                                children: [
                                  Text(
                                    dictionary.addExercisesDescription,
                                    style: MyTextStyle.textStyle(context),
                                  ),
                                  SizedBox(
                                    height: MySizeStyle.design(20, context),
                                  ),
                                  MyButton(
                                    title: dictionary.explore,
                                    onTap: () => {
                                      Navigator.of(context).pushReplacement(
                                          Transition.createHomePageRoute(
                                              HomePage()))
                                    },
                                  )
                                ],
                              ),
                      ))
                    ],
                  ),
                ),
                widget.workout.exercises.length > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: MySizeStyle.design(20, context),
                            vertical: MySizeStyle.design(10, context)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyButton(
                                title: "Start Workout".toUpperCase(),
                                onTap: () => showLevel(context))
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          ItemFader(
              key: timerBKKey,
              type: ConfirmAction.FADE,
              child: IgnorePointer(
                ignoring: _start <= 1,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.8)),
                  child: Center(
                    child: ItemZoom(
                      key: timerKey,
                      child: Text(
                        _start > 0 ? _start.toString() : "",
                        style: MyTextStyle.customStyle(context,
                            size: 70, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
