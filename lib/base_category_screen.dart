import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BaseCategoryScreen extends StatefulWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;

  const BaseCategoryScreen({
    Key? key,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  State<BaseCategoryScreen> createState() => _BaseCategoryScreenState();
}

class _BaseCategoryScreenState extends State<BaseCategoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  String _sortBy = 'timestamp'; // Default sort by timestamp
  bool _sortAscending = false; // Default descending (newest first)
  String _filterStatus = 'All'; // Default show all statuses
  String? _errorMessage;
  bool _useSimpleQuery = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  // Simple query that only filters by category - no complex indexes needed
  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simple query that only filters by category - no complex indexes needed
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('category', isEqualTo: widget.category)
          .get();

      final List<Map<String, dynamic>> complaints = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Add document ID for tracking
        data['id'] = doc.id;

        // Convert timestamp to readable date
        if (data['timestamp'] != null) {
          final timestamp = data['timestamp'] as Timestamp;
          data['date'] = _formatDate(timestamp.toDate());
          data['timestampDate'] = timestamp.toDate();
        } else if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          data['date'] = _formatDate(timestamp.toDate());
          data['timestampDate'] = timestamp.toDate();
        } else {
          data['date'] = 'Unknown';
          data['timestampDate'] = DateTime.now();
        }

        // Convert urgency from number to string if needed
        if (data['urgency'] is int) {
          data['urgency'] = _getUrgencyString(data['urgency']);
        }

        // Ensure all required fields exist with defaults
        data['title'] = data['title'] ?? 'Untitled Complaint';
        data['location'] = data['location'] ?? 'Unknown Location';
        data['status'] = data['status'] ?? 'Pending';
        data['urgency'] = data['urgency'] ?? 'Medium';
        data['submittedBy'] = data['submittedBy'] ?? 'Anonymous';
        data['description'] = data['description'] ?? 'No description provided';
        data['hasImage'] = data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty;

        complaints.add(data);
      }

      setState(() {
        _complaints = complaints;
        // Apply filtering and sorting in memory
        _applyFiltersAndSort();
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading complaints: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading complaints: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadComplaints,
            ),
          ),
        );
      }
    }
  }

  // Apply filters and sorting in memory instead of in the database
  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> filtered = List.from(_complaints);

    // Apply status filter if not 'All'
    if (_filterStatus != 'All') {
      filtered = filtered.where((c) => c['status'] == _filterStatus).toList();
    }

    // Sort the complaints
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'timestamp':
        case 'createdAt':
          final aDate = a['timestampDate'] as DateTime;
          final bDate = b['timestampDate'] as DateTime;
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
        case 'title':
          return _sortAscending
              ? a['title'].toString().compareTo(b['title'].toString())
              : b['title'].toString().compareTo(a['title'].toString());
        default:
          return 0;
      }
    });

    setState(() {
      _filteredComplaints = filtered;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getUrgencyString(int urgencyLevel) {
    switch (urgencyLevel) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  Future<void> _refreshComplaints() async {
    await _loadComplaints();
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
        title: Text(
          '${widget.category} Complaints',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComplaints,
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
      body: RefreshIndicator(
        onRefresh: _refreshComplaints,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.categoryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.categoryIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_filteredComplaints.length} complaints',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusFilterChip('All'),
                          _buildStatusFilterChip('Pending'),
                          _buildStatusFilterChip('In Progress'),
                          _buildStatusFilterChip('Resolved'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Complaints List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorState()
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to complaint form for this specific category
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ComplaintForm(
          //       preSelectedCategory: widget.category,
          //     ),
          //   ),
          // );
        },
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusFilterChip(String status) {
    final isSelected = _filterStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
          // Apply filters in memory
          _applyFiltersAndSort();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? widget.categoryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Complaints',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'An unknown error occurred',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.categoryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No complaints found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'All'
                ? 'There are no complaints in this category yet'
                : 'There are no $_filterStatus complaints in this category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadComplaints,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.categoryColor,
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
        onTap: () {
          _showComplaintDetails(complaint);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
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
                  widget.categoryIcon,
                  color: widget.categoryColor,
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
              _buildSortOption('timestamp', 'Date'),
              _buildSortOption('urgency', 'Urgency'),
              _buildSortOption('status', 'Status'),
              _buildSortOption('title', 'Title'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
            color: _sortBy == value ? widget.categoryColor : Colors.grey,
          ),
        ],
      ),
      value: value,
      groupValue: _sortBy,
      activeColor: widget.categoryColor,
      onChanged: (String? newValue) {
        Navigator.of(context).pop();
        if (newValue != null) {
          setState(() {
            if (_sortBy == newValue) {
              // Toggle direction if same sort option
              _sortAscending = !_sortAscending;
            } else {
              _sortBy = newValue;
              _sortAscending = false; // Default to descending for new sort
            }
            // Apply filters in memory
            _applyFiltersAndSort();
          });
        }
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Complaints'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status:'),
              _buildFilterOption('All', 'All Statuses'),
              _buildFilterOption('Pending', 'Pending'),
              _buildFilterOption('In Progress', 'In Progress'),
              _buildFilterOption('Resolved', 'Resolved'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _filterStatus,
      activeColor: widget.categoryColor,
      onChanged: (String? newValue) {
        Navigator.of(context).pop();
        if (newValue != null) {
          setState(() {
            _filterStatus = newValue;
            // Apply filters in memory
            _applyFiltersAndSort();
          });
        }
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
              // Header with close button
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

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              complaint['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Image if available
                      if (complaint['hasImage'])
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              complaint['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Details
                      _buildDetailItem('Category', widget.category, widget.categoryIcon),
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
                        complaint['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Share complaint functionality
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.categoryColor,
                        side: BorderSide(color: widget.categoryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Track complaint functionality
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tracking functionality coming soon!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.track_changes),
                      label: const Text('Track'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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
