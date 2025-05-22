import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        backgroundColor: const Color(0xFF005D99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.gavel,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_formatDate(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Terms and Conditions Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('1. Acceptance of Terms'),
                    _buildParagraph(
                      'By accessing or using the COMSATS University Islamabad Complaints Management System (the "Service"), you agree to be bound by these Terms and Conditions. If you disagree with any part of the terms, you may not access the Service.',
                    ),

                    _buildSectionTitle('2. User Registration and Accounts'),
                    _buildParagraph(
                      '2.1. To use certain features of the Service, you must register for an account. When you register, you must provide accurate and complete information.',
                    ),
                    _buildParagraph(
                      '2.2. You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password.',
                    ),
                    _buildParagraph(
                      '2.3. You agree not to disclose your password to any third party. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.',
                    ),
                    _buildParagraph(
                      '2.4. You may not use as a username the name of another person or entity that is not lawfully available for use, or a name or trademark that is subject to any rights of another person or entity without appropriate authorization.',
                    ),

                    _buildSectionTitle('3. User Conduct'),
                    _buildParagraph(
                      '3.1. You agree to use the Service only for lawful purposes and in a way that does not infringe the rights of, restrict, or inhibit anyone else\'s use and enjoyment of the Service.',
                    ),
                    _buildParagraph(
                      '3.2. Prohibited behavior includes but is not limited to:',
                    ),
                    _buildListItem('Submitting false or misleading complaints'),
                    _buildListItem('Harassing, threatening, or intimidating others'),
                    _buildListItem('Impersonating any person or entity'),
                    _buildListItem('Uploading viruses or other malicious code'),
                    _buildListItem('Attempting to gain unauthorized access to the Service'),
                    _buildListItem('Interfering with the proper working of the Service'),

                    _buildSectionTitle('4. Complaints Submission'),
                    _buildParagraph(
                      '4.1. When submitting a complaint through the Service, you must provide accurate, current, and complete information.',
                    ),
                    _buildParagraph(
                      '4.2. You understand that any complaint you submit may be reviewed by university administrators and relevant staff members.',
                    ),
                    _buildParagraph(
                      '4.3. You agree not to submit complaints that are frivolous, vexatious, made in bad faith, or without reasonable grounds.',
                    ),
                    _buildParagraph(
                      '4.4. The university reserves the right to prioritize complaints based on urgency and severity.',
                    ),

                    _buildSectionTitle('5. Content Ownership and Responsibility'),
                    _buildParagraph(
                      '5.1. You retain ownership of any content you submit through the Service, including text, images, and other materials ("User Content").',
                    ),
                    _buildParagraph(
                      '5.2. By submitting User Content, you grant COMSATS University Islamabad a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, adapt, publish, and display such content for the purpose of providing and improving the Service.',
                    ),
                    _buildParagraph(
                      '5.3. You represent and warrant that you own or have the necessary rights to the User Content you submit, and that such content does not violate the rights of any third party.',
                    ),

                    _buildSectionTitle('6. Privacy Policy'),
                    _buildParagraph(
                      '6.1. Your use of the Service is also governed by our Privacy Policy, which is incorporated by reference into these Terms and Conditions.',
                    ),
                    _buildParagraph(
                      '6.2. The Privacy Policy explains how we collect, use, and protect your personal information when you use the Service.',
                    ),

                    _buildSectionTitle('7. Limitation of Liability'),
                    _buildParagraph(
                      '7.1. COMSATS University Islamabad, its administrators, faculty, staff, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your access to or use of, or inability to access or use, the Service.',
                    ),
                    _buildParagraph(
                      '7.2. The Service is provided on an "AS IS" and "AS AVAILABLE" basis, without any warranties of any kind, either express or implied.',
                    ),

                    _buildSectionTitle('8. Termination'),
                    _buildParagraph(
                      '8.1. We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms and Conditions.',
                    ),
                    _buildParagraph(
                      '8.2. Upon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may simply discontinue using the Service.',
                    ),

                    _buildSectionTitle('9. Changes to Terms'),
                    _buildParagraph(
                      '9.1. We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days\' notice prior to any new terms taking effect.',
                    ),
                    _buildParagraph(
                      '9.2. By continuing to access or use our Service after those revisions become effective, you agree to be bound by the revised terms.',
                    ),

                    _buildSectionTitle('10. Governing Law'),
                    _buildParagraph(
                      '10.1. These Terms shall be governed and construed in accordance with the laws of Pakistan, without regard to its conflict of law provisions.',
                    ),
                    _buildParagraph(
                      '10.2. Any disputes arising under or in connection with these Terms shall be subject to the exclusive jurisdiction of the courts located within Islamabad, Pakistan.',
                    ),

                    _buildSectionTitle('11. Contact Information'),
                    _buildParagraph(
                      'If you have any questions about these Terms, please contact us at:',
                    ),
                    _buildContactInfo('Email', 'legal@comsats.edu.pk'),
                    _buildContactInfo('Phone', '+92-51-9247000'),
                    _buildContactInfo('Address', 'COMSATS University Islamabad, Park Road, Tarlai Kalan, Islamabad 45550, Pakistan'),

                    const SizedBox(height: 40),

                    // Accept Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005D99),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'I Accept These Terms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF005D99),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF005D99),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey[800],
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF005D99),
              ),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
