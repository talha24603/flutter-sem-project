import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InProgressComplaintsScreen extends StatefulWidget {
  const InProgressComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<InProgressComplaintsScreen> createState() => _InProgressComplaintsScreenState();
}

class _InProgressComplaintsScreenState extends State<InProgressComplaintsScreen> {
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
          .where('status', isEqualTo: 'In Progress')
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
      print('Error loading in progress complaints: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading complaints: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    data['status'] = data['status'] ?? 'In Progress';
    data['category'] = data['category'] ?? 'General';
    data['location'] = data['location'] ?? 'Not specified';
    data['title'] = data['title'] ?? 'No title';
    data['urgency'] = data['urgency'] ?? 'Low';
    data['assignedTo'] = data['assignedTo'] ?? 'Unassigned';

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
        case 'assignedTo':
          final aAssigned = a['assignedTo'] ?? '';
          final bAssigned = b['assignedTo'] ?? '';
          return _sortAscending ? aAssigned.compareTo(bAssigned) : bAssigned.compareTo(aAssigned);
        default:
          return 0;
      }
    });

    setState(() {
      _complaints = complaints;
      _isLoading = false;
    });
  }

  Future<void> _markAsResolved(String complaintId) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'status': 'Resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint marked as resolved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload complaints to reflect changes
      _loadComplaints();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resolving complaint: ${e.toString()}'),
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
          'In Progress Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
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
              Text('Loading in progress complaints...'),
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
            Icons.engineering,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No In Progress Complaints',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No complaints are currently being worked on',
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
              backgroundColor: Colors.blue,
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
                          'Assigned to: ${complaint['assignedTo']}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
                    onPressed: () => _showResolveDialog(complaint),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Mark Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
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
              _buildSortOption('assignedTo', 'Assigned To'),
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
            color: _sortBy == value ? Colors.blue : Colors.grey,
          ),
        ],
      ),
      value: value,
      groupValue: _sortBy,
      activeColor: Colors.blue,
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
          _sortComplaints(_complaints);
        }
      },
    );
  }

  void _showResolveDialog(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark as Resolved'),
          content: Text('Are you sure you want to mark "${complaint['title']}" as resolved?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _markAsResolved(complaint['id']);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Mark Resolved'),
            ),
          ],
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
                      _buildDetailItem('Assigned To', complaint['assignedTo'], Icons.assignment_ind),
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
