import 'package:firebase_sample/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoundedBottomButton extends StatelessWidget {
  RoundedBottomButton({
    @required this.isEnable,
    @required this.title,
    @required this.onPressed,
    @required this.color,
    this.vertical = 10.0,
  });

  final bool isEnable;
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
        child: SizedBox(
          height: 50,
          width: size.width * .9,
          child: RaisedButton(
            disabledColor: color,
            color: color,
            onPressed: isEnable ? onPressed : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              title,
              style: isEnable
                  ? const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    )
                  : const TextStyle(
                      fontSize: 20.0,
                      color: white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    @required this.title,
    @required this.color,
    @required this.radius,
    @required this.onPressed,
    @required this.style,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) : padding = padding;

  final String title;
  final Color color;
  final VoidCallback onPressed;
  final double radius;
  final EdgeInsets padding;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding,
        child: Text(
          title,
          style: style,
        ),
      ),
    );
  }
}

class RoundedHeaderButton extends StatelessWidget {
  const RoundedHeaderButton({
    this.width,
    this.height,
    this.title,
    this.onPressed,
    this.fontSize,
  });

  final double width;
  final double height;
  final String title;
  final VoidCallback onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: RaisedButton(
        child: Text(
          title,
          style: TextStyle(
            color: black,
            fontSize: fontSize,
          ),
        ),
        color: ROUNDED_BUTTON_COLOR,
        shape: const StadiumBorder(
          side: BorderSide(color: Colors.transparent),
        ),
        elevation: 0,
        onPressed: onPressed,
      ),
    );
  }
}
