import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:io';

class ProfileImageProvider extends ChangeNotifier {
  File? _profileImage;

  File? get profileImage => _profileImage;

  Future<void> loadProfileImage() async {
    final box = Hive.box('userBox');
    final imagePath = box.get('profileImagePath');
    if (imagePath != null) {
      _profileImage = File(imagePath);
      notifyListeners();
    }
  }

  Future<void> saveProfileImage(String path) async {
    final box = Hive.box('userBox');
    await box.put('profileImagePath', path);
    _profileImage = File(path);
    notifyListeners();
  }
}
