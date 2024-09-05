import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/main.dart'; // Import MyAppScreen class

class TermsHelper extends StatefulWidget {
  const TermsHelper({super.key});

  @override
  State<TermsHelper> createState() => _TermsHelperState();
}

class _TermsHelperState extends State<TermsHelper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool? _userAgreed; // To store user's choice
  bool _isLoading = true; // To handle loading state

  static const String _termsAndConditions = '''
  **Introduction**

Welcome to Medicare Connect! These Terms and Conditions outline the rules and regulations for using the Medicare Connect app. By accessing or using our app, you agree to be bound by these Terms and Conditions.

**Use of the App**

You must be at least 18 years old to use this app. By using the app, you represent and warrant that you have the right, authority, and capacity to enter into this agreement and to abide by all of the terms and conditions of this agreement.

**Account Registration**

To access certain features of the app, you must create an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete. 

**User Responsibilities**

You are responsible for your use of the app and for any consequences thereof. You agree to use the app in compliance with all applicable local, state, national, and international laws, rules, and regulations. 

**Privacy Policy**

Our Privacy Policy explains how we collect, use, and disclose information that pertains to your privacy. By agreeing to these Terms, you agree to our Privacy Policy

**Intellectual Property Rights**

All content, trademarks, and data on this app, including software, databases, text, graphics, icons, hyperlinks, private information, designs, and agreements, are the property of or licensed to Medicare Connect and as such are protected from infringement by local and international legislation and treaties. 

**Prohibited Activities**

We may update our Terms and Conditions from time to time. We will notify you of any changes by posting the new Terms and Conditions on this page. You are advised to review this Terms and Conditions periodically for any changes.

You agree not to engage in any of the following prohibited activities:

(a) copying, distributing, or disclosing any part of the app in any medium;

(b) using any automated system to access the app;

(c) transmitting spam, chain letters, or other unsolicited email;

(d) attempting to interfere with, compromise the system integrity or security, or decipher any transmissions to or from the servers running the app.

**Limitation of Liability**

To the fullest extent permitted by applicable law, in no event shall Medicare Connect, its affiliates, directors, employees, or agents be liable for any direct, indirect, punitive, incidental, special, consequential, or exemplary damages, including without limitation damages for loss of profits, goodwill, use, data, or other intangible losses, that result from the use of, or inability to use, this app.

**Indemnification**

You agree to indemnify and hold harmless Medicare Connect and its affiliates, and their directors, officers, employees, and agents, from and against any and all claims, damages, obligations, losses, liabilities, costs, or debt, and expenses (including but not limited to attorney’s fees) arising from:

(a) your use of and access to the app;

(b) your violation of any term of these Terms and Conditions;

(c) your violation of any third-party right, including without limitation any copyright, property, or privacy right;

(d) any claim that your use of the app caused damage to a third party.  

**Changes to the Terms**

Medicare Connect reserves the right, in its sole discretion, to modify or replace these Terms and Conditions at any time. We will provide notice of any changes by posting the new terms on the app. Your continued use of the app following the posting of any changes constitutes acceptance of those changes. If you do not agree with the new terms, please stop using the app.

**Governing Law**

These Terms and Conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which Medicare Connect is based, without regard to its conflict of law principles. Any disputes arising from these Terms and Conditions or the use of the app will be subject to the exclusive jurisdiction of the courts located within that jurisdiction. 

**Termination**

Medicare Connect reserves the right to terminate or suspend your access to the app immediately, without prior notice or liability, for any reason whatsoever, including, without limitation, if you breach these Terms and Conditions. Upon termination, your right to use the app will cease immediately. 

**Contact Us**

If you have any questions or concerns about these Terms and Conditions, please contact us at [support@medicareconnect.com](mailto:support@medicareconnect.com) or +233557297728/ +233505264636  

**Miscellaneous**

If any provision of these Terms and Conditions is found to be unenforceable or invalid, the remaining provisions of these Terms and Conditions will remain in effect. These Terms and Conditions constitute the entire agreement between us regarding our app, and supersede and replace any prior agreements we might have had between us regarding the app.  By using Medicare Connect, you agree to these Terms and Conditions.

  ''';

  @override
  void initState() {
    super.initState();
    _checkUserResponse(); // Check if the user has already made a choice
  }

  Future<void> _checkUserResponse() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc =
            await _firestore.collection('user_responses').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userAgreed = doc['agreedToTerms'] as bool?;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error fetching user response: $e');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user response: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserResponse(bool agreed) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('user_responses').doc(user.uid).set({
          'agreedToTerms': agreed,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _userAgreed = agreed;
        });
        if (agreed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyAppScreen(
                userEmail: user.email!,
                userName: user.displayName ?? '',
                userImageUrl: '',
              ),
            ),
          );
        } else {
          Navigator.pop(context); // Go back if the user disagrees
        }
      } catch (e) {
        print('Error saving user response: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save response. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Markdown(
                      data: _termsAndConditions,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, color: Colors.black87),
                        h1: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        h2: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _userAgreed == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _saveUserResponse(true);
                              },
                              child: const Text('Agree'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _saveUserResponse(false);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Disagree'),
                            ),
                          ],
                        )
                      : Text(
                          _userAgreed == true
                              ? 'You have agreed to the terms.'
                              : 'You have disagreed with the terms.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _userAgreed == true ? Colors.green : Colors.red,
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
