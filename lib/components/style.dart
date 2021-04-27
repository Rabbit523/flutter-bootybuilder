import 'dart:ui';

import 'package:flutter/material.dart';

class MyColorStyle {
  static final background = Color(0xFFF7F8FA);
  static const foreground = Color(0xFF9297A3);
  static final primaryColor = Color(0xFFEC6A06);
  static final secondaryColor = Color(0xFF122B4B);
  static final whiteColor = Colors.white;
  static final blackColor = Colors.black;
  static final white50Color = Color(0x80FFFFFF);

  static final successColor = Color(0xFF51f701);
  static final errorColor = Color(0xFFF15D5E);

  static final premiumColor = Color(0xFFEC6A06);
}

double zoom(size, context) =>
    (MediaQuery.of(context).size.width * size / 365.0).roundToDouble();

class MyFontStyle {
  static double h1(context) => zoom(35.0, context);
  static double h2(context) => zoom(25.0, context);
  static double h3(context) => zoom(15.0, context);
  static double text(context) => zoom(13.0, context);
  static double small(context) => zoom(10.0, context);
  static double button(context) => zoom(15.0, context);
}

class MySizeStyle {
  static double design(size, context) => zoom(size, context);
  static double pageVertical(context) => zoom(60.0, context);
  static double pageHorizontal(context) => zoom(15.0, context);
  static double fullWidth(context) => MediaQuery.of(context).size.width;
}

class MyTextStyle {
  static TextStyle customStyle(context, { size = 13.0, color = MyColorStyle.foreground}) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MySizeStyle.design(size, context),
      decoration: TextDecoration.none,
      color: color);

  static TextStyle pageTitleStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h1(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.blackColor);

  static TextStyle titleStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h2(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.whiteColor);

  static TextStyle titleDarkStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h2(context),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
      color: MyColorStyle.secondaryColor);

  static TextStyle timeDarkStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: zoom(20.0, context),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
      color: MyColorStyle.secondaryColor);

  static TextStyle tagStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.text(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.whiteColor);

  static TextStyle tagPrimaryStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.text(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.primaryColor);

  static TextStyle tagDarkStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.text(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.secondaryColor);

  static TextStyle tagBoldStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.text(context),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold,
      color: MyColorStyle.secondaryColor);

  static TextStyle smallTagStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.small(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.secondaryColor);

  static TextStyle textStyle(context, {color = MyColorStyle.foreground, size = 13, sameWidth: false}) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: zoom(size, context),
      decoration: TextDecoration.none,
      fontFeatures: sameWidth ? [
        FontFeature.tabularFigures()
      ]: [],
      color: color);

  static TextStyle textWhiteStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.text(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.whiteColor);

  static TextStyle textBoldStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h3(context),
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold,
      color: MyColorStyle.secondaryColor);

  static TextStyle textPremiumStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.small(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.whiteColor);

  static TextStyle buttonStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.button(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.whiteColor);

  static TextStyle buttonDarkStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.button(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.foreground);

  static TextStyle buttonPrimaryStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.button(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.primaryColor);

  static TextStyle titlePrimaryStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h2(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.primaryColor);

  static TextStyle smallButtonDarkStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h3(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.foreground);

  static TextStyle smallButtonPrimaryStyle(context) => TextStyle(
      fontFamily: "Visbyround",
      fontSize: MyFontStyle.h3(context),
      decoration: TextDecoration.none,
      color: MyColorStyle.primaryColor);
}
