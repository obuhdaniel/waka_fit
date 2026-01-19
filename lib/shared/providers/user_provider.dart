import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? name;
  String? username;
  String? profileImageUrl;

  bool get isInitialized => name != null;

  void setUser({
    required String name,
    required String username,
    required String profileImageUrl,
  }) {
    this.name = name;
    this.username = username;
    this.profileImageUrl = profileImageUrl;
    notifyListeners();
  }

  void clearUser() {
    name = null;
    username = null;
    profileImageUrl = null;
    notifyListeners();
  }
}
