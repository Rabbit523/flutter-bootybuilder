import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      backgroundColor: MyColorStyle.secondaryColor,
      valueColor: AlwaysStoppedAnimation<Color>(MyColorStyle.primaryColor),
    );
  }
}
