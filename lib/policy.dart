import 'package:flutter/material.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Privacy Policy & Terms'),
        backgroundColor: const Color(0xFF005D99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.policy,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Privacy Policy & Terms of Use',
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

            const SizedBox(height: 24),

            // Policy Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Introduction'),
                  _buildParagraph(
                    'Welcome to the COMSATS University Islamabad Complaints Management System. This Privacy Policy and Terms of Use document outlines how we collect, use, and protect your information when you use our application, as well as the terms governing your use of the service.',
                  ),
                  _buildParagraph(
                    'By using this application, you agree to the collection and use of information in accordance with this policy. We will not use or share your information with anyone except as described in this Privacy Policy.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Information Collection and Use'),
                  _buildParagraph(
                    'For a better experience while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to your name, email address, student ID, and contact information. The information that we collect will be used to contact or identify you, process your complaints, and improve our services.',
                  ),
                  _buildParagraph(
                    'We may also collect information that your browser sends whenever you visit our Service or when you access the Service by or through a mobile device.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Data Storage and Security'),
                  _buildParagraph(
                    'We value your trust in providing us your personal information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.',
                  ),
                  _buildParagraph(
                    'Your data is stored securely on our servers and is only accessible to authorized personnel who need the information to perform their official duties. We implement appropriate technical and organizational measures to protect your personal data against unauthorized or unlawful processing, accidental loss, destruction, or damage.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('User Rights and Data Access'),
                  _buildParagraph(
                    'You have the right to access, update, or delete the information we have on you. Whenever made possible, you can:',
                  ),
                  _buildListItem('Access and update your personal information directly within the app'),
                  _buildListItem('Request to see what personal data we have about you'),
                  _buildListItem('Request that we correct any inaccurate data about you'),
                  _buildListItem('Request that we delete your personal data when it is no longer necessary'),
                  _buildListItem('Object to our processing of your personal data'),

                  _buildParagraph(
                    'If you wish to exercise any of these rights, please contact us through the contact information provided in the app.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Cookies and Tracking'),
                  _buildParagraph(
                    'We use cookies and similar tracking technologies to track the activity on our Service and hold certain information. Cookies are files with a small amount of data which may include an anonymous unique identifier.',
                  ),
                  _buildParagraph(
                    'You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent. However, if you do not accept cookies, you may not be able to use some portions of our Service.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Third-Party Services'),
                  _buildParagraph(
                    'Our Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites.',
                  ),
                  _buildParagraph(
                    'We have no control over, and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Terms of Use'),
                  _buildSubsectionTitle('Acceptable Use'),
                  _buildParagraph(
                    'You agree to use the Complaints Management System only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else\'s use and enjoyment of the system. Prohibited behavior includes harassing or causing distress or inconvenience to any person, transmitting obscene or offensive content, or disrupting the normal flow of dialogue within the system.',
                  ),

                  _buildSubsectionTitle('User Accounts'),
                  _buildParagraph(
                    'When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.',
                  ),
                  _buildParagraph(
                    'You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password. You agree not to disclose your password to any third party.',
                  ),

                  _buildSubsectionTitle('Intellectual Property'),
                  _buildParagraph(
                    'The Service and its original content, features, and functionality are and will remain the exclusive property of COMSATS University Islamabad. The Service is protected by copyright, trademark, and other laws of both Pakistan and foreign countries.',
                  ),
                  _buildParagraph(
                    'Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of COMSATS University Islamabad.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Changes to This Policy'),
                  _buildParagraph(
                    'We may update our Privacy Policy and Terms of Use from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy and Terms of Use on this page. These changes are effective immediately after they are posted on this page.',
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Contact Us'),
                  _buildParagraph(
                    'If you have any questions or suggestions about our Privacy Policy or Terms of Use, do not hesitate to contact us at:',
                  ),
                  _buildContactInfo('Email', 'privacy@comsats.edu.pk'),
                  _buildContactInfo('Phone', '+92-51-9247000'),
                  _buildContactInfo('Address', 'COMSATS University Islamabad, Park Road, Tarlai Kalan, Islamabad 45550, Pakistan'),

                  const SizedBox(height: 32),

                  // Acceptance Button
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
                        'I Understand and Accept',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF005D99),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
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
