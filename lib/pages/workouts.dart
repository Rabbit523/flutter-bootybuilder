import 'dart:io';

import 'package:app/components/backend.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/workout_category_model.dart';
import 'package:app/components/my_in_app_purchase.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:convert';
import 'package:app/components/category_widget.dart';
import 'package:app/components/models/workout_model.dart';
import 'package:app/pages/workout.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'package:app/components/alert_helper.dart';
import 'dart:async';

class WorkoutsPage extends StatefulWidget {
  WorkoutsPage({Key key}) : super(key: key);

  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  var selected = 0;

  List<WorkoutCategory> categories;

  List<GlobalKey<ItemFaderState>> keys;

  List<Workout> items;
  List<Workout> workouts;
  var perPage = 20;
  var page = 1;
  var total = 0;
  var isLoading = false;
  var _category_loaded = false;
  ScrollController _controller;

  bool mounted = true;

  var selectedTimer = 0;
  var timerTitles = ["Timer", "No Timer"];

  void toggleTimer(int index) {
    setState(() {
      selectedTimer = index;
    });

    loadCategories();
  }

  void reload() {
    total = 0;
    page = 1;
    items.clear();

    if(categories.length > selected) {
      _loadWorkouts();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

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

    items = <Workout>[];
    workouts = <Workout>[];
    categories = <WorkoutCategory>[];

    loadCategories();
  }

  void loadWorkouts() {
    for (var i = (page - 1) * perPage; i < workouts.length && i < page * perPage; i++) {
      items.add(workouts[i]);
    }
  }

  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - MySizeStyle.design(700, context)) &&
        !_controller.position.outOfRange) {
      // message = "reach the bottom";
      if(page * perPage < total && isLoading == false) {
        setState(() {
          page++;
          loadWorkouts();
        });
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      // message = "reach the top";
    }
  }

  void loadTimerCategories() {
    APIManager().getTimerCategories().then((value) {
      if (value.statusCode == 200) {
        var data = json.decode(value.body);
        setState(() {
          timerTitles[0] = data["timer"];
          timerTitles[1] = data["no_timer"];
          _category_loaded = true;
        });
      }
    });
  }

  void loadCategories() {
    setState(() {
      isLoading = true;
    });

    loadTimerCategories();

    APIManager().getWorkoutCategories(selectedTimer == 0 ? '1' : '0').then((value) {
      if (value.statusCode == 200) {
        var data = json.decode(value.body);
        if (data["categories"] != null) {
          categories = <WorkoutCategory>[];
          for(var i = 0; i < data["categories"].length; i++) {
            var category = WorkoutCategory.fromMap(data["categories"][i]);
            categories.add(category);
          }

          setState(() {
            selected = 0;
          });


          reload();
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

  void _loadWorkouts() {
    setState(() {
      isLoading = true;
    });

    var category = categories[selected];

    APIManager().getWorkouts(selectedTimer == 0 ? '1' : '0', category.id,  1, 10000).then((value) {
      if (value.statusCode == 200) {
        var data = json.decode(value.body);
        if (data["data"] != null) {
          workouts = <Workout>[];
          for(var i = 0; i < data["data"].length; i++) {
            var workout = Workout.fromMap(data["data"][i]);
            workouts.add(workout);
          }

          loadWorkouts();

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

  Future _checkSubscription (context, item) async {
    if(isLoading) return;

    setState(() {
      isLoading = true;
    });

    bool available = await InAppPurchaseConnection.instance.isAvailable();

    if (available) {
      final QueryPurchaseDetailsResponse purchaseResponse =
      await InAppPurchaseConnection.instance.queryPastPurchases();

      for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
        if (purchase.productID == item.productId) {

          if (Platform.isIOS) {
            InAppPurchaseConnection.instance.completePurchase(purchase);
          }

          Navigator.of(context)
              .push(Transition.createHomePageRoute(WorkoutPage(workout: item, hasTimer: selectedTimer == 0,)));

          setState(() {
            isLoading = false;
          });

          return;
        }
      }

      Navigator.of(context)
          .push(Transition.createHomePageRoute(
          MyInAppPurchasePage(
            workout: item,
          )));
    } else {
      AlertHelper(title: "Sorry", message: "Store is unavailable.", type: AlertType.failure)
          .alertDialog(context);
    }

    setState(() {
      isLoading = false;
    });
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
                  vertical: MySizeStyle.pageHorizontal(context)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _category_loaded ? Container(
                    padding: EdgeInsets.only(
                        right: MySizeStyle.design(5, context)
                    ),
                    margin: EdgeInsets.only(
                        bottom: MySizeStyle.design(10, context)
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            timerTitles.length,
                                (index) =>
                                LayoutBuilder(builder: (context, constraints) {
                                  var timerTitle = timerTitles[index];
                                  return GestureDetector(
                                    onTap: () => toggleTimer(index),
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
                                                  color: selectedTimer == index
                                                      ? MyColorStyle
                                                      .primaryColor
                                                      : Colors.transparent,
                                                  width: 2.0))),
                                      child: Text(
                                        timerTitle.toUpperCase(),
                                        style: selectedTimer == index
                                            ? MyTextStyle.tagPrimaryStyle(
                                            context)
                                            : MyTextStyle.tagDarkStyle(context),
                                      ),
                                    ),
                                  );
                                })),
                      ),
                    ),
                  ) : SizedBox(),
                  categories.length > 0 ? Container(
                    padding: EdgeInsets.only(
                        right: MySizeStyle.design(5, context)
                    ),
                    margin: EdgeInsets.only(
                        bottom: MySizeStyle.design(10, context)
                    ),
                    child:  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            categories.length,
                                (index) =>
                                LayoutBuilder(builder: (context, constraints) {
                                  var category = categories[index];
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
                                        category.title,
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
                  ) : SizedBox(),
                  Column(
                    children: List.generate(items.length, (index)  => LayoutBuilder(builder: (context, constraints) {
                      var item = items[index];
                      var day = item.days.length > 0 ? item.days.length : "NO";
                      var description = item.description;

                      if (description == null) {
                        description = "NO DESCRIPTION";
                      } else if(description.length > 60) {
                        description = description.substring(0,60) + "...";
                      }

                      return CategoryWidget(
                        title: item.title,
                        description: description,
                        isPremium: item.isNeedPurchase(),
                        file: item.file,
                        onTap: () async {
                          if (item.isNeedPurchase()) {
                            await _checkSubscription(context, item);
                          } else {
                            Navigator.of(context)
                                .push(Transition.createHomePageRoute(WorkoutPage(workout: item, hasTimer: selectedTimer == 0,)));
                          }
                        },
                      );
                    })),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: isLoading ? LoadingWidget() : SizedBox(),
        ),
      ],
    );
  }
}