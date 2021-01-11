import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    this.formKey,
    this.onValidate,
    this.onChanged,
    this.resetTextField,
    this.controller,
    this.height,
    this.hintText,
    this.counterText,
    this.initialValue,
    this.maxLines,
    this.isNumber = false,
  });

  final GlobalKey<FormState> formKey;
  final String Function(String) onValidate;
  final ValueChanged<String> onChanged;
  final VoidCallback resetTextField;
  final TextEditingController controller;
  final double height;
  final String hintText;
  final String counterText;
  final String initialValue;
  final int maxLines;
  final bool isNumber;

  @override
  Widget build(BuildContext context) {
    final buttonSize = 20.0;

    return Form(
      key: formKey,
      child: SizedBox(
        height: height,
        child: TextFormField(
          style: TextStyle(
            color: Colors.black,
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          scrollPadding: const EdgeInsets.all(100.0),
          autovalidate: true,
          onChanged: onChanged,
          initialValue: initialValue,
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          maxLength: 140,
          decoration: InputDecoration(
            counterText: counterText ?? '',
            counterStyle: const TextStyle(
              fontSize: 15.0,
            ),
            isDense: true,
            labelText: hintText,
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            hintStyle: TextStyle(
              color: Colors.black,
            ),
            suffix: SizedBox(
              height: buttonSize,
              width: buttonSize,
              child: RawMaterialButton(
                onPressed: () {
                  resetTextField == null
                      ? WidgetsBinding.instance.addPostFrameCallback(
                          (_) => controller.clear(),
                        )
                      : resetTextField();
                },
                child: Icon(
                  Icons.clear,
                  color: Colors.grey,
                  size: buttonSize,
                ),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue,
                width: 1,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorStyle: const TextStyle(
              fontSize: 10.0,
              color: Colors.red,
            ),
          ),
          validator: onValidate,
        ),
      ),
    );
  }
}
