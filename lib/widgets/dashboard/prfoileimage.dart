import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class ProfileImageProvider extends ChangeNotifier {
  ValueNotifier<File?> profileImageNotifier = ValueNotifier<File?>(null);

  /// Load profile image from Hive
  Future<void> loadProfileImage() async {
    final box = await Hive.openBox('userBox');
    final base64Image = box.get('profileImage');
    if (base64Image != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/profileImage.png');
      await file.writeAsBytes(base64Decode(base64Image));
      profileImageNotifier.value = file;
    }
  }

  /// Save profile image to Hive
  Future<void> updateProfileImage(File imageFile) async {
    final box = await Hive.openBox('userBox');
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    await box.put('profileImage', base64Image);

    profileImageNotifier.value = imageFile;
  }

  /// Clear image cache
  void clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }
}
