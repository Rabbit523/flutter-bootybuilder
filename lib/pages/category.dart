import 'dart:convert';

import 'package:app/components/backend.dart';
import 'package:app/components/exercise_widget.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/category_model.dart';
import 'package:app/components/models/exercise_model.dart';
import 'package:app/pages/exercise.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'dart:async';

class CategoryPage extends StatefulWidget {
  final Category category;
  CategoryPage({Key key, @required this.category}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  var selected = 0;
  var selectedSub = 0;
  var selectedTag;

  List<ExerciseModel> items;
  List<ExerciseModel> exercises;

  var perPage = 20;
  var page = 1;
  var total = 0;
  var isLoading = false;

  ScrollController _controller;

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

    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    items = <ExerciseModel>[];
    exercises = <ExerciseModel>[];

    if (widget.category.tags.length > 0) {
      selectedTag = widget.category.tags[0];
    }

    _loadExercises();
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
    if (selectedTag == null) return;

    setState(() {
      isLoading = true;
    });

    var tag = selectedTag;
    if (selectedTag.hasSubtag && selectedTag.subtags.length > selectedSub) {
      tag = selectedTag.subtags[selectedSub];
    }

    APIManager().getExercisesFromTag(tag.id, 1, 10000).then((value) {
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
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
                              widget.category.title,
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            widget.category.tags.length,
                            (index) =>
                                LayoutBuilder(builder: (context, constraints) {
                                  var tag = widget.category.tags[index];
                                  return GestureDetector(
                                    onTap: () => {
                                      setState(() {
                                        selected = index;
                                        selectedSub = 0;
                                        selectedTag = tag;
                                        reload();
                                      })
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              MySizeStyle.design(3, context)),
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MySizeStyle.design(10, context),
                                        vertical:
                                            MySizeStyle.design(8, context),
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: selected == index
                                                      ? MyColorStyle
                                                          .primaryColor
                                                      : Colors.transparent,
                                                  width: 2.0))),
                                      child: Text(
                                        tag.name.toUpperCase(),
                                        style: selected == index
                                            ? MyTextStyle.tagPrimaryStyle(
                                                context)
                                            : MyTextStyle.tagDarkStyle(context),
                                      ),
                                    ),
                                  );
                                })),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MySizeStyle.design(10, context),
                  ),
                  (selectedTag != null && selectedTag.hasSubtag && selectedTag.subtags.length > 0)
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: MySizeStyle.pageHorizontal(context)),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  selectedTag.subtags.length,
                                  (index) => LayoutBuilder(
                                          builder: (context, constraints) {
                                        var tag = selectedTag.subtags[index];
                                        return GestureDetector(
                                          onTap: () => {
                                            setState(() {
                                              selectedSub = index;
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
                                              tag.name,
                                              style: selectedSub == index
                                                  ? MyTextStyle.tagPrimaryStyle(
                                                      context)
                                                  : MyTextStyle.tagDarkStyle(
                                                      context),
                                            ),
                                          ),
                                        );
                                      })),
                            ),
                          ),
                        )
                      : SizedBox(),
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
                          controller: _controller,
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: MySizeStyle.design(10, context),
                          childAspectRatio: 14 / 24,
                          children: List.generate(
                              items.length,
                              (index) => LayoutBuilder(
                                      builder: (context, constraints) {
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
                                  })),
                        )),
                  ),
                ],
              ),
            ),
            Center(
              child: isLoading ? LoadingWidget() : SizedBox(),
            )
          ],
        ),
      ),
    );
  }
}
