import 'package:flutter/material.dart';

enum ConfirmAction { SLIDE, ZOOM, FADE }

class ItemFader extends StatefulWidget {
  final Widget child;
  final direction;
  final type;

  const ItemFader({Key key, @required this.child, this.direction = 0, this.type = ConfirmAction.SLIDE})
      : super(key: key);

  @override
  ItemFaderState createState() => ItemFaderState();
}

class ItemFaderState extends State<ItemFader>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  CurvedAnimation _curvedAnimation;

  int position = 1;
  var type = ConfirmAction.SLIDE;

  void initState() {
    super.initState();

    type = this.widget.type;

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (this.type == ConfirmAction.SLIDE) {
      return AnimatedBuilder(
          animation: _curvedAnimation,
          child: widget.child,
          builder: (context, child) {
            return Transform.translate(
                offset: this.widget.direction == 0
                    ? Offset(0, 64 * position * (1 - _curvedAnimation.value))
                    : this.widget.direction == 1
                        ? Offset(
                            0, -64 * position * (1 - _curvedAnimation.value))
                        : this.widget.direction == 2
                            ? Offset(
                                64 * position * (1 - _curvedAnimation.value), 0)
                            : Offset(
                                -64 * position * (1 - _curvedAnimation.value),
                                0),
                child: Opacity(opacity: _curvedAnimation.value, child: child));
          });
    } else if (this.type == ConfirmAction.FADE) {
      return AnimatedBuilder(
          animation: _curvedAnimation,
          child: widget.child,
          builder: (context, child) {
            return Opacity(opacity: _curvedAnimation.value, child: child);
          });
    }

    return SizeTransition(
      axis: Axis.vertical,
      child: FadeTransition(
        child: widget.child,
        opacity: _curvedAnimation,
      ),
      sizeFactor: _curvedAnimation,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  void show() {
    if (_animationController != null) {
      setState(() => position = 1);
      _animationController.forward();
    }
  }

  void hide() {
    if (_animationController != null) {
      setState(() => position = -1);
      _animationController.reverse();
    }
  }

  void zoomOut() {
    if (_animationController != null) {
      setState(() => this.type = ConfirmAction.ZOOM);
      _animationController.reverse();
    }
  }

  void zoomIn() {
    if (_animationController != null) {
      setState(() => this.type = ConfirmAction.ZOOM);
      _animationController.forward();
    }
  }
}
