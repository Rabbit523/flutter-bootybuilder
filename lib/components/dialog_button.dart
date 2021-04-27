import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class DialogButton extends StatefulWidget {
  final String text;
  final color;
  final onTap;

  DialogButton({Key key, @required this.text, @required this.color, this.onTap})
      : super(key: key);

  @override
  _DialogButtonState createState() => _DialogButtonState();
}

class _DialogButtonState extends State<DialogButton>
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
          height: MySizeStyle.design(40, context),
          width: MySizeStyle.design(100, context),
          decoration: BoxDecoration(
              color: this.widget.color,
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
              boxShadow: [
                BoxShadow(
                  color: this.widget.color.withOpacity(0.5),
                  spreadRadius: MySizeStyle.design(-12.0 * _shadowScale, context),
                  blurRadius: MySizeStyle.design(12.0 * _shadowScale, context),
                  offset: Offset(
                    0,
                    MySizeStyle.design(12.0 * _shadowScale, context),
                  ), // changes position of shadow
                ),
              ]),
          child: Center(
            child: Text(
              this.widget.text,
              style: MyTextStyle.textWhiteStyle(context),
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
