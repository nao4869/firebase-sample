import 'package:firebase_sample/constants/texts.dart';
import 'package:flutter/material.dart';

extension SetImagePath on void {
  Widget setImagePath(
    String imagePath,
  ) {
    if (imagePath == null || imagePath == defaultPersonImage) {
      return Image.asset(
        'assets/images/default_profile_image.png',
        fit: BoxFit.cover,
      );
    } else if (imagePath.contains('person')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
      );
    }
  }
}
