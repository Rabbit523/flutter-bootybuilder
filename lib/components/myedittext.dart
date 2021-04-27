import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/components/style.dart';

class MyEditText extends StatefulWidget {
  final String text;
  final String placeholder;
  final TextEditingController textController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final onFieldSubmitted;
  final validator;
  final isSettingWorkout;

  MyEditText({
    Key key,
    this.text = "",
    this.placeholder = "Place input a value.",
    this.textController,
    this.validator,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.isSettingWorkout = false,
  }) : super(key: key);

  @override
  _MyEditTextState createState() => _MyEditTextState();
}

class _MyEditTextState extends State<MyEditText> {
  int _status;
  FocusNode _myFocusNode;
  bool _focus = false;

  @override
  void initState() {
    super.initState();

    _myFocusNode = FocusNode();
    _focus = false;

    _myFocusNode.addListener(() {
      this.setState(() {
        if (_focus != _myFocusNode.hasFocus) {
          _focus = _myFocusNode.hasFocus;
        }
      });
    });
  }

  void requestFocus() {
    _myFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _myFocusNode.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        height: MySizeStyle.design(45, context),
        padding:
            EdgeInsets.symmetric(horizontal: MySizeStyle.design(20, context)),
        decoration: BoxDecoration(
            color: MyColorStyle.whiteColor,
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
            boxShadow: [
              BoxShadow(
                color: MyColorStyle.foreground.withOpacity(0.5),
                spreadRadius: MySizeStyle.design(-24.0, context),
                blurRadius: MySizeStyle.design(24.0, context),
                offset: Offset(
                  0,
                  MySizeStyle.design(24.0, context),
                ), // changes position of shadow
              ),
            ]),
        child: Center(
          child: TextFormField(
            validator: (value) {
              if (widget.validator != null) {
                return widget.validator(value);
              }
              return null;
            },
            maxLines: 1,
            textInputAction: widget.textInputAction,
            onSaved: (input) => input,
            style: MyTextStyle.buttonDarkStyle(context),
            textAlign: TextAlign.start,
            controller: widget.textController,
            keyboardType: widget.isSettingWorkout
                ? TextInputType.number
                : widget.textInputType,
            autocorrect: false,
            autofocus: false,
            cursorColor: MyColorStyle.foreground,
            focusNode: _myFocusNode,
            textCapitalization: widget.textCapitalization,
            decoration: InputDecoration(
                contentPadding:
                    widget.isSettingWorkout ? EdgeInsets.only(left: 15) : null,
                border: widget.isSettingWorkout
                    ? OutlineInputBorder()
                    : InputBorder.none,
                focusedBorder: widget.isSettingWorkout
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      )
                    : InputBorder.none,
                enabledBorder: widget.isSettingWorkout
                    ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      )
                    : InputBorder.none,
                errorBorder: InputBorder.none,
                alignLabelWithHint: widget.isSettingWorkout,
                disabledBorder: InputBorder.none,
                labelText: widget.text,
                labelStyle: MyTextStyle.buttonDarkStyle(context),
                hintStyle: MyTextStyle.buttonDarkStyle(context),
                hintText: widget.placeholder),
            onFieldSubmitted: (v) {
              if (widget.onFieldSubmitted != null) {
                widget.onFieldSubmitted(v);
              }
            },
          ),
        ));
  }
}
