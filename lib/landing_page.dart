import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:semester_project/about_us.dart';
import 'package:semester_project/contact_us.dart';
import 'package:semester_project/login.dart';
import 'package:semester_project/policy.dart';
import 'admin_dashboard.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToSection(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;
    final isTablet = screenWidth > 650 && screenWidth <= 1000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: Color(0xFF2A3F54), // sets drawer icon color
        ),
        title: Padding(
          padding: EdgeInsets.only(left: isDesktop ? 40 : 0),
          child: Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF2A3F54),
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'CUI COMPLAINTS',
                style: TextStyle(
                  color: Color(0xFF2A3F54),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: isDesktop || isTablet
            ? [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsPage()),
            ),
            child: const Text('About Us'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactUsPage()),
            ),
            child: const Text('Contact Us'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PolicyPage()),
            ),
            child: const Text('Policy'),
          ),
          Padding(
            padding: EdgeInsets.only(right: isDesktop ? 40 : 16, left: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A3F54),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Login'),
            ),
          ),
        ]
            : null,
      ),
      drawer: !(isDesktop || isTablet)
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2A3F54),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text('CUI COMPLAINTS', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF2A3F54)),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF2A3F54)),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy, color: Color(0xFF2A3F54)),
              title: const Text('Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PolicyPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF2A3F54)),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2A3F54),
                    const Color(0xFF2A3F54).withOpacity(0.8),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streamline Your Complaint Management Process',
                      style: TextStyle(
                        fontSize: isDesktop ? 40 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'An efficient, user-friendly platform to manage, track, and resolve complaints.',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AdminDashboard()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2A3F54),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Get Started'),
                        ),
                        const SizedBox(width: 15),
                        OutlinedButton(
                          onPressed: () => _scrollToSection(600),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Learn More'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // How It Works Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 60, horizontal: isDesktop ? 80 : 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3F54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Simple process, powerful results',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildProcessStep(
                    '01',
                    'Submit a Complaint',
                    'Users can easily submit complaints through the mobile app or web portal.',
                  ),
                  const SizedBox(height: 30),
                  _buildProcessStep(
                    '02',
                    'Review & Assign',
                    'Admins review and assign complaints to the appropriate team.',
                  ),
                  const SizedBox(height: 30),
                  _buildProcessStep(
                    '03',
                    'Resolve & Feedback',
                    'Assigned teams resolve issues and users can rate the outcome.',
                  ),
                ],
              ),
            ),

            // Footer remains unchanged...
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3F54),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3F54),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Placeholder pages
// class AboutUsPage extends StatelessWidget {
//   const AboutUsPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('About Us')),
//       body: const Center(child: Text('About Us content here.')),
//     );
//   }
// }
//
// class ContactUsPage extends StatelessWidget {
//   const ContactUsPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Contact Us')),
//       body: const Center(child: Text('Contact Us content here.')),
//     );
//   }
// }
//
// class PolicyPage extends StatelessWidget {
//   const PolicyPage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Policy')),
//       body: const Center(child: Text('Policy content here.')),
//     );
//   }
// }
