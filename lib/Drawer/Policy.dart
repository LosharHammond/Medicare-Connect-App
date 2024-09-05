import 'package:flutter/material.dart';

class PolicyHelper extends StatelessWidget {
  const PolicyHelper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Privacy Policy'),
              _buildSectionContent(
                'Your privacy is important to us. This privacy statement explains the personal data Medicare Connect processes, how Medicare Connect processes it, and for what purposes.',
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Terms of Service'),
              _buildSectionContent(
                'By accessing or using our service, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the service.',
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Cookie Policy'),
              _buildSectionContent(
                'We use cookies to enhance your experience. You can choose to accept or decline cookies. Most web browsers automatically accept cookies, but you can modify your browser settings to decline cookies if you prefer.',
              ),
              SizedBox(height: 16),
              _buildSectionTitle('User Responsibilities'),
              _buildSectionContent(
                'Users are responsible for maintaining the confidentiality of their account and password and for restricting access to their device. Users agree to accept responsibility for all activities that occur under their account or password.',
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Contact Us'),
              _buildSectionContent(
                'If you have any questions about these policies, please contact us at support@medicareconnect.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Policies',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
