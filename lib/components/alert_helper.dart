import 'package:app/components/dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:app/components/style.dart';

enum AlertType {
  success,
  failure,
  delConfirm,
  addConfirm
}

class AlertHelper {
  final AlertType type;
  final confirmFn;
  final cancelFn;
  final title;
  final message;

  AlertHelper({this.type, this.title, this.message, this.cancelFn, this.confirmFn});

  alertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                type == AlertType.success ? successContent(context) :
                type == AlertType.delConfirm ? delConfirmContent(context) :
                type == AlertType.addConfirm ? addConfirmContent(context) : errorContent(context)
              ],
            ),
          );
        });
  }

  _cancelFn(BuildContext context) {
    Navigator.of(context).pop();
    if (this.cancelFn != null) {
      this.cancelFn();
    }
  }

  _onTap(context) {
    Navigator.of(context).pop();
    if (this.confirmFn != null) {
      this.confirmFn();
    }
  }
  addConfirmContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MySizeStyle.design(40, context)
          ),
          padding: EdgeInsets.only(
              left: MySizeStyle.design(20, context),
              right: MySizeStyle.design(20, context),
              bottom: MySizeStyle.design(40, context),
              top: MySizeStyle.design(60, context)
          ),
          decoration: BoxDecoration(
            color: MyColorStyle.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: MyTextStyle.titleDarkStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(5, context),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: MyTextStyle.textStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(20, context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DialogButton(text: "Close", color: MyColorStyle.foreground, onTap: () => _cancelFn(context),),
                  SizedBox(
                    width: MySizeStyle.design(5, context),
                  ),
                  DialogButton(text: "Add", color: MyColorStyle.primaryColor, onTap: () => _onTap(context),)
                ],
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MySizeStyle.design(80, context),
              height: MySizeStyle.design(80, context),
              decoration: BoxDecoration(
                color: MyColorStyle.successColor,
                borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(40, context))),
              ),
              child: Center(
                child: Icon(Icons.add, size: MySizeStyle.design(60, context), color: MyColorStyle.whiteColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  delConfirmContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MySizeStyle.design(40, context)
          ),
          padding: EdgeInsets.only(
              left: MySizeStyle.design(20, context),
              right: MySizeStyle.design(20, context),
              bottom: MySizeStyle.design(40, context),
              top: MySizeStyle.design(60, context)
          ),
          decoration: BoxDecoration(
            color: MyColorStyle.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: MyTextStyle.titleDarkStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(5, context),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: MyTextStyle.textStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(20, context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DialogButton(text: "Close", color: MyColorStyle.foreground, onTap: () => _cancelFn(context),),
                  SizedBox(
                    width: MySizeStyle.design(5, context),
                  ),
                  DialogButton(text: "Delete", color: MyColorStyle.errorColor, onTap: () => _onTap(context),)
                ],
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MySizeStyle.design(80, context),
              height: MySizeStyle.design(80, context),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(40, context))),
              ),
              child: Center(
                child: Icon(Icons.clear, size: MySizeStyle.design(60, context), color: MyColorStyle.whiteColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  errorContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MySizeStyle.design(40, context)
          ),
          padding: EdgeInsets.only(
              left: MySizeStyle.design(20, context),
              right: MySizeStyle.design(20, context),
              bottom: MySizeStyle.design(40, context),
              top: MySizeStyle.design(60, context)
          ),
          decoration: BoxDecoration(
            color: MyColorStyle.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: MyTextStyle.titleDarkStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(5, context),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: MyTextStyle.textStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(20, context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DialogButton(text: "Close", color: Colors.red, onTap: () => _cancelFn(context),)
                ],
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MySizeStyle.design(80, context),
              height: MySizeStyle.design(80, context),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(40, context))),
              ),
              child: Center(
                child: Icon(Icons.clear, size: MySizeStyle.design(60, context), color: MyColorStyle.whiteColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  successContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MySizeStyle.design(40, context)
          ),
          padding: EdgeInsets.only(
              left: MySizeStyle.design(20, context),
              right: MySizeStyle.design(20, context),
              bottom: MySizeStyle.design(40, context),
              top: MySizeStyle.design(60, context)
          ),
          decoration: BoxDecoration(
            color: MyColorStyle.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: MyTextStyle.titleDarkStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(5, context),
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: MyTextStyle.textStyle(context),
              ),
              SizedBox(
                height: MySizeStyle.design(20, context),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DialogButton(text: "Close", color: MyColorStyle.foreground, onTap: () => _cancelFn(context),)
                ],
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MySizeStyle.design(80, context),
              height: MySizeStyle.design(80, context),
              decoration: BoxDecoration(
                color: MyColorStyle.successColor,
                borderRadius: BorderRadius.all(Radius.circular(MySizeStyle.design(40, context))),
              ),
              child: Center(
                child: Icon(Icons.check, size: MySizeStyle.design(60, context), color: MyColorStyle.whiteColor,),
              ),
            )
          ],
        )
      ],
    );
  }
}