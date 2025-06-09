import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingComplaintsScreen extends StatefulWidget {
  const PendingComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<PendingComplaintsScreen> createState() => _PendingComplaintsScreenState();
}

class _PendingComplaintsScreenState extends State<PendingComplaintsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'Pending')
          .get();

      List<Map<String, dynamic>> complaints = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data = _processComplaintData(data);
        complaints.add(data);
      }

      _sortComplaints(complaints);
    } catch (e) {
      print('Error loading pending complaints: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading complaints: ${e.toString()}'),
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
    data['submittedBy'] = data['submittedBy'] ?? 'Anonymous';
    data['status'] = data['status'] ?? 'Pending';
    data['category'] = data['category'] ?? 'General';
    data['location'] = data['location'] ?? 'Not specified';
    data['title'] = data['title'] ?? 'No title';
    data['urgency'] = data['urgency'] ?? 'Low';

    return data;
  }

  void _sortComplaints(List<Map<String, dynamic>> complaints) {
    complaints.sort((a, b) {
      switch (_sortBy) {
        case 'date':
          final aDate = a['timestamp'] as DateTime? ?? DateTime.now();
          final bDate = b['timestamp'] as DateTime? ?? DateTime.now();
          return _sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        case 'urgency':
          final urgencyOrder = {'Low': 0, 'Medium': 1, 'High': 2, 'Critical': 3};
          final aUrgency = urgencyOrder[a['urgency']] ?? 0;
          final bUrgency = urgencyOrder[b['urgency']] ?? 0;
          return _sortAscending ? aUrgency.compareTo(bUrgency) : bUrgency.compareTo(aUrgency);
        case 'category':
          final aCategory = a['category'] ?? '';
          final bCategory = b['category'] ?? '';
          return _sortAscending ? aCategory.compareTo(bCategory) : bCategory.compareTo(aCategory);
        case 'title':
          final aTitle = a['title'] ?? '';
          final bTitle = b['title'] ?? '';
          return _sortAscending ? aTitle.compareTo(bTitle) : bTitle.compareTo(aTitle);
        default:
          return 0;
      }
    });

    setState(() {
      _complaints = complaints;
    });
  }

  Future<void> _assignComplaint(String complaintId, String teamId, String teamName) async {
    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be logged in to assign complaints'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Add the current user's information to the update
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'In Progress',
        'assignedTo': teamName,
        'assignedToId': teamId,
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'assignedBy': user.displayName ?? user.email ?? 'Unknown',
        'assignedById': user.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint assigned to $teamName successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload complaints to reflect changes
      _loadComplaints();
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Maintenance':
        return Icons.build;
      case 'Security':
        return Icons.security;
      case 'Cleanliness':
        return Icons.cleaning_services;
      case 'Noise':
        return Icons.volume_up;
      case 'Staff':
        return Icons.people;
      case 'Facilities':
        return Icons.apartment;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Maintenance':
        return Colors.blue;
      case 'Security':
        return Colors.red;
      case 'Cleanliness':
        return Colors.green;
      case 'Noise':
        return Colors.orange;
      case 'Staff':
        return Colors.purple;
      case 'Facilities':
        return Colors.teal;
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
          'Pending Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadComplaints,
        child: _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading pending complaints...'),
            ],
          ),
        )
            : _complaints.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _complaints.length,
          itemBuilder: (context, index) {
            final complaint = _complaints[index];
            return _buildComplaintCard(complaint);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pending_actions,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Complaints',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All complaints have been processed or assigned',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
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
        onTap: () => _showComplaintDetails(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(complaint['category']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(complaint['category']),
                      color: _getCategoryColor(complaint['category']),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAssignDialog(complaint),
                    icon: const Icon(Icons.assignment_ind, size: 16),
                    label: const Text('Assign'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showComplaintDetails(complaint),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Complaints'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('date', 'Date'),
              _buildSortOption('urgency', 'Urgency'),
              _buildSortOption('category', 'Category'),
              _buildSortOption('title', 'Title'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: _sortBy == value ? Colors.orange : Colors.grey,
          ),
        ],
      ),
      value: value,
      groupValue: _sortBy,
      activeColor: Colors.orange,
      onChanged: (String? newValue) {
        Navigator.of(context).pop();
        if (newValue != null) {
          setState(() {
            if (_sortBy == newValue) {
              _sortAscending = !_sortAscending;
            } else {
              _sortBy = newValue;
            }
          });
          _loadComplaints();
        }
      },
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
                  onPressed: () => Navigator.of(context).pop(),
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
                    backgroundColor: Colors.orange,
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

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complaint #${complaint['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem('Category', complaint['category'], Icons.category),
                      _buildDetailItem('Location', complaint['location'], Icons.location_on),
                      _buildDetailItem('Submitted By', complaint['submittedBy'], Icons.person),
                      _buildDetailItem('Date', complaint['date'], Icons.calendar_today),
                      _buildDetailItem('Urgency', complaint['urgency'], Icons.warning_amber,
                          valueColor: _getUrgencyColor(complaint['urgency'])),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        complaint['description'] ?? 'No description provided',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
