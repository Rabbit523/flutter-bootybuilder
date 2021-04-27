import 'package:app/components/alert_helper.dart';
import 'package:app/components/icon_button.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/models/my_workout_model.dart';
import 'package:app/components/my_workout_widget.dart';
import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/repository.dart';
import 'package:app/services/transition.dart';
import 'package:app/pages/new_workout.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';

import 'my_exercises.dart';

class MyWorkoutsPage extends StatefulWidget {
  MyWorkoutsPage({Key key}) : super(key: key);

  @override
  _MyWorkoutsPageState createState() => _MyWorkoutsPageState();
}

class _MyWorkoutsPageState extends State<MyWorkoutsPage> {
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
    keys = List<GlobalKey<ItemFaderState>>();
    workouts = new List<MyWorkoutModel>();

    Future.delayed(
        Duration.zero, () async => {await showAll(keys), await loadWorkouts()});
  }

  Future loadWorkouts() async {
    await Repository().open();
    var db = Repository().db;
    if (db != null) {
      var data = await MyWorkoutModel.getItems(db);
      if (data != null) {
        var newKeys =
            List.generate(data.length, (_) => GlobalKey<ItemFaderState>());
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

  Future onDelete(index, workout) async {
    AlertHelper(
        type: AlertType.delConfirm,
        title: "Are you sure?",
        message: "This process cannot be undone.",
        confirmFn: () => _onDelete(index, workout)).alertDialog(context);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MySizeStyle.pageHorizontal(context),
                  vertical: MySizeStyle.pageHorizontal(context)),
              child: workouts.length > 0 ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(
                        workouts.length,
                        (index) =>
                            LayoutBuilder(builder: (context, constraints) {
                              var workout = workouts[index];
                              return ItemFader(
                                key: workout.key,
                                child: MyWorkoutWidget(
                                  title: workout.name,
                                  exercises: workout.exercises.length,
                                  file: workout.file,
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                        Transition.createHomePageRoute(
                                            MyExercisesPage(
                                      workout: workout,
                                    )));
                                    setState(() {});
                                  },
                                  onDelete: () async =>
                                      await onDelete(index, workout),
                                ),
                              );
                            })),
                  )
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dictionary.addWorkout,
                    style: MyTextStyle.titleDarkStyle(context),
                  ),
                  SizedBox(
                    height: MySizeStyle.design(10, context),
                  ),
                  Text(
                    dictionary.addWorkoutDescription,
                    style: MyTextStyle.textStyle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: MySizeStyle.design(20, context),
          child: MyIconButton(
            icon: Icon(
              Bootybuilder.add,
              size: MySizeStyle.design(20, context),
              color: MyColorStyle.primaryColor,
            ),
            onTap: _createNewWorkout,
          ),
        )
      ],
    );
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
