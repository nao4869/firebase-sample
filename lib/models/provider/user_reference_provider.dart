import 'package:flutter/material.dart';

class UserReferenceProvider with ChangeNotifier {
  UserReferenceProvider({
    this.referenceToUser,
    this.userSettingsReference,
    this.currentParentCategoryIdReference,
    this.todoFontSize,
    this.isDisplayCompletedTodo,
    this.isDisplayOnlyCompletedTodo,
    this.isSortByCreatedAt,
    this.isSortCategoryByCreatedAt,
    this.isDisplayCheckBox,
    this.isDisplayCreatedAt,
  });

  String referenceToUser;
  String userSettingsReference;
  String currentParentCategoryIdReference;
  double todoFontSize;
  bool isDisplayCompletedTodo;
  bool isDisplayOnlyCompletedTodo;
  bool isSortByCreatedAt;
  bool isSortCategoryByCreatedAt;
  bool isDisplayCheckBox;
  bool isDisplayCreatedAt;

  void initializeUserSettings({
    String userReference,
    String userSettingsReference,
    bool isDisplayCompletedTodo,
    bool isDisplayOnlyCompletedTodo,
    bool isSortByCreatedAt,
    bool isSortCategoryByCreatedAt,
    bool isDisplayCheckBox,
    bool isDisplayCreatedAt = false,
    String currentParentCategoryIdReference,
    double todoFontSize,
  }) {
    this.referenceToUser = userReference;
    this.userSettingsReference = userSettingsReference;
    this.isDisplayCompletedTodo = isDisplayCompletedTodo;
    this.isDisplayOnlyCompletedTodo = isDisplayOnlyCompletedTodo;
    this.isSortByCreatedAt = isSortByCreatedAt;
    this.isSortCategoryByCreatedAt = isSortCategoryByCreatedAt;
    this.isDisplayCheckBox = isDisplayCheckBox;
    this.isDisplayCreatedAt = isDisplayCreatedAt;
    this.currentParentCategoryIdReference = currentParentCategoryIdReference;
    this.todoFontSize = todoFontSize;
  }

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

  void updateIsDisplayCheckBox(bool updated) {
    isDisplayCheckBox = updated;
  }

  void updateIsDisplayCreatedAt(bool updated) {
    isDisplayCreatedAt = updated;
  }

  void updateIsSortCategoryByCreatedAt(bool updated) {
    isSortCategoryByCreatedAt = updated;
  }

  void updateParentCategoryReference(String newReference) {
    currentParentCategoryIdReference = newReference;
  }

  void updateTodoFontSize(newFontSize) {
    todoFontSize = newFontSize;
  }
}
