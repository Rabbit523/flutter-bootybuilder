import 'package:app/components/backend.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

const height = 150;

class CategoryWidget extends StatefulWidget {
  final String title;
  final String tag;
  final String file;
  final String description;
  final bool isPremium;
  final onTap;

  CategoryWidget(
      {Key key,
      @required this.title,
      @required this.tag,
      @required this.description,
      @required this.file,
      this.isPremium = false,
      this.onTap})
      : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 1000),
      lowerBound: 0.0,
      upperBound: 0.02,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _scale = 1 - _controller.value;
    double _shadowScale = (0.02 - _controller.value) / 0.02;

    return GestureDetector(
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: MySizeStyle.fullWidth(context),
          height: MySizeStyle.design(height, context),
          margin: EdgeInsets.only(bottom: MySizeStyle.design(15, context)),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: MyColorStyle.foreground.withOpacity(0.5),
              spreadRadius: MySizeStyle.design(-12.0 * _shadowScale, context),
              blurRadius: MySizeStyle.design(12.0 * _shadowScale, context),
              offset: Offset(
                0,
                MySizeStyle.design(12.0 * _shadowScale, context),
              ), // changes position of shadow
            ),
          ]),
          child: Stack(
            children: [
              CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: MyColorStyle.secondaryColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          MyColorStyle.primaryColor),
                    ),
                  ),
                ),
                imageUrl: APIManager().getPath(widget.file),
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                    "assets/images/placeholder.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity),
              ),
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColorStyle.blackColor.withAlpha(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              this.widget.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: MyTextStyle.titleStyle(context),
                            ),
                            SizedBox(
                              height: MySizeStyle.design(5, context),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.tag != null ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MySizeStyle.design(4, context),
                                      vertical: MySizeStyle.design(2, context)),
                                  decoration: BoxDecoration(
                                      color: MyColorStyle.primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(2.0))),
                                  child: Text(
                                    widget.tag,
                                    style: MyTextStyle.tagStyle(context),
                                  ),
                                ): SizedBox(),
                                widget.isPremium
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            left:
                                                MySizeStyle.design(5, context)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                MySizeStyle.design(4, context),
                                            vertical:
                                                MySizeStyle.design(2, context)),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(2.0)),
                                            color: MyColorStyle.premiumColor),
                                        child: Text(
                                          "PREMIUM",
                                          style: MyTextStyle.tagStyle(context),
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
    );
  }

  void onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void onTapCancel() async {
    _controller.reverse();
  }

  void onTapUp(TapUpDetails details) async {
    _controller.reverse();

    if (this.widget.onTap != null) {
      await Future.delayed(Duration(milliseconds: 200));
      this.widget.onTap();
    }
  }
}
