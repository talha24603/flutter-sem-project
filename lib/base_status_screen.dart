import 'package:flutter/material.dart';

class BaseStatusScreen extends StatefulWidget {
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final bool showStatusFilter;

  const BaseStatusScreen({
    Key? key,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    this.showStatusFilter = false,
  }) : super(key: key);

  @override
  State<BaseStatusScreen> createState() => _BaseStatusScreenState();
}

class _BaseStatusScreenState extends State<BaseStatusScreen> {
  bool _isLoading = true;
  String _sortBy = 'date';
  String _filterCategory = 'All';
  List<Map<String, dynamic>> _complaints = [];

  // Mock categories for filtering
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.category, 'color': Colors.grey},
    {'name': 'Maintenance', 'icon': Icons.build, 'color': Colors.blue},
    {'name': 'Security', 'icon': Icons.security, 'color': Colors.red},
    {'name': 'Cleanliness', 'icon': Icons.cleaning_services, 'color': Colors.green},
    {'name': 'Noise', 'icon': Icons.volume_up, 'color': Colors.orange},
    {'name': 'Staff', 'icon': Icons.people, 'color': Colors.purple},
    {'name': 'Facilities', 'icon': Icons.apartment, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data - would be replaced with Firebase queries
    final List<Map<String, dynamic>> allComplaints = [
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
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'John Doe',
        'submitterId': 'user123',
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
        'id': 'C-1003',
        'title': 'Broken Window',
        'category': 'Maintenance',
        'location': 'Library, West Wing',
        'status': 'Resolved',
        'date': '2023-06-10',
        'timestamp': DateTime.now().subtract(const Duration(days: 7)),
        'urgency': 'High',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'Alice Johnson',
        'submitterId': 'user789',
        'resolvedBy': 'Maintenance Team',
        'resolvedAt': DateTime.now().subtract(const Duration(days: 5)),
        'description': 'A window in the west wing of the library is broken, allowing rain to enter.',
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
      {
        'id': 'C-1007',
        'title': 'Graffiti on Wall',
        'category': 'Cleanliness',
        'location': 'Parking Lot, Wall B',
        'status': 'Resolved',
        'date': '2023-06-08',
        'timestamp': DateTime.now().subtract(const Duration(days: 9)),
        'urgency': 'Medium',
        'hasImage': true,
        'imageUrl': 'https://via.placeholder.com/60x60',
        'submittedBy': 'David Wilson',
        'submitterId': 'user303',
        'resolvedBy': 'Cleaning Staff',
        'resolvedAt': DateTime.now().subtract(const Duration(days: 6)),
        'description': 'There is graffiti on the wall in Parking Lot B that needs to be cleaned.',
      },
      {
        'id': 'C-1008',
        'title': 'Loud Construction Noise',
        'category': 'Noise',
        'location': 'Near Science Block',
        'status': 'Resolved',
        'date': '2023-06-09',
        'timestamp': DateTime.now().subtract(const Duration(days: 8)),
        'urgency': 'Low',
        'hasImage': false,
        'submittedBy': 'Sarah Thompson',
        'submitterId': 'user404',
        'resolvedBy': 'Admin',
        'resolvedAt': DateTime.now().subtract(const Duration(days: 7)),
        'description': 'The construction near the Science Block is causing excessive noise during class hours.',
      },
    ];

    // Filter complaints based on status
    List<Map<String, dynamic>> filteredComplaints;
    if (widget.status == 'All') {
      filteredComplaints = allComplaints;
    } else {
      filteredComplaints = allComplaints.where((c) => c['status'] == widget.status).toList();
    }

    setState(() {
      _complaints = filteredComplaints;
      _isLoading = false;
    });
  }

  void _sortComplaints() {
    setState(() {
      switch (_sortBy) {
        case 'date':
          _complaints.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
          break;
        case 'urgency':
          final urgencyOrder = {'Critical': 0, 'High': 1, 'Medium': 2, 'Low': 3};
          _complaints.sort((a, b) =>
              urgencyOrder[a['urgency']]!.compareTo(urgencyOrder[b['urgency']]!));
          break;
        case 'category':
          _complaints.sort((a, b) => a['category'].compareTo(b['category']));
          break;
      }
    });
  }

  void _filterComplaints() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.status} Complaints'),
        backgroundColor: widget.statusColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          // Header with status info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.statusColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.statusIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.status} Complaints',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_complaints.length} complaints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Filter and Sort Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sort Dropdown
                    DropdownButton<String>(
                      value: _sortBy,
                      hint: const Text('Sort By'),
                      icon: const Icon(Icons.sort),
                      underline: Container(
                        height: 2,
                        color: widget.statusColor,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortBy = newValue;
                            _sortComplaints();
                          });
                        }
                      },
                      items: <String>['date', 'urgency', 'category']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.substring(0, 1).toUpperCase() + value.substring(1),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Category Filter
                    DropdownButton<String>(
                      value: _filterCategory,
                      hint: const Text('Filter by Category'),
                      icon: const Icon(Icons.filter_list),
                      underline: Container(
                        height: 2,
                        color: widget.statusColor,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filterCategory = newValue;
                            _filterComplaints();
                          });
                        }
                      },
                      items: _categories
                          .map<DropdownMenuItem<String>>((Map<String, dynamic> category) {
                        return DropdownMenuItem<String>(
                          value: category['name'],
                          child: Row(
                            children: [
                              Icon(
                                category['icon'],
                                color: category['color'],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    // Status Filter (only shown for All Complaints)
                    if (widget.showStatusFilter)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Show status filter dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Filter by Status'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.pending, color: Colors.orange),
                                      title: const Text('Pending'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Filter by Pending
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.loop, color: Colors.blue),
                                      title: const Text('In Progress'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Filter by In Progress
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.check_circle, color: Colors.green),
                                      title: const Text('Resolved'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Filter by Resolved
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.all_inclusive),
                                      title: const Text('All'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        // Show all
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.filter_alt, size: 16),
                        label: const Text('Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: _complaints.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.status} complaints found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                return _buildComplaintCard(complaint);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to complaint details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 16),

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
                        if (complaint.containsKey('resolvedBy'))
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Resolved by: ${complaint['resolvedBy']}',
                              style: const TextStyle(
                                color: Colors.green,
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
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(complaint['category']),
                        size: 16,
                        color: _getCategoryColor(complaint['category']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        complaint['category'],
                        style: TextStyle(
                          color: _getCategoryColor(complaint['category']),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to complaint details
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.statusColor,
                      side: BorderSide(color: widget.statusColor),
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
}
