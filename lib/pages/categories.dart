import 'package:app/components/backend.dart';
import 'package:app/components/category_widget.dart';
import 'package:app/components/loading_widget.dart';
import 'package:app/components/models/category_model.dart';
import 'package:app/pages/category.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';
import 'package:app/components/item_fader.dart';
import 'package:app/services/transition.dart';
import 'dart:async';
import 'dart:convert';

const qrCodeUrl = "https://appadmin.bootybuilder.com/app";

class CategoriesPage extends StatefulWidget {
  CategoriesPage({Key key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<GlobalKey<ItemFaderState>> keys;

  List<Category> categories;
  List<Category> items;
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

    categories = <Category>[];
    items = <Category>[];

    _loadCategories();
  }

  _scrollListener() {
    if (_controller.offset >= (_controller.position.maxScrollExtent - MySizeStyle.design(700, context)) &&
        !_controller.position.outOfRange) {
      // message = "reach the bottom";
      if (page * perPage < total && isLoading == false) {
        setState(() {
          page++;
          loadCategories();
        });
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      // message = "reach the top";
    }
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

  void loadCategories() {
    for (var i = (page - 1) * perPage; i < categories.length && i < page * perPage; i++) {
      items.add(categories[i]);
    }
  }

  void _loadCategories() {
    setState(() {
      isLoading = true;
    });

    APIManager().getCategories(1, 10000).then((value) {
      if (value.statusCode == 200) {
        var data = json.decode(value.body);
        if (data["data"] != null) {
          categories = <Category>[];

          for (var i = 0; i < data["data"].length; i++) {
            var category = Category.fromMap(data["data"][i]);
            categories.add(category);
          }

          loadCategories();

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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            controller: _controller,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MySizeStyle.pageHorizontal(context),
                  vertical: MySizeStyle.pageHorizontal(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(
                        items.length,
                        (index) =>
                            LayoutBuilder(builder: (context, constraints) {
                              var item = items[index];
                              var tag = item.totalExercises > 0
                                  ? item.totalExercises
                                  : "NO";
                              var description = item.description;

                              if (description == null) {
                                description = "NO DESCRIPTION";
                              } else if (description.length > 60) {
                                description =
                                    description.substring(0, 60) + "...";
                              }

                              return CategoryWidget(
                                title: item.title,
                                tag: "$tag EXERCISES",
                                description: description,
                                file: item.file,
                                onTap: () => {
                                  if (item.tags.length > 0)
                                    {
                                      Navigator.of(context).push(
                                          Transition.createHomePageRoute(
                                              CategoryPage(category: item)))
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
