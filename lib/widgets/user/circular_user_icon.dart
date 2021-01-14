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
    return SizedBox(
      width: size.width * iconSize,
      height: size.width * iconSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: imagePath == null || imagePath == defaultPersonImage
            ? Image.asset(
                'assets/images/default_profile_image.png',
                fit: BoxFit.cover,
              )
            : Image.network(
                imagePath,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
