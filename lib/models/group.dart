import 'package:firebase_sample/models/category.dart';
import 'package:firebase_sample/models/user.dart';

class Group {
  final String id;
  final DateTime createdAt;
  final String name;
  final List<User> users;
  final List<Category> categories;

  Group({
    this.id,
    this.createdAt,
    this.name,
    this.users,
    this.categories,
  });
}
