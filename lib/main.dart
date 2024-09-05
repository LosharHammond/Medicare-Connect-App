import 'package:convex_bottom_bar/convex_bottom_bar.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:image_picker/image_picker.dart';
import 'package:medicare/Drawer/History.dart';
import 'package:medicare/Emergency/Emergency.dart';
import 'package:medicare/Health_Newz/Health_info.dart';
import 'package:medicare/Prediction/Inputs.dart';
import 'package:medicare/Drawer/Policy.dart';
import 'package:medicare/Doctors/PractitionersScreen.dart';
import 'package:medicare/Drawer/Settings.dart';
import 'package:medicare/Drawer/Terms.dart';
import 'package:medicare/Drawer/Reports.dart';
import 'package:medicare/Auth/loginPage.dart';
import 'package:medicare/Auth/signUp.dart';
import 'Auth/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart'; // Added import for SvgPicture

const routeHome = '/';
const routeSettings = '/settings';
const routeHealthInfo = '/HealthInfo';
const routeEmergency = '/Emergency';
const routePolicy = '/Policy';
const routeTerms = '/term';
const routeReports = '/report';
const String routeHistory = '/history';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCare',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
        ),
        // This will use the system theme setting
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: routeHome,
      onGenerateRoute: (settings) {
        late Widget page;

        switch (settings.name) {
          case routeHome:
            page = LoginPage();
            break;
          case routeSettings:
            page = const SettingsScreen();
            break;
          case routeTerms:
            page = const TermsScreen();
            break;
          case routeReports:
            page = const ReportsScreen();
            break;
          
          case routePolicy:
            page = const PolicyScreen();
            break;
          default:
            throw Exception('Unknown route: ${settings.name}');
        }

        return MaterialPageRoute<dynamic>(
          builder: (context) => page,
          settings: settings,
        );
      },
      home: const LoginPage(),
    );
  }
}



class NavBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userImageUrl;
  final Future<void> Function(String) updateUserName;
  final Future<void> Function(String) updateProfileImage;

  const NavBar({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
    required this.updateUserName,
    required this.updateProfileImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.blue, fontFamily: 'Oswald', fontSize: 15),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showUpdateNameDialog(context);
                    },
                  ),
                ],
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(
                    color: Colors.blue, fontFamily: 'Oswald', fontSize: 15),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.network(
                    userImageUrl,
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://th.bing.com/th/id/R.1628e37a62c47f046da5fa08e897450f?rik=TZjbPqd2r6S47g&pid=ImgRaw&r=0',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.black),
              title: const Text(
                'Terms and Conditions',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushNamed(context, routeTerms);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.black),
              title: const Text(
                'Policies',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushNamed(context, routePolicy);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.black),
              title: const Text(
                'Report',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushNamed(context, routeReports);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.black),
              title: const Text(
                'History',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PredictionHistoryScreen(),
                  ),
                );
              },
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushNamed(context, routeSettings);
              },
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.signpost_outlined, color: Colors.black),
              title: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.black),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
              ),
              onTap: () {
                _confirmDeleteAccount(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = userName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.of(context).pop();
                  await updateUserName(newName);
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  
  

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteAccount(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Show a dialog to prompt the user for their password
        String? password = await _showPasswordPrompt(context);
        if (password == null || password.isEmpty) {
          // User cancelled the prompt or entered an empty password
          return;
        }

        // Re-authenticate the user with the entered password
        final userCredential = await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          ),
        );

        if (userCredential.user != null) {
          await user.delete();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account deleted successfully.")),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please log in again to delete your account."),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.message}"),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected error occurred.")),
        );
      }
    }
  }

// Function to show a dialog to prompt the user for their password
  Future<String?> _showPasswordPrompt(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    String? enteredPassword;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                enteredPassword = passwordController.text;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return enteredPassword;
  }
}

class _predictedDiseases {}

class MyAppScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userImageUrl;

  const MyAppScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  _MyAppScreenState createState() => _MyAppScreenState();

  static of(BuildContext context) {}
}

class _MyAppScreenState extends State<MyAppScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _userName;
  late String _userEmail;
  late String _userImageUrl;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize user details
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _userImageUrl = widget.userImageUrl;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _updateUserName(String newName) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;

    if (user != null) {
      try {
        // Update the user's display name in Firebase Auth
        await user.updateProfile(displayName: newName);
        print('Updated display name in Firebase Auth');

        // Update the user's name in Firestore
        await firestore.collection('users').doc(user.uid).update({
          'name': newName,
        });
        print('Updated user name in Firestore');

        // Update state to reflect the new name
        setState(() {
          _userName = newName;
        });

        // Notify user of successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User name updated successfully')),
        );
      } catch (e) {
        print('Failed to update user name: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user name: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Current index: $_currentIndex'); // Debugging line

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'MediCare Connect',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Oswald',
          ),
          textAlign: TextAlign.center,
        ),
        foregroundColor: Colors.white,
      ),
      drawer: NavBar(
        userName: _userName,
        userEmail: _userEmail,
        userImageUrl: _userImageUrl,
        updateUserName: _updateUserName,
        updateProfileImage: _updateProfileImage,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DiseasePredictionScreen(),
          const HealthInfoScreen(),
          EmergencyScreen2(),
          const PractitionersScreen(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        items: const [
          TabItem(
            activeIcon: Icon(
              Icons.insights,
              color: Colors.white,
            ),
            title: 'Predict',
            icon: Icons.insights_outlined,
          ),
          TabItem(
            activeIcon: Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
            ),
            title: 'Health Info',
            icon: Icons.health_and_safety,
          ),
          TabItem(
            activeIcon: Icon(
              Icons.emergency,
              color: Colors.white,
            ),
            title: 'Emergency',
            icon: Icons.emergency_outlined,
          ),
          TabItem(
            activeIcon: Icon(
              Icons.people,
              color: Colors.white,
            ),
            title: 'Practitioners',
            icon: Icons.people_outline,
          ),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        curve: Curves.bounceIn,
        elevation: 10,
       // shadowColor: Colors.white,
        height: 70,
        style: TabStyle.reactCircle,
        backgroundColor: Colors.lightBlue[50], // Change the background color here
        color: Colors.black87, // Color of inactive icons and text
        activeColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileImage(String imageUrl) async {
    setState(() {
      _userImageUrl = imageUrl;
    });
  }

  AnimatedNotchBottomBar(
      {required PageController pageController,
      required List bottomBarItems,
      required Null Function(int value) onTap,
      required bool showLabel,
      required TextStyle itemLabelStyle,
      required bool showBlurBottomBar,
      required double blurOpacity,
      required double blurFilterX,
      required double blurFilterY}) {}

  BottomBarItems(
      {required Icon inActiveItem,
      required Icon activeItem,
      required String itemLabel}) {}
}

class SvgPicture {
  static asset(String s, {required MaterialColor color}) {}
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SettingScreen(),
    );
  }
}

class HealthInfoScreen extends StatelessWidget {
  const HealthInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NewsFeedScreen(),
    );
  }
}

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmergencyScreen2(),
    );
  }
}

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PolicyHelper(),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ReportsHelper(),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TermsHelper(),
    );
  }
}


