import 'package:flutter/material.dart';

class Transition {
  static Route createHomePageRoute(Widget page) {
    return MaterialPageRoute(builder: (context) {
      return page;
    });
    // return PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) => page,
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       var begin = Offset(0.0, 1.0);
    //       var end = Offset.zero;
    //       var curve = Curves.easeIn;
    //
    //       var tween =
    //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    //
    //       return SlideTransition(
    //         position: animation.drive(tween),
    //         child: child,
    //       );
    //     },
    //     transitionDuration: Duration(milliseconds: 500));
  }
}
