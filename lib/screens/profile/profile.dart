import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_app_final/screens/profile/about_us.dart';
import 'package:inventory_app_final/screens/profile/privacy.dart';
import 'package:inventory_app_final/screens/profile/term&condtion.dart';
import 'package:inventory_app_final/widgets/dashboard/prfoileimage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../model/product_user_model.dart';
import 'login.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final ValueNotifier<String> _userNameNotifier =
      ValueNotifier<String>('Guest');
  final ValueNotifier<String> _userEmailNotifier =
      ValueNotifier<String>('guest@example.com');

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileImageProvider>(context, listen: false)
          .loadProfileImage();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (imageFile.existsSync()) {
        final profileImageProvider =
            Provider.of<ProfileImageProvider>(context, listen: false);
        profileImageProvider.clearImageCache();
        await profileImageProvider.updateProfileImage(imageFile);
      } else {
        print('Invalid file selected.');
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDB = Hive.box<Userdatamodel>('login_db');
      if (userDB.isNotEmpty) {
        final user = userDB.values.first;
        _userNameNotifier.value = user.name;
        _userEmailNotifier.value = user.email;
      } else {
        print('No user data found.');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final box = Hive.box<Userdatamodel>('login_db');
      await box.delete('currentUserID');
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyLogin()),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileImageProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Section
                ValueListenableBuilder<File?>(
                  valueListenable: Provider.of<ProfileImageProvider>(context)
                      .profileImageNotifier,
                  builder: (context, profileImage, _) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage)
                            : const AssetImage('assets/images/28829132.jpg')
                                as ImageProvider,
                        child: profileImage == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder<String>(
                  valueListenable: _userNameNotifier,
                  builder: (context, userName, _) {
                    return Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: _userEmailNotifier,
                  builder: (context, userEmail, _) {
                    return Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Action Cards
                _buildActionCard(
                  icon: Icons.article_outlined,
                  title: 'Terms and Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildActionCard(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildActionCard(
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildActionCard(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
