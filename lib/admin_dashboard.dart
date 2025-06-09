import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/all_complaints.dart';
import 'package:semester_project/auth_wrapper.dart';
import 'package:semester_project/cleanliness_category.dart';
import 'package:semester_project/facilities_screen.dart';
import 'package:semester_project/in_prograss_screen.dart';
import 'package:semester_project/maintenance_screen.dart';
import 'package:semester_project/noise_screen.dart';
import 'package:semester_project/pending_complaints.dart';
import 'package:semester_project/resolved_complaints_screen.dart';
import 'package:semester_project/security_screen.dart';
import 'package:semester_project/services/shared_preferences_service.dart';
import 'package:semester_project/staff_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2A3F54),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2A3F54),
          primary: const Color(0xFF2A3F54),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data from Firebase
  List<Map<String, dynamic>> _pendingComplaints = [];
  List<Map<String, dynamic>> _inProgressComplaints = [];
  Map<String, int> _complaintStats = {
    'Total': 0,
    'Pending': 0,
    'In Progress': 0,
    'Resolved': 0,
  };
  List<Map<String, dynamic>> _categories = [
    {
      'id': 'cat1',
      'name': 'Maintenance',
      'icon': Icons.build,
      'color': Colors.blue,
      'count': 0,
    },
    {
      'id': 'cat2',
      'name': 'Security',
      'icon': Icons.security,
      'color': Colors.red,
      'count': 0,
    },
    {
      'id': 'cat3',
      'name': 'Cleanliness',
      'icon': Icons.cleaning_services,
      'color': Colors.green,
      'count': 0,
    },
    {
      'id': 'cat4',
      'name': 'Noise',
      'icon': Icons.volume_up,
      'color': Colors.orange,
      'count': 0,
    },
    {
      'id': 'cat5',
      'name': 'Staff',
      'icon': Icons.people,
      'color': Colors.purple,
      'count': 0,
    },
    {
      'id': 'cat6',
      'name': 'Facilities',
      'icon': Icons.apartment,
      'color': Colors.teal,
      'count': 0,
    },
  ];
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadFirebaseData();
    _setupRealtimeListeners();
  }

  // Load all data from Firebase
  Future<void> _loadFirebaseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadComplaints(),
        _loadComplaintStats(),
        _loadCategoryCounts(),
        _loadRecentActivity(),
      ]);
    } catch (e) {
      print('Error loading Firebase data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Setup real-time listeners for live updates
  void _setupRealtimeListeners() {
    // Listen to complaints collection for real-time updates
    _firestore.collection('complaints').snapshots().listen((snapshot) {
      if (mounted) {
        _loadComplaints();
        _loadComplaintStats();
        _loadCategoryCounts();
      }
    });
  }

  // Load complaints from Firebase
  Future<void> _loadComplaints() async {
    try {
      // Load pending complaints
      QuerySnapshot pendingSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      // Load in-progress complaints
      QuerySnapshot inProgressSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'In Progress')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      List<Map<String, dynamic>> pendingComplaints = [];
      List<Map<String, dynamic>> inProgressComplaints = [];

      // Process pending complaints
      for (QueryDocumentSnapshot doc in pendingSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data = _processComplaintData(data);
        pendingComplaints.add(data);
      }

      // Process in-progress complaints
      for (QueryDocumentSnapshot doc in inProgressSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data = _processComplaintData(data);
        inProgressComplaints.add(data);
      }

      setState(() {
        _pendingComplaints = pendingComplaints;
        _inProgressComplaints = inProgressComplaints;
      });
    } catch (e) {
      print('Error loading complaints: $e');
    }
  }

  // Load complaint statistics
  Future<void> _loadComplaintStats() async {
    try {
      // Get total count
      QuerySnapshot totalSnapshot = await _firestore.collection('complaints').get();

      // Get pending count
      QuerySnapshot pendingSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'Pending')
          .get();

      // Get in-progress count
      QuerySnapshot inProgressSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'In Progress')
          .get();

      // Get resolved count
      QuerySnapshot resolvedSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'Resolved')
          .get();

      setState(() {
        _complaintStats = {
          'Total': totalSnapshot.docs.length,
          'Pending': pendingSnapshot.docs.length,
          'In Progress': inProgressSnapshot.docs.length,
          'Resolved': resolvedSnapshot.docs.length,
        };
      });
    } catch (e) {
      print('Error loading complaint stats: $e');
    }
  }

  // Load category counts
  Future<void> _loadCategoryCounts() async {
    try {
      for (int i = 0; i < _categories.length; i++) {
        String categoryName = _categories[i]['name'];
        QuerySnapshot categorySnapshot = await _firestore
            .collection('complaints')
            .where('category', isEqualTo: categoryName)
            .get();

        setState(() {
          _categories[i]['count'] = categorySnapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error loading category counts: $e');
    }
  }

  // Load recent activity
  Future<void> _loadRecentActivity() async {
    try {
      QuerySnapshot recentSnapshot = await _firestore
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> activities = [];

      for (QueryDocumentSnapshot doc in recentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Create activity based on complaint data
        String action = 'New Complaint';
        String details = '${data['title']} submitted';
        IconData icon = Icons.add_circle;

        if (data['status'] == 'In Progress' && data.containsKey('assignedTo')) {
          action = 'Complaint Assigned';
          details = '${data['title']} assigned to ${data['assignedTo']}';
          icon = Icons.assignment_ind;
        } else if (data['status'] == 'Resolved') {
          action = 'Status Updated';
          details = '${data['title']} marked as Resolved';
          icon = Icons.check_circle;
        }

        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        String timeAgo = _getTimeAgo(createdAt);

        activities.add({
          'id': doc.id,
          'action': action,
          'details': details,
          'time': timeAgo,
          'timestamp': createdAt,
          'icon': icon,
          'complaintId': doc.id,
        });
      }

      setState(() {
        _recentActivity = activities;
      });
    } catch (e) {
      print('Error loading recent activity: $e');
    }
  }

  // Process complaint data for display
  Map<String, dynamic> _processComplaintData(Map<String, dynamic> data) {
    // Convert Timestamp to DateTime and format date
    if (data['createdAt'] != null) {
      Timestamp timestamp = data['createdAt'] as Timestamp;
      DateTime dateTime = timestamp.toDate();
      data['timestamp'] = dateTime;
      data['date'] = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }

    // Convert urgency level to string
    if (data['urgencyLevel'] != null) {
      int urgencyLevel = data['urgencyLevel'] as int;
      List<String> urgencyLabels = ['Low', 'Medium', 'High', 'Critical'];
      data['urgency'] = urgencyLabels[urgencyLevel.clamp(0, 3)];
    }

    // Set default values
    data['hasImage'] = false; // Since we removed image functionality
    data['submittedBy'] = data['submittedBy'] ?? 'Anonymous';
    data['status'] = data['status'] ?? 'Pending';

    return data;
  }

  // Get time ago string
  String _getTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Assign complaint to team
  Future<void> _assignComplaint(String complaintId, String teamId, String teamName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update complaint in Firestore
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'In Progress',
        'assignedTo': teamName,
        'assignedToId': teamId,
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint assigned to $teamName successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload data to reflect changes
      await _loadFirebaseData();
    } catch (e) {
      print('Error assigning complaint: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning complaint: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Sign out functionality
  Future<void> _signOut() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A3F54),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await _auth.signOut();
        await SharedPreferencesService.clearUserData();

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to AuthWrapper which will show login page
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2A3F54),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFirebaseData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person),
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                // Navigate to admin profile page
                  break;
                case 'settings':
                // Navigate to settings page
                  break;
                case 'logout':
                  _signOut();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF2A3F54),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF2A3F54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Admin User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _auth.currentUser?.email ?? 'admin@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('All Complaints'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllComplaintsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Complaints'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingComplaintsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.engineering),
              title: const Text('In Progress'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InProgressComplaintsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Resolved'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResolvedComplaintsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard data...'),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFirebaseData,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A3F54),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome, Admin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have ${_complaintStats['Pending']} pending complaints to review',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickActionButton(
                            icon: Icons.pending_actions,
                            label: 'Review Pending',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PendingComplaintsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            icon: Icons.assignment_ind,
                            label: 'Assign Tasks',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PendingComplaintsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            icon: Icons.analytics,
                            label: 'Reports',
                            onTap: () {
                              // Navigate to reports page
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Complaint Statistics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complaint Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3F54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildStatCard(
                              'Total',
                              _complaintStats['Total']!,
                              Colors.indigo,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AllComplaintsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStatCard(
                              'Pending',
                              _complaintStats['Pending']!,
                              Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PendingComplaintsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStatCard(
                              'In Progress',
                              _complaintStats['In Progress']!,
                              Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const InProgressComplaintsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStatCard(
                              'Resolved',
                              _complaintStats['Resolved']!,
                              Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResolvedComplaintsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Charts Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analytics Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3F54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complaints by Category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _categories.any((cat) => cat['count'] > 0)
                                  ? PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: _categories
                                      .where((category) => category['count'] > 0)
                                      .map((category) {
                                    return PieChartSectionData(
                                      value: category['count'].toDouble(),
                                      title: category['count'].toString(),
                                      color: category['color'],
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                                  : const Center(
                                child: Text(
                                  'No complaint data available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3F54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _buildCategoryCard(
                            name: category['name'],
                            icon: category['icon'],
                            color: category['color'],
                            count: category['count'],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Pending Complaints
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pending Complaints',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3F54),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PendingComplaintsScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _pendingComplaints.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No pending complaints'),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pendingComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _pendingComplaints[index];
                          return _buildAdminComplaintCard(complaint);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // In Progress Complaints
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'In Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3F54),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InProgressComplaintsScreen(),
                                ),
                              );
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _inProgressComplaints.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No complaints in progress'),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _inProgressComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _inProgressComplaints[index];
                          return _buildAdminComplaintCard(complaint);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Activity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3F54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _recentActivity.isEmpty
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No recent activity'),
                          ),
                        )
                            : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentActivity.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final activity = _recentActivity[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2A3F54).withOpacity(0.1),
                                child: Icon(
                                  activity['icon'],
                                  color: const Color(0xFF2A3F54),
                                  size: 20,
                                ),
                              ),
                              title: Text(activity['action']),
                              subtitle: Text(activity['details']),
                              trailing: Text(
                                activity['time'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                // Navigate to complaint details if needed
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2A3F54),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      int count,
      Color color, {
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to the specific category screen based on the category name
        switch (name) {
          case 'Maintenance':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaintenanceScreen(),
              ),
            );
            break;
          case 'Security':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecurityScreen(),
              ),
            );
            break;
          case 'Cleanliness':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CleanlinessScreen(),
              ),
            );
            break;
          case 'Noise':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoiseScreen(),
              ),
            );
            break;
          case 'Staff':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffScreen(),
              ),
            );
            break;
          case 'Facilities':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FacilitiesScreen(),
              ),
            );
            break;
          default:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryComplaintsScreen(category: name),
              ),
            );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count complaints',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminComplaintCard(Map<String, dynamic> complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to complaint details if needed
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(complaint['category'] ?? '').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(complaint['category'] ?? ''),
                      color: _getCategoryColor(complaint['category'] ?? ''),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Complaint Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                complaint['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint['status'] ?? 'Pending').withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint['status'] ?? 'Pending',
                                style: TextStyle(
                                  color: _getStatusColor(complaint['status'] ?? 'Pending'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint['location'] ?? 'No Location',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submitted by: ${complaint['submittedBy'] ?? 'Anonymous'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (complaint.containsKey('assignedTo') && complaint['assignedTo'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Assigned to: ${complaint['assignedTo']}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        complaint['category'] ?? 'No Category',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(complaint['urgency'] ?? 'Low'),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${complaint['urgency'] ?? 'Low'} Priority',
                        style: TextStyle(
                          color: _getUrgencyColor(complaint['urgency'] ?? 'Low'),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    complaint['date'] ?? 'No Date',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Admin Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (complaint['status'] == 'Pending')
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAssignDialog(complaint);
                      },
                      icon: const Icon(Icons.assignment_ind, size: 16),
                      label: const Text('Assign'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A3F54),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to complaint details if needed
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2A3F54),
                      side: const BorderSide(color: Color(0xFF2A3F54)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(Map<String, dynamic> complaint) {
    final List<Map<String, dynamic>> teams = [
      {'id': 'team1', 'name': 'Tech Team'},
      {'id': 'team2', 'name': 'Maintenance Crew'},
      {'id': 'team3', 'name': 'Security Team'},
      {'id': 'team4', 'name': 'Cleaning Staff'},
    ];

    String selectedTeamId = teams[0]['id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign Complaint: ${complaint['title'] ?? 'No Title'}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select team to assign:'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedTeamId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: teams.map((team) {
                      return DropdownMenuItem<String>(
                        value: team['id'],
                        child: Text(team['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedTeamId = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selectedTeam = teams.firstWhere(
                          (team) => team['id'] == selectedTeamId,
                      orElse: () => {'id': '', 'name': 'Unknown'},
                    );

                    _assignComplaint(
                      complaint['id'],
                      selectedTeamId,
                      selectedTeam['name'],
                    );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3F54),
                  ),
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    for (var cat in _categories) {
      if (cat['name'] == category) {
        return cat['icon'];
      }
    }
    return Icons.help_outline;
  }

  Color _getCategoryColor(String category) {
    for (var cat in _categories) {
      if (cat['name'] == category) {
        return cat['color'];
      }
    }
    return Colors.grey;
  }
}

// Dummy Screens for Navigation
class CategoryComplaintsScreen extends StatelessWidget {
  final String category;

  const CategoryComplaintsScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Complaints')),
      body: Center(child: Text('$category Complaints Screen')),
    );
  }
}
