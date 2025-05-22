import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF005D99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with University Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF005D99),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // University Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          'https://www.comsats.edu.pk/Images/CUI-Logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'CUI',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005D99),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'COMSATS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005D99),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'COMSATS UNIVERSITY ISLAMABAD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complaints Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About the University
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About the University'),
                  _buildParagraph(
                    'COMSATS University Islamabad (CUI) is one of the leading public sector universities in Pakistan, known for its excellence in research and higher education. Established in 1998, CUI has grown into a premier educational institution with multiple campuses across Pakistan.',
                  ),
                  _buildParagraph(
                    'The university offers undergraduate, graduate, and doctoral programs in various disciplines including engineering, computer science, business, and natural sciences. CUI is committed to providing quality education and fostering innovation through research and development.',
                  ),

                  const SizedBox(height: 24),

                  // About the App
                  _buildSectionTitle('About the Complaints System'),
                  _buildParagraph(
                    'The CUI Complaints Management System is designed to streamline the process of submitting and tracking complaints within the university. This application provides a user-friendly interface for students, faculty, and staff to report issues and track their resolution status.',
                  ),
                  _buildParagraph(
                    'Our goal is to improve communication between the university community and administration, ensuring that all concerns are addressed promptly and efficiently. The system categorizes complaints, assigns them to relevant departments, and provides real-time updates on their status.',
                  ),

                  const SizedBox(height: 24),

                  // Mission & Vision
                  _buildSectionTitle('Our Mission & Vision'),

                  // Mission
                  _buildSubsectionTitle('Mission'),
                  _buildParagraph(
                    'To create a transparent and efficient complaint resolution system that enhances the university experience for all stakeholders by addressing concerns promptly and effectively.',
                  ),

                  const SizedBox(height: 16),

                  // Vision
                  _buildSubsectionTitle('Vision'),
                  _buildParagraph(
                    'To establish a model complaint management system that fosters a responsive and accountable university environment, setting a standard for educational institutions across Pakistan.',
                  ),

                  const SizedBox(height: 24),

                  // Key Features
                  _buildSectionTitle('Key Features'),

                  // Features List
                  _buildFeatureItem('Easy complaint submission process'),
                  _buildFeatureItem('Real-time tracking of complaint status'),
                  _buildFeatureItem('Categorized complaint management'),
                  _buildFeatureItem('Secure and confidential handling of information'),
                  _buildFeatureItem('Efficient assignment to relevant departments'),
                  _buildFeatureItem('Analytics and reporting capabilities'),
                  _buildFeatureItem('User-friendly mobile interface'),

                  const SizedBox(height: 24),

                  // Development Team
                  _buildSectionTitle('Development Team'),
                  _buildParagraph(
                    'This application was developed by the Department of Computer Science at COMSATS University Islamabad. The team consists of faculty members and students dedicated to improving university services through technology.',
                  ),

                  const SizedBox(height: 16),

                  // Team Members
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTeamMember('Dr. Ahmed Khan', 'Project Lead'),
                      _buildTeamMember('Sarah Ali', 'Lead Developer'),
                      _buildTeamMember('Usman Malik', 'UI/UX Designer'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Acknowledgments
                  _buildSectionTitle('Acknowledgments'),
                  _buildParagraph(
                    'We would like to thank the university administration for their support and guidance throughout the development of this application. Special thanks to the IT department for their technical assistance and the student body for their valuable feedback during the testing phase.',
                  ),

                  const SizedBox(height: 32),

                  // Copyright Notice
                  Center(
                    child: Text(
                      '© ${DateTime.now().year} COMSATS University Islamabad. All Rights Reserved.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF005D99),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 3,
            color: const Color(0xFF005D99),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF005D99),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF005D99),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFF005D99),
          child: Text(
            name.substring(0, 1),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          role,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
