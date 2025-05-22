import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:semester_project/all_complaints.dart';
import 'package:semester_project/cleanliness_category.dart';
import 'package:semester_project/facilities_screen.dart';
import 'package:semester_project/in_prograss_screen.dart';
import 'package:semester_project/maintenance_screen.dart';
import 'package:semester_project/noise_screen.dart';
import 'package:semester_project/pending_complaints.dart';
import 'package:semester_project/resolved_complaints_screen.dart';
import 'package:semester_project/security_screen.dart';
import 'package:semester_project/staff_screen.dart';

// FUTURE FIREBASE INTEGRATION:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';



// Import status screens


void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // FUTURE FIREBASE INTEGRATION:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

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
      // FUTURE FIREBASE INTEGRATION:
      // Use StreamBuilder with FirebaseAuth.instance.authStateChanges()
      // to redirect to login page if not authenticated
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

  // Mock data - would be replaced with Firebase data in the future
  late List<Map<String, dynamic>> _pendingComplaints;
  late List<Map<String, dynamic>> _inProgressComplaints;
  late Map<String, int> _complaintStats;
  late List<Map<String, dynamic>> _categories;
  late List<Map<String, dynamic>> _recentActivity;

  @override
  void initState() {
    super.initState();
    // Load mock data - would be replaced with Firebase queries
    _loadMockData();

    // FUTURE FIREBASE INTEGRATION:
    // Set up listeners for real-time updates from Firestore
  }

  // This simulates loading data - would be replaced with Firebase queries
  Future<void> _loadMockData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data that mimics Firestore document structure
    _pendingComplaints = [
      {
        'id': 'C-1001',
        'title': 'Broken Water Fountain',
        'category': 'Maintenance',
        'location': 'Building A, 2nd Floor',
        'status': 'Pending',
        'date': '2023-06-15',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'urgency': 'Medium',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60', // Would be Firebase Storage URL
        'submittedBy': 'John Doe',
        'submitterId': 'user123', // Would be Firebase Auth UID
        'description': 'The water fountain on the 2nd floor is not working properly. Water pressure is very low.',
      },
      {
        'id': 'C-1002',
        'title': 'Flickering Lights in Classroom',
        'category': 'Facilities',
        'location': 'Science Block, Room 204',
        'status': 'Pending',
        'date': '2023-06-14',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'urgency': 'Low',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'Jane Smith',
        'submitterId': 'user456',
        'description': 'The lights in Room 204 are flickering constantly, making it difficult to concentrate during lectures.',
      },
      {
        'id': 'C-1004',
        'title': 'Broken Chair in Auditorium',
        'category': 'Maintenance',
        'location': 'Main Auditorium, Row C',
        'status': 'Pending',
        'date': '2023-06-16',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'urgency': 'High',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'Robert Johnson',
        'submitterId': 'user789',
        'description': 'A chair in Row C of the main auditorium is broken and poses a safety hazard.',
      },
    ];

    _inProgressComplaints = [
      {
        'id': 'C-1005',
        'title': 'AC Not Working',
        'category': 'Facilities',
        'location': 'Computer Lab 3',
        'status': 'In Progress',
        'date': '2023-06-13',
        'timestamp': DateTime.now().subtract(const Duration(days: 4)),
        'urgency': 'High',
        'hasImage': false,
        'submittedBy': 'Emily Davis',
        'submitterId': 'user101',
        'assignedTo': 'Tech Team',
        'assignedToId': 'team1',
        'assignedAt': DateTime.now().subtract(const Duration(days: 2)),
        'description': 'The air conditioning in Computer Lab 3 is not working. The room is too hot for students to work effectively.',
      },
      {
        'id': 'C-1006',
        'title': 'Leaking Roof',
        'category': 'Maintenance',
        'location': 'Library, East Wing',
        'status': 'In Progress',
        'date': '2023-06-12',
        'timestamp': DateTime.now().subtract(const Duration(days: 5)),
        'urgency': 'Critical',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'Michael Brown',
        'submitterId': 'user202',
        'assignedTo': 'Maintenance Crew',
        'assignedToId': 'team2',
        'assignedAt': DateTime.now().subtract(const Duration(days: 3)),
        'description': 'The roof in the east wing of the library is leaking. Water is dripping onto bookshelves and damaging books.',
      },
    ];

    _complaintStats = {
      'Total': 24,
      'Pending': 8,
      'In Progress': 10,
      'Resolved': 6,
    };

    _categories = [
      {
        'id': 'cat1',
        'name': 'Maintenance',
        'icon': Icons.build,
        'color': Colors.blue,
        'count': 12,
      },
      {
        'id': 'cat2',
        'name': 'Security',
        'icon': Icons.security,
        'color': Colors.red,
        'count': 5,
      },
      {
        'id': 'cat3',
        'name': 'Cleanliness',
        'icon': Icons.cleaning_services,
        'color': Colors.green,
        'count': 8,
      },
      {
        'id': 'cat4',
        'name': 'Noise',
        'icon': Icons.volume_up,
        'color': Colors.orange,
        'count': 3,
      },
      {
        'id': 'cat5',
        'name': 'Staff',
        'icon': Icons.people,
        'color': Colors.purple,
        'count': 2,
      },
      {
        'id': 'cat6',
        'name': 'Facilities',
        'icon': Icons.apartment,
        'color': Colors.teal,
        'count': 7,
      },
    ];

    _recentActivity = [
      {
        'id': 'act1',
        'action': 'Complaint Assigned',
        'details': 'Leaking Roof assigned to Maintenance Crew',
        'time': '2 hours ago',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.assignment_ind,
        'complaintId': 'C-1006',
      },
      {
        'id': 'act2',
        'action': 'Status Updated',
        'details': 'Broken Window marked as Resolved',
        'time': '4 hours ago',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'icon': Icons.check_circle,
        'complaintId': 'C-1003',
      },
      {
        'id': 'act3',
        'action': 'New Complaint',
        'details': 'Broken Chair in Auditorium submitted',
        'time': '6 hours ago',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'icon': Icons.add_circle,
        'complaintId': 'C-1004',
      },
      {
        'id': 'act4',
        'action': 'Comment Added',
        'details': 'Comment added to AC Not Working',
        'time': '1 day ago',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.comment,
        'complaintId': 'C-1005',
      },
    ];

    setState(() {
      _isLoading = false;
    });
  }

  // FUTURE FIREBASE INTEGRATION:
  // This would be implemented to update a complaint in Firestore
  Future<void> _assignComplaint(String complaintId, String teamId, String teamName) async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Update local state to reflect the change
      // In the future, this would be handled by Firestore listeners
      setState(() {
        // Find the complaint and update it
        final complaintIndex = _pendingComplaints.indexWhere((c) => c['id'] == complaintId);
        if (complaintIndex != -1) {
          final complaint = Map<String, dynamic>.from(_pendingComplaints[complaintIndex]);
          complaint['status'] = 'In Progress';
          complaint['assignedTo'] = teamName;
          complaint['assignedToId'] = teamId;
          complaint['assignedAt'] = DateTime.now();

          // Remove from pending and add to in progress
          _pendingComplaints.removeAt(complaintIndex);
          _inProgressComplaints.add(complaint);

          // Update stats
          _complaintStats['Pending'] = _complaintStats['Pending']! - 1;
          _complaintStats['In Progress'] = _complaintStats['In Progress']! + 1;

          // Add to activity log
          _recentActivity.insert(0, {
            'id': 'act${_recentActivity.length + 1}',
            'action': 'Complaint Assigned',
            'details': '${complaint['title']} assigned to $teamName',
            'time': 'Just now',
            'timestamp': DateTime.now(),
            'icon': Icons.assignment_ind,
            'complaintId': complaintId,
          });
        }
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint $complaintId assigned to $teamName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Hide loading indicator
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

  // FUTURE FIREBASE INTEGRATION:
  // This would use FirebaseAuth.instance.signOut()
  Future<void> _signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.green,
        ),
      );
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
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to admin profile page
            },
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
                    'admin@example.com',
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
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
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
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: _categories.map((category) {
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
                              // FUTURE FIREBASE INTEGRATION:
                              // Navigate to the related complaint details
                              // if (activity.containsKey('complaintId')) {
                              //   Navigator.push(context, MaterialPageRoute(
                              //     builder: (context) => ComplaintDetailsPage(
                              //       complaintId: activity['complaintId'],
                              //     ),
                              //   ));
                              // }
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
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: const Color(0xFF2A3F54),
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.dashboard),
      //       label: 'Dashboard',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.list_alt),
      //       label: 'Complaints',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.analytics),
      //       label: 'Reports',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      // ),
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
      Color color,
      {required VoidCallback onTap}
      ) {
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
          // Fallback to a generic category screen if needed
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
          // FUTURE FIREBASE INTEGRATION:
          // Navigate to complaint details page
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => ComplaintDetailsPage(
          //     complaintId: complaint['id'],
          //   ),
          // ));
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
                  // Complaint Image or Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: complaint['hasImage']
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        complaint['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 30,
                          );
                        },
                      ),
                    )
                        : Icon(
                      _getCategoryIcon(complaint['category']),
                      color: _getCategoryColor(complaint['category']),
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
                                complaint['title'],
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
                                color: _getStatusColor(complaint['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint['status'],
                                style: TextStyle(
                                  color: _getStatusColor(complaint['status']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint['location'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submitted by: ${complaint['submittedBy']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (complaint.containsKey('assignedTo'))
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
                        complaint['category'],
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
                          color: _getUrgencyColor(complaint['urgency']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${complaint['urgency']} Priority',
                        style: TextStyle(
                          color: _getUrgencyColor(complaint['urgency']),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    complaint['date'],
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
                        // Show assign dialog
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
                      // FUTURE FIREBASE INTEGRATION:
                      // Navigate to complaint details page
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) => ComplaintDetailsPage(
                      //     complaintId: complaint['id'],
                      //   ),
                      // ));
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
    // Mock data for teams - would come from Firebase in the future
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
              title: Text('Assign Complaint: ${complaint['title']}'),
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
                    // Get the selected team name
                    final selectedTeam = teams.firstWhere(
                          (team) => team['id'] == selectedTeamId,
                      orElse: () => {'id': '', 'name': 'Unknown'},
                    );

                    // Assign the complaint
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
