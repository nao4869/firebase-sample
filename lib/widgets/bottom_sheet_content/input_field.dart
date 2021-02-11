import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  InputField({
    this.onChanged,
    this.height = .3,
    this.width = .9,
  });

  final Function(String) onChanged;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 5),
      child: SizedBox(
        height: size.width * height,
        width: size.width * width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: TextField(
            maxLines: 20,
            autofocus: true,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
