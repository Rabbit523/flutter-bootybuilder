import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class MyIconButton extends StatefulWidget {
  final onTap;
  final icon;

  MyIconButton({Key key, this.icon, this.onTap}) : super(key: key);

  @override
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton>
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
          width: MySizeStyle.design(80, context),
          height: MySizeStyle.design(50, context),
          decoration: BoxDecoration(
              color: MyColorStyle.whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(MySizeStyle.design(25, context)),
                  bottomLeft: Radius.circular(MySizeStyle.design(25, context))),
              boxShadow: [
                BoxShadow(
                  color: MyColorStyle.foreground.withOpacity(0.5),
                  spreadRadius: MySizeStyle.design(-16.0 * _shadowScale, context),
                  blurRadius: MySizeStyle.design(16.0 * _shadowScale, context),
                  offset: Offset(
                    0,
                    MySizeStyle.design(16.0 * _shadowScale, context),
                  ), // changes position of shadow
                ),
              ]),
          child: this.widget.icon,
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
