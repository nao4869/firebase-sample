import 'package:flutter/material.dart';

import 'colors.dart';

const whiteBorderDecoration = BoxDecoration(
  shape: BoxShape.circle,
  border: Border.fromBorderSide(
    BorderSide(color: Colors.white, width: 3.0),
  ),
);

const blackBorderDecoration = BoxDecoration(
  shape: BoxShape.circle,
  border: Border.fromBorderSide(
    BorderSide(color: darkBlack, width: 3.0),
  ),
);

const greyBoxShadowDecoration = BoxDecoration(
  shape: BoxShape.circle,
  boxShadow: [
    BoxShadow(color: Colors.grey, blurRadius: 1.0, spreadRadius: 1.0)
  ],
);
