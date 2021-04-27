import 'package:flutter/material.dart';

class ItemZoom extends StatefulWidget {
  final Widget child;

  const ItemZoom({Key key, @required this.child})
      : super(key: key);

  @override
  ItemZoomState createState() => ItemZoomState();
}

class ItemZoomState extends State<ItemZoom>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  CurvedAnimation _curvedAnimation;

  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 - _curvedAnimation.value,
      child: FadeTransition(
        child: widget.child,
        opacity: _curvedAnimation,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  void zoom() {
    if (_animationController != null) {
      _animationController.reset();
      _animationController.forward();
    }
  }
}
