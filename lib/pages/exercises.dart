import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/exercise_widget.dart';
import 'package:app/components/icon_button.dart';
import 'package:app/components/models/my_workout_model.dart';
import 'package:app/pages/exercise.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';

class ExercisesPage extends StatefulWidget {
  final MyWorkoutModel workout;
  ExercisesPage({Key key, @required this.workout}) : super(key: key);

  @override
  _ExercisesPageState createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
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
    keys = List.generate(7, (_) => GlobalKey<ItemFaderState>());

    Future.delayed(
        Duration.zero,
        () async => {
              await showAll(keys),
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
                    vertical: MySizeStyle.pageVertical(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemFader(
                      key: keys[0],
                      child: Text(
                        widget.workout.name,
                        style: MyTextStyle.titleDarkStyle(context),
                      ),
                    ),
                    SizedBox(
                      height: MySizeStyle.design(30, context),
                    ),
                    Column(
                      children: List.generate(
                          widget.workout.exercises.length,
                          (index) =>
                              LayoutBuilder(builder: (context, constraints) {
                                var item = widget.workout.exercises[index];
                                var description = item.description;

                                if (description == null) {
                                  description = "NO DESCRIPTION";
                                } else if (description.length > 50) {
                                  description =
                                      description.substring(0, 50) + "...";
                                }

                                var tag =
                                    "${item.repetitions} REP | ${item.series} SERIES";
                                return ExerciseWidget(
                                  title: item.title,
                                  description: description,
                                  tag: tag,
                                  file: item.thumbnail,
                                  onTap: () => {
                                    Navigator.of(context).push(
                                        Transition.createHomePageRoute(
                                            ExercisePage(exercise: item)))
                                  },
                                );
                              })),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                right: 0,
                top: MySizeStyle.design(30, context),
                child: MyIconButton(
                  icon: Icon(Bootybuilder.next,
                      size: MySizeStyle.design(15, context)),
                  onTap: () => {Navigator.of(context).pop()},
                ))
          ],
        ),
      ),
    );
  }
}
