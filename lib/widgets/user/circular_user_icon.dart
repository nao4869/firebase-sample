import 'dart:io';
import 'package:firebase_sample/constants/texts.dart';
import 'package:flutter/material.dart';

class CircularUserIcon extends StatelessWidget {
  const CircularUserIcon({
    this.iconSize = .14,
    this.imageFile,
    this.imagePath,
  });

  final double iconSize;
  final File imageFile;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final image = setImageWidget();
    return SizedBox(
      width: size.width * iconSize,
      height: size.width * iconSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: image,
      ),
    );
  }

  Widget setImageWidget() {
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
