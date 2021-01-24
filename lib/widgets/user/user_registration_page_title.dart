import 'package:flutter/material.dart';

class UserRegistrationPageTitle extends StatelessWidget {
  UserRegistrationPageTitle({
    this.title,
    this.fontSize = 20,
  });

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
