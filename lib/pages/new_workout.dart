import 'package:app/components/alert_helper.dart';
import 'package:app/components/bootybuilder_icons.dart';
import 'package:app/components/dictionary.dart';
import 'package:app/components/models/my_workout_model.dart';
import 'package:app/components/mybutton.dart';
import 'package:app/components/myedittext.dart';
import 'package:app/components/repository.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';

class NewWorkoutPage extends StatefulWidget {
  NewWorkoutPage({Key key}) : super(key: key);

  @override
  _NewWorkoutPageState createState() => _NewWorkoutPageState();
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  List<GlobalKey<ItemFaderState>> keys;

  static var hasError;

  final _workoutInput = MyEditText(
      placeholder: dictionary.workoutName,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value.isEmpty) {
          hasError = true;
          return null;
        }
        return null;
      },
      textController: TextEditingController());

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
    keys = List.generate(4, (_) => GlobalKey<ItemFaderState>());

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

  Future _createWorkout() async {
    hasError = false;

    _formKey.currentState.validate();

    if (!hasError) {
      await Repository().open();
      var db = Repository().db;
      MyWorkoutModel model = new MyWorkoutModel();
      model.name = _workoutInput.textController.text;
      model = await MyWorkoutModel.insert(db, model);
      model.exercises = [];
      await Repository().close();
      AlertHelper(
              type: AlertType.success,
              title: "Workout added!",
              message: "${model.name} was added.",
              cancelFn: () => Navigator.of(context).pop(model))
          .alertDialog(context);
    } else {
      AlertHelper(
              type: AlertType.failure,
              title: "Please type name",
              message: "The workout was not created.")
          .alertDialog(context);
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MySizeStyle.pageHorizontal(context),
                      vertical: MySizeStyle.pageVertical(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemFader(
                        key: keys[0],
                        child: Text(
                          dictionary.newWorkout,
                          style: MyTextStyle.titleDarkStyle(context),
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(10, context),
                      ),
                      ItemFader(
                        key: keys[1],
                        child: Text(
                          dictionary.newWorkoutDescription,
                          style: MyTextStyle.textStyle(context),
                        ),
                      ),
                      SizedBox(
                        height: MySizeStyle.design(15, context),
                      ),
                      ItemFader(
                        key: keys[2],
                        child: _workoutInput,
                      ),
                      SizedBox(
                        height: MySizeStyle.design(15, context),
                      ),
                      ItemFader(
                        key: keys[3],
                        child: MyButton(
                          title: dictionary.createWorkout,
                          onTap: _createWorkout,
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
                          color: MyColorStyle.foreground,
                        ),
                      ),
                    ),
                    onTap: () => {Navigator.of(context).pop()},
                  ),
                  right: MySizeStyle.design(10, context),
                  top: 0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
