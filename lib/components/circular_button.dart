import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class MyCircularButton extends StatefulWidget {
  final onTap;
  final icon;
  final size;
  final color;

  MyCircularButton({Key key, this.icon, this.onTap, @required this.size, @required this.color = Colors.white}) : super(key: key);

  @override
  _MyCircularButtonState createState() => _MyCircularButtonState();
}

class _MyCircularButtonState extends State<MyCircularButton>
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
          width: MySizeStyle.design(widget.size, context),
          height: MySizeStyle.design(widget.size, context),
          decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(widget.size / 2, context))),
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
