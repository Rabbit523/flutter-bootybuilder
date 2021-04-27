import 'dart:convert';

import 'package:app/components/backend.dart';
import 'package:app/components/dialog_button.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/exercise_widget.dart';
import 'package:app/components/item_zoom.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/exercise_model.dart';
import 'package:app/components/models/workout_model.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/pages/exercise.dart';
import 'package:app/pages/timer_exercise.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'dart:async';

class WorkoutPage extends StatefulWidget {
  final Workout workout;
  final bool hasTimer;
  WorkoutPage({Key key, @required this.workout, this.hasTimer = false}) : super(key: key);

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  var selected = 0;

  List<ExerciseModel> items;
  List<ExerciseModel> exercises;

  var perPage = 20;
  var page = 1;
  var total = 0;
  var isLoading = false;
  String levelValue = 'Level 1';

  ScrollController _controller;
  Timer _timer;
  int _start = 0;

  GlobalKey<ItemFaderState> startWorkoutKey = new GlobalKey<ItemFaderState>();
  GlobalKey<ItemZoomState> timerKey = new GlobalKey<ItemZoomState>();
  GlobalKey<ItemFaderState> timerBKKey = new GlobalKey<ItemFaderState>();

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
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    items = <ExerciseModel>[];
    exercises = <ExerciseModel>[];
    _loadExercises();
  }

  void countDown() {
    setState(() {
      _start = _start - 1;
    });

    if (timerKey.currentState != null) {
      timerKey.currentState.zoom();
    }
  }

  @override
  void dispose() {
    mounted = false;
    _timer?.cancel();

    super.dispose();
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
          const Duration(seconds: 1), (Timer timer) {
          if (_start <= 1) {
            timer.cancel();
            _timer = null;

            setState(() {
              _start = 0;
            });
            timerBKKey.currentState.hide();

            var work = 30;
            var rest = 30;
            var rounds = 3;

            if (levelValue == "Level 1") {
              work = widget.workout.level1_work;
              rest = widget.workout.level1_rest;
              rounds = widget.workout.level1_rounds;
            } else if (levelValue == "Level 2") {
              work = widget.workout.level2_work;
              rest = widget.workout.level2_rest;
              rounds = widget.workout.level2_rounds;
            } else {
              work = widget.workout.level3_work;
              rest = widget.workout.level3_rest;
              rounds = widget.workout.level3_rounds;
            }

            Navigator.of(context).push(
                Transition.createHomePageRoute(
                    TimerExercisePage(exercises: items, work: work, rest: rest, rounds: rounds,)));

          } else {
            countDown();
          }
        },
        );
      }
    });

  }

  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - MySizeStyle.design(700, context)) &&
        !_controller.position.outOfRange) {
      // message = "reach the bottom";
      if (page * perPage < total && isLoading == false) {
        setState(() {
          page++;
          loadExercises();
        });
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      // message = "reach the top";
    }
  }


  void reload() {
    total = 0;
    page = 1;
    items.clear();

    _loadExercises();
  }

  void loadExercises() {
    for (var i = (page - 1) * perPage; i < exercises.length && i < page * perPage; i++) {
      items.add(exercises[i]);
    }
  }

  void _loadExercises() {
    setState(() {
      isLoading = true;
    });
    var day = widget.workout.days[selected];
    APIManager().getExercisesFromDay(day.id, 1, 10000).then((value) {
      if (value.statusCode == 200) {
        var data = json.decode(value.body);
        if (data["data"] != null) {
          exercises = <ExerciseModel>[];
          for (var i = 0; i < data["data"].length; i++) {
            var exercise = ExerciseModel.fromMap(data["data"][i]);
            exercises.add(exercise);
          }

          loadExercises();

          setState(() {
            total = int.parse(data['total'].toString());
            isLoading = false;
          });

          if(widget.hasTimer && exercises.length > 0) {
            startWorkoutKey.currentState.show();
          }

          return 0;
        }
      }

      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
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

  Widget buildBadget(BuildContext context, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MySizeStyle.design(5, context)),
      margin: EdgeInsets.only(
        top: MySizeStyle.design(5, context)
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(2.0))),
      child: Text(
        text,
        style: MyTextStyle.textStyle(context, color: color, size: 12),
      ),
    );
  }

  void showLevel(BuildContext context) {
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
                          dictionary.selectYourLevel,
                          textAlign: TextAlign.center,
                          style: MyTextStyle.titleDarkStyle(context),
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
                        Row(
                          children: [
                            Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Level 1:",
                                  textAlign: TextAlign.left,
                                  style: MyTextStyle.buttonDarkStyle(context),
                                ),
                                buildBadget(context, "${widget.workout.level1_work}s work", Colors.green),
                                buildBadget(context, "${widget.workout.level1_rest}s rest", Colors.red),
                                buildBadget(context, "${widget.workout.level1_rounds} rounds", Colors.blue)
                              ],
                            )),
                            SizedBox(width: MySizeStyle.design(10, context)),
                            Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Level 2:",
                                  textAlign: TextAlign.left,
                                  style: MyTextStyle.buttonDarkStyle(context),
                                ),
                                buildBadget(context, "${widget.workout.level2_work}s work", Colors.green),
                                buildBadget(context, "${widget.workout.level2_rest}s rest", Colors.red),
                                buildBadget(context, "${widget.workout.level2_rounds} rounds", Colors.blue)
                              ],
                            )),
                            SizedBox(width: MySizeStyle.design(10, context)),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Level 3:",
                                  textAlign: TextAlign.left,
                                  style: MyTextStyle.buttonDarkStyle(context),
                                ),
                                buildBadget(context, "${widget.workout.level3_work}s work", Colors.green),
                                buildBadget(context, "${widget.workout.level3_rest}s rest", Colors.red),
                                buildBadget(context, "${widget.workout.level3_rounds} rounds", Colors.blue)
                              ],
                            ))
                          ],
                        ),
                        SizedBox(
                          height: MySizeStyle.design(10, context),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: MySizeStyle.design(10, context),
                            vertical: 0,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.0, style: BorderStyle.solid, color: MyColorStyle.foreground),
                              borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(5, context))),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: levelValue,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                iconSize: 20,
                                elevation: 16,
                                isExpanded: true,
                                style: MyTextStyle.textStyle(context, color: MyColorStyle.primaryColor),
                                onChanged: (String newValue) {
                                  setState(() {
                                    levelValue = newValue;
                                  });
                                },
                                items: <String>['Level 1', 'Level 2', 'Level 3']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              )),
                        ),
                        SizedBox(
                          height: MySizeStyle.design(20, context),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: DialogButton(text: dictionary.iAmReady.toUpperCase(), color: MyColorStyle.primaryColor, onTap: () => { Navigator.of(context).pop(), runTimer() })),
                            SizedBox(width: MySizeStyle.design(5, context)),
                            Expanded(child: DialogButton(text: dictionary.needTime.toUpperCase(), color: MyColorStyle.foreground, onTap: () => Navigator.of(context).pop()))
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: MySizeStyle.design(10, context)),
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: MySizeStyle.design(15, context)),
                                child: Icon(Icons.arrow_back,
                                    size: MySizeStyle.design(30, context),
                                    color: MyColorStyle.secondaryColor),
                              ),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  widget.workout.title,
                                  style: MyTextStyle.titleDarkStyle(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: MySizeStyle.design(5, context)),
                        child: widget.workout.days.length > 1 ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                                widget.workout.days.length,
                                    (index) =>
                                    LayoutBuilder(builder: (context, constraints) {
                                      var day = widget.workout.days[index];
                                      return GestureDetector(
                                        onTap: () => {
                                          setState(() {
                                            selected = index;
                                            reload();
                                          })
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: MySizeStyle.design(
                                                  3, context)),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MySizeStyle.design(
                                                10, context),
                                            vertical: MySizeStyle.design(
                                                8, context),
                                          ),
                                          decoration: BoxDecoration(
                                              color: MyColorStyle.foreground
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0))),
                                          child: Text(
                                            day.name.toUpperCase(),
                                            style: selected == index
                                                ? MyTextStyle.tagPrimaryStyle(
                                                context)
                                                : MyTextStyle.tagDarkStyle(context),
                                          ),
                                        ),
                                      );
                                    })),
                          ),
                        ) : SizedBox(),
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
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 14 / 24,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: MySizeStyle.design(10, context),
                              children: List.generate(
                                items.length,
                                    (index) =>
                                    LayoutBuilder(builder: (context, constraints) {
                                      var item = items[index];
                                      var description = item.description;

                                      if (description == null) {
                                        description = "NO DESCRIPTION";
                                      } else if (description.length > 60) {
                                        description =
                                            description.substring(0, 60) + "...";
                                      }

                                      var tag =
                                          "${item.repetitions} REP | ${item.series} SERIES";
                                      return ExerciseWidget(
                                        title: item.title,
                                        description: description,
                                        tag: tag,
                                        file: item.thumbnail,
                                        video: item.file,
                                        onTap: () => {
                                          Navigator.of(context).push(
                                              Transition.createHomePageRoute(
                                                  ExercisePage(exercise: item)))
                                        },
                                      );
                                    }),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                widget.hasTimer ? Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MySizeStyle.design(20, context),
                      vertical: MySizeStyle.design(10, context)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ItemFader(
                          key: startWorkoutKey,
                          child: MyButton(
                              title: "Start Workout".toUpperCase(),
                              onTap: () => showLevel(context)
                          ))
                    ],
                  ),
                ) : SizedBox(),
                Center(
                  child: isLoading ? LoadingWidget() : SizedBox(),
                )
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
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8)
                ),
                child: Center(
                  child: ItemZoom(
                    key: timerKey,
                    child: Text(
                      _start > 0 ? _start.toString() : "",
                      style: MyTextStyle.customStyle(context, size: 70, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}
