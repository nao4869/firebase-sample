import 'package:flutter/material.dart';

class UserReferenceProvider with ChangeNotifier {
  UserReferenceProvider({
    this.referenceToUser,
    this.isDisplayCompletedTodo,
  });

  String referenceToUser;
  bool isDisplayCompletedTodo;

  void updateUserReference(String newUserReference) {
    referenceToUser = newUserReference;
  }

  void updateCompletedTodo(bool updated) {
    isDisplayCompletedTodo = updated;
  }
}
