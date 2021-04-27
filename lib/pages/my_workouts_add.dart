import 'package:app/components/alert_helper.dart';
import 'package:app/components/models/exercise_model.dart';
import 'package:app/components/models/my_workout_model.dart';
import 'package:app/components/my_workout_widget.dart';
import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/icon_button.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/components/repository.dart';
import 'package:app/pages/exercises.dart';
import 'package:app/services/transition.dart';
import 'package:app/pages/new_workout.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';

class MyWorkoutsForAddPage extends StatefulWidget {
  final ExerciseModel exercise;
  MyWorkoutsForAddPage({Key key, @required this.exercise}) : super(key: key);

  @override
  _MyWorkoutsForAddPageState createState() => _MyWorkoutsForAddPageState();
}

class _MyWorkoutsForAddPageState extends State<MyWorkoutsForAddPage> {

  List<GlobalKey<ItemFaderState>> keys;
  List<MyWorkoutModel> workouts;

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
    keys = List.generate(3, (_) => GlobalKey<ItemFaderState>());
    workouts = new List<MyWorkoutModel>();

    Future.delayed(Duration.zero, () async => {
      await showAll(keys),
      await loadWorkouts()
    });
  }

  Future loadWorkouts() async {
    await Repository().open();
    var db = Repository().db;
    if (db != null) {
      var data = await MyWorkoutModel.getItems(db);
      if (data != null) {
        var newKeys = List.generate(data.length, (_) => GlobalKey<ItemFaderState>());
        for (var i = 0; i < data.length; i++) {
          data[i].key = newKeys[i];
        }
        setState(() {
          workouts = data;
        });

        await showAll(newKeys);
      }
    }
    await Repository().close();
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

  Future hideAll() async {
    for (GlobalKey<ItemFaderState> key in keys) {
      await Future.delayed(Duration(milliseconds: 120));
      if (key.currentState != null) {
        key.currentState.hide();
      } else {
        break;
      }
    }
  }

  Future onDelete(index, workout) {
    AlertHelper(
        type: AlertType.delConfirm,
        title: "Are you sure?",
        message: "Do you really want to to delete this workout? This process cannot be undone.",
        confirmFn: () => _onDelete(index, workout)
    ).alertDialog(context);
  }

  Future _onDelete(index, workout) async {
    await Repository().open();
    var db = Repository().db;
    if (db != null) {
      await MyWorkoutModel.delete(db, workout.id);

      if (workout.key != null && workout.key.currentState != null) {
        workout.key.currentState.zoomOut();
        await Future.delayed(Duration(milliseconds: 500));
      }

      setState(() {
        workouts.removeAt(index);
      });
    }
    await Repository().close();
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    var workout = workouts[index];
    return MyWorkoutWidget(
      title: workout.name,
      file: workout.file,
      onTap: () => {
        Navigator.of(context)
            .push(Transition.createHomePageRoute(ExercisesPage()))
      },
      onDelete: () async => await onDelete(index, workout),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MySizeStyle.pageHorizontal(context),
                    vertical: MySizeStyle.pageVertical(context)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemFader(
                      key: keys[0],
                      child: Text(
                        dictionary.myWorkouts,
                        style: MyTextStyle.pageTitleStyle(context),
                      ),
                    ),
                    SizedBox(
                      height: MySizeStyle.design(10, context),
                    ),
                    ItemFader(
                      key: keys[1],
                      child: Text(
                        dictionary.myWorkoutsSelectDescription,
                        style: MyTextStyle.textStyle(context),
                      ),
                    ),
                    SizedBox(
                      height: MySizeStyle.design(20, context),
                    ),
                    Column(
                      children: List.generate(workouts.length, (index)  => LayoutBuilder(builder: (context, constraints) {
                        var workout = workouts[index];
                        return ItemFader(
                          key: workout.key,
                          child: MyWorkoutWidget(
                            title: workout.name,
                            file: workout.file,
                            exercises: workout.exercises.length,
                            onTap: () async => {
                              await _linkToWorkout(workout)
                            },
                            onDelete: () async => await onDelete(index, workout),
                          ),
                        );
                      })),
                    ),
                    SizedBox(
                      height: MySizeStyle.design(15, context),
                    ),
                    ItemFader(
                      key: keys[2],
                      child: MyButton(
                        title: "+ New Workout",
                        onTap: _createNewWorkout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: MySizeStyle.design(30, context),
              child: MyIconButton(
                icon: Icon(Bootybuilder.next, size: MySizeStyle.design(15, context)),
                onTap: () => {
                  Navigator.of(context).pop()
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _linkToWorkout(MyWorkoutModel workout) async {
    await Repository().open();
    var db = Repository().db;
    ExerciseModel model = new ExerciseModel();
    model.id = widget.exercise.id;
    model.title = widget.exercise.title;
    model.description = widget.exercise.description;
    model.file = widget.exercise.file;
    model.series = widget.exercise.series;
    model.repetitions = widget.exercise.repetitions;
    model.formatID = widget.exercise.formatID;
    model.workoutId = workout.id;
    model.videoLength = widget.exercise.videoLength;
    model.thumbnail = widget.exercise.thumbnail;

    bool exist = await ExerciseModel.exist(db, workout.id, widget.exercise.id);
    if (exist == false) {
      model = await ExerciseModel.insert(db, model);
    }

    if (workout.file == null) {
      workout.file = model.thumbnail;
      await MyWorkoutModel.update(db, workout);
    }

    await Repository().close();
    AlertHelper(
        type: AlertType.success,
        title: "Exercise added!",
        message: "${model.title} was added to ${workout.name}.",
        cancelFn: () => Navigator.of(context).pop(model)
    ).alertDialog(context);
  }

  Future _createNewWorkout() async {
    var result = await Navigator.of(context)
        .push(Transition.createHomePageRoute(NewWorkoutPage()));
    if (result != null) {
        result.key = GlobalKey<ItemFaderState>();
        setState(() {
          workouts.add(result);
        });
        await Future.delayed(Duration(milliseconds: 120));
        if (result.key.currentState != null) {
          result.key.currentState.show();
        }
    }
  }
}