import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/main.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const SettingsForm(),
      backgroundColor: Colors.white,
      
    );
  }
}

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  bool _darkModeEnabled = false;
  bool _pushNotificationsEnabled = false;
  bool _emailNotificationsEnabled = false;
  bool _privacySettingsEnabled = false;
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in.');
      return;
    }

    try {
      final settings = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (settings.exists) {
        setState(() {
          _darkModeEnabled = settings['darkMode'] ?? false;
          _pushNotificationsEnabled = settings['pushNotifications'] ?? false;
          _emailNotificationsEnabled = settings['emailNotifications'] ?? false;
          _privacySettingsEnabled = settings['privacySettings'] ?? false;
        });
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<void> _updateSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'darkMode': _darkModeEnabled,
        'pushNotifications': _pushNotificationsEnabled,
        'emailNotifications': _emailNotificationsEnabled,
        'privacySettings': _privacySettingsEnabled,
      }, SetOptions(merge: true));

      // Notify app about theme change
      if (_darkModeEnabled) {
        MyAppScreen.of(context).setDarkMode();
      } else {
        MyAppScreen.of(context).setLightMode();
      }
    } catch (e) {
      print('Failed to update settings: $e');
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in.');
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );

      _passwordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      print('Failed to change password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
        
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications',
                style: TextStyle(color: Colors.black87)),
            subtitle: const Text('Enable push notifications'),
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
                _updateSettings();
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email Notifications',
                style: TextStyle(color: Colors.black87)),
            subtitle: const Text('Enable email notifications'),
            value: _emailNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value;
                _updateSettings();
              });
            },
          ),
          const Divider(),
          const Text(
            'Privacy Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SwitchListTile(
            title: const Text('Privacy Settings',
                style: TextStyle(color: Colors.black87)),
            subtitle: const Text('Enable privacy settings'),
            value: _privacySettingsEnabled,
            onChanged: (value) {
              setState(() {
                _privacySettingsEnabled = value;
                _updateSettings();
              });
            },
          ),
          const Divider(),
          const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current Password'),
          ),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}
