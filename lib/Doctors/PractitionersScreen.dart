import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PractitionersScreen extends StatelessWidget {
  const PractitionersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Practitioners',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('practitioners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No practitioners found.'));
          }

          final practitioners = snapshot.data!.docs;

          return ListView.builder(
            itemCount: practitioners.length,
            itemBuilder: (context, index) {
              final data = practitioners[index].data() as Map<String, dynamic>;

              return PractitionerCard(
                imageUrl:
                    data['imageUrl'] ?? 'https://example.com/placeholder.jpeg',
                userName: data['name'] ?? 'No name',
                userEmail: data['email'] ?? 'No email',
                job: data['job'] ?? 'No job',
                position: data['position'] ?? 'No position',
                about: data['about'] ?? 'No about info',
                contact: data['contact'] ?? 'No contact',
              );
            },
          );
        },
      ),
    );
  }
}

class PractitionerCard extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String userEmail;
  final String job;
  final String position;
  final String about;
  final String contact;

  const PractitionerCard({
    Key? key,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    required this.job,
    required this.position,
    required this.about,
    required this.contact,
  }) : super(key: key);

  Future<void> _makeCall(BuildContext context, String phoneNumber) async {
    if (await Permission.phone.request().isGranted) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showError(context, 'Could not launch the phone call.');
      }
    } else {
      _showError(context, 'Phone permission not granted.');
    }
  }

  Future<void> _sendSMS(BuildContext context, String phoneNumber) async {
    if (await Permission.sms.request().isGranted) {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showError(context, 'Could not launch SMS.');
      }
    } else {
      _showError(context, 'SMS permission not granted.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // Image on the left side
          Container(
            width: 100,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                bottomLeft: Radius.circular(12.0),
              ),
              image: DecorationImage(
                image: _getImageProvider(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Information on the right side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email: $userEmail',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Job: $job',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Position: $position',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'About: $about',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contact: $contact',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const Divider(height: 10, color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makeCall(context, contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.blue),
                        onPressed: () => _sendSMS(context, contact),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return const AssetImage('assets/practitioners/placeholder.jpeg');
    }
  }
}
