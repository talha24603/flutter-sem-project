import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllComplaintsScreen extends StatefulWidget {
  const AllComplaintsScreen({Key? key}) : super(key: key);

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _sortBy = 'date';
  bool _sortAscending = false;
  String _filterStatus = 'All';
  String _filterCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Maintenance',
    'Security',
    'Cleanliness',
    'Noise',
    'Staff',
    'Facilities'
  ];

  final List<String> _statuses = [
    'All',
    'Pending',
    'In Progress',
    'Resolved'
  ];

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
      QuerySnapshot snapshot = await _firestore.collection('complaints').get();

      List<Map<String, dynamic>> complaints = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data = _processComplaintData(data);
        complaints.add(data);
      }

      setState(() {
        _complaints = complaints;
      });

      _applyFiltersAndSort();
    } catch (e) {
      print('Error loading all complaints: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading complaints: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_complaints);

    // Apply status filter
    if (_filterStatus != 'All') {
      filtered = filtered.where((complaint) => complaint['status'] == _filterStatus).toList();
    }

    // Apply category filter
    if (_filterCategory != 'All') {
      filtered = filtered.where((complaint) => complaint['category'] == _filterCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((complaint) {
        final title = complaint['title']?.toLowerCase() ?? '';
        final description = complaint['description']?.toLowerCase() ?? '';
        final location = complaint['location']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query) || location.contains(query);
      }).toList();
    }

    // Sort the filtered results
    filtered.sort((a, b) {
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
        case 'status':
          final statusOrder = {'Pending': 0, 'In Progress': 1, 'Resolved': 2};
          final aStatus = statusOrder[a['status']] ?? 0;
          final bStatus = statusOrder[b['status']] ?? 0;
          return _sortAscending ? aStatus.compareTo(bStatus) : bStatus.compareTo(aStatus);
        case 'category':
          final aCategory = a['category'] ?? '';
          final bCategory = b['category'] ?? '';
          return _sortAscending ? aCategory.compareTo(bCategory) : bCategory.compareTo(aCategory);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredComplaints = filtered;
      _isLoading = false;
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
          'All Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFiltersAndSort();
              },
              decoration: InputDecoration(
                hintText: 'Search complaints...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Status: $_filterStatus', () => _showStatusFilter()),
                  const SizedBox(width: 8),
                  _buildFilterChip('Category: $_filterCategory', () => _showCategoryFilter()),
                  const SizedBox(width: 8),
                  if (_searchQuery.isNotEmpty || _filterStatus != 'All' || _filterCategory != 'All')
                    _buildClearFiltersChip(),
                ],
              ),
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredComplaints.length} complaint${_filteredComplaints.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (_complaints.isNotEmpty)
                  Text(
                    'Total: ${_complaints.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadComplaints,
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading all complaints...'),
                  ],
                ),
              )
                  : _filteredComplaints.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredComplaints.length,
                itemBuilder: (context, index) {
                  final complaint = _filteredComplaints[index];
                  return _buildComplaintCard(complaint);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.indigo,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearFiltersChip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchQuery = '';
          _filterStatus = 'All';
          _filterCategory = 'All';
        });
        _applyFiltersAndSort();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Clear Filters',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.clear,
              color: Colors.red,
              size: 16,
            ),
          ],
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
            _searchQuery.isNotEmpty || _filterStatus != 'All' || _filterCategory != 'All'
                ? Icons.search_off
                : Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'All' || _filterCategory != 'All'
                ? 'No Matching Complaints'
                : 'No Complaints Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'All' || _filterCategory != 'All'
                ? 'Try adjusting your search or filters'
                : 'No complaints have been submitted yet',
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
              backgroundColor: Colors.indigo,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statuses.map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = value!;
                });
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return RadioListTile<String>(
              title: Text(category),
              value: category,
              groupValue: _filterCategory,
              onChanged: (value) {
                setState(() {
                  _filterCategory = value!;
                });
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            );
          }).toList(),
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
              _buildSortOption('status', 'Status'),
              _buildSortOption('category', 'Category'),
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
            color: _sortBy == value ? Colors.indigo : Colors.grey,
          ),
        ],
      ),
      value: value,
      groupValue: _sortBy,
      activeColor: Colors.indigo,
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
          _applyFiltersAndSort();
        }
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter & Search'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions:'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Pending Only'),
                    selected: _filterStatus == 'Pending',
                    onSelected: (selected) {
                      setState(() {
                        _filterStatus = selected ? 'Pending' : 'All';
                      });
                      _applyFiltersAndSort();
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('High Priority'),
                    selected: false,
                    onSelected: (selected) {
                      // Could implement urgency filter here
                    },
                  ),
                ],
              ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint['status'],
                      style: TextStyle(
                        color: _getStatusColor(complaint['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
