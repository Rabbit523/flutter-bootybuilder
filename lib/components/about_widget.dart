import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class AboutWidget extends StatefulWidget {
  final image;
  final onTap;

  AboutWidget({Key key, this.image, this.onTap}) : super(key: key);

  @override
  _AboutWidgetState createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget>
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
        child: Stack(
          children: [
            Container(
              height: MySizeStyle.design(100, context),
              margin: EdgeInsets.only(
                bottom: MySizeStyle.design(15, context),
              ),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(this.widget.image),
                      fit: BoxFit.fitHeight),
                  color: MyColorStyle.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  boxShadow: [
                    BoxShadow(
                      color: MyColorStyle.foreground.withOpacity(0.2),
                      spreadRadius:
                          MySizeStyle.design(-24.0 * _shadowScale, context),
                      blurRadius:
                          MySizeStyle.design(24.0 * _shadowScale, context),
                      offset: Offset(
                        0,
                        MySizeStyle.design(24.0 * _shadowScale, context),
                      ), // changes position of shadow
                    ),
                  ]),
            )
          ],
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
