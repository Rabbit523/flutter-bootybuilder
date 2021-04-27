import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class MyButton extends StatefulWidget {
  final String title;
  final String type;
  final opacity;
  final onTap;

  MyButton(
      {Key key,
      @required this.title,
      this.opacity = 1.0,
      this.type = "primary",
      this.onTap})
      : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
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
          height: MySizeStyle.design(45, context),
          decoration: BoxDecoration(
              color: this.widget.type != "primary"
                  ? MyColorStyle.whiteColor.withOpacity(widget.opacity)
                  : MyColorStyle.primaryColor.withOpacity(widget.opacity),
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              boxShadow: [
                BoxShadow(
                  color: this.widget.type != "primary"
                      ? MyColorStyle.foreground.withOpacity(0.5)
                      : MyColorStyle.primaryColor.withOpacity(0.5),
                  spreadRadius: MySizeStyle.design(-24.0 * _shadowScale, context),
                  blurRadius: MySizeStyle.design(24.0 * _shadowScale, context),
                  offset: Offset(
                    0,
                    MySizeStyle.design(24.0 * _shadowScale, context),
                  ), // changes position of shadow
                ),
              ]),
          child: Center(
            child: Text(
              this.widget.title.toUpperCase(),
              style: this.widget.type != "primary"
                  ? MyTextStyle.buttonDarkStyle(context)
                  : MyTextStyle.buttonStyle(context),
            ),
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
