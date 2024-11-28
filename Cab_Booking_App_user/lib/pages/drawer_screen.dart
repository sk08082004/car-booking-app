import 'package:flutter/material.dart';
import 'package:user_app/pages/home_page.dart';
import 'package:user_app/pages/profile_screen.dart';
import 'package:user_app/pages/setting_screen.dart';
import 'package:user_app/global/global_var.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: Colors.white, // White background for the drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              accountName: Text(userName, style: const TextStyle(color: Colors.black)),
              accountEmail: Text(userModelCurrentInfo?.email ?? 'No email', style: const TextStyle(color: Colors.black)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.yellow.shade700, // Yellow header background
              ),
            ),
            
            // Drawer Items
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue), // Blue icon for Home
              title: const Text('Home', style: TextStyle(color: Colors.black)), // Black text for Home
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue), // Blue icon for Profile
              title: const Text('Profile', style: TextStyle(color: Colors.black)), // Black text for Profile
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue), // Blue icon for Settings
              title: const Text('Settings', style: TextStyle(color: Colors.black)), // Black text for Settings
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.blue), // Blue icon for Log Out
              title: const Text('Log Out', style: TextStyle(color: Colors.black)), // Black text for Log Out
              onTap: () {
                // Log out functionality
                firebaseAuth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
