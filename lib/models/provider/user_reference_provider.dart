import 'package:flutter/material.dart';

class UserReferenceProvider with ChangeNotifier {
  UserReferenceProvider({
    this.referenceToUser,
    this.userSettingsReference,
    this.currentParentCategoryIdReference,
    this.isDisplayCompletedTodo,
    this.isDisplayOnlyCompletedTodo,
    this.isSortByCreatedAt,
    this.isSortCategoryByCreatedAt,
  });

  String referenceToUser;
  String userSettingsReference;
  String currentParentCategoryIdReference;
  bool isDisplayCompletedTodo;
  bool isDisplayOnlyCompletedTodo;
  bool isSortByCreatedAt;
  bool isSortCategoryByCreatedAt;

  void updateUserReference(String newUserReference) {
    referenceToUser = newUserReference;
  }

  void updateUserSettingsReference(String newUserSettingsReference) {
    userSettingsReference = newUserSettingsReference;
  }

  void updateCompletedTodo(bool updated) {
    isDisplayCompletedTodo = updated;
  }

  void updateIsDisplayOnlyCompletedTodo(bool updated) {
    isDisplayOnlyCompletedTodo = updated;
  }

  void updateIsSortByCreatedAt(bool updated) {
    isSortByCreatedAt = updated;
  }

  void updateIsSortCategoryByCreatedAt(bool updated) {
    isSortCategoryByCreatedAt = updated;
  }

  void updateParentCategoryReference(String newReference) {
    currentParentCategoryIdReference = newReference;
  }
}
