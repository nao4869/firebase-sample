import 'package:firebase_sample/widgets/buttons/full_width_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCategoryBottomSheet extends StatelessWidget {
  AddCategoryBottomSheet({
    this.onPressed,
    this.title,
    this.onNameChange,
  });

  final VoidCallback onPressed;
  final String title;
  final Function(String) onNameChange;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: size.width * .2,
              width: size.width * .9,
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
                  onChanged: onNameChange,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: size.width,
            child: FullWidthButton(
              title: title,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
