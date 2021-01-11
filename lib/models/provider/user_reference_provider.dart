import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserReferenceProvider with ChangeNotifier {
  UserReferenceProvider({
    this.referenceToUser,
  });

  final DocumentSnapshot referenceToUser;
}
