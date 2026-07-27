import 'package:flutter/material.dart';
import '../../services/job_service.dart';

class ApplicationsView extends StatefulWidget {
  final Map<String, dynamic> user;

  const ApplicationsView({
    super.key,
    required this.user,
  });

  @override
  State<ApplicationsView> createState() => _ApplicationsViewState();
}

class _ApplicationsViewState extends State<ApplicationsView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allApplications = [];
  List<Map<String, dynamic>> _filteredApplications = [];
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  String _errorMessage = '';

  // Form Fields for Add
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _portalController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedStatus = 'In Progress';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadApplications();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = widget.user['userId'] ?? 1;
      final apps = await JobService.fetchApplications(userId: userId);
      setState(() {
        _allApplications = apps;
        _applyFiltersAndSearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredApplications = _allApplications.where((app) {
        final matchesFilter = _selectedFilter == 'All' || app['status'] == _selectedFilter;
        final matchesSearch = query.isEmpty ||
            (app['companyName'] ?? '').toLowerCase().contains(query) ||
            (app['jobTitle'] ?? '').toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _onFilterTabSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFiltersAndSearch();
    });
  }

  void _showAddApplicationSheet() {
    // Reset Form Fields
    _companyController.clear();
    _titleController.clear();
    _portalController.clear();
    _contactNameController.clear();
    _contactEmailController.clear();
    _notesController.clear();
    _selectedStatus = 'In Progress';
    _selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Job Application',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Company is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Job Title *',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Job title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Application Status',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: ['In Progress', 'Interview', 'Offer', 'Rejected', 'Withdrawn']
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Picker Row
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Applied On: ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portalController,
                        decoration: const InputDecoration(
                          labelText: 'Portal Link',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _submitApplication,
                            child: const Text('Save Application'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context); // Close bottom sheet
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = widget.user['userId'] ?? 1;
        final appData = {
          'userId': userId,
          'companyName': _companyController.text.trim(),
          'jobTitle': _titleController.text.trim(),
          'portalLink': _portalController.text.trim(),
          'contactName': _contactNameController.text.trim(),
          'contactEmail': _contactEmailController.text.trim(),
          'status': _selectedStatus,
          'notes': _notesController.text.trim(),
          'applicationDate': _selectedDate.toIso8601String(),
        };

        await JobService.createApplication(appData);
        _loadApplications();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _deleteApplication(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this job application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await JobService.deleteApplication(id);
        _loadApplications();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action Bar (Search & Add button)
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search applications...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddApplicationSheet,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Job'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
        ),

        // Horizontal filter tags
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              'All',
              'In Progress',
              'Interview',
              'Offer',
              'Rejected',
              'Withdrawn',
            ].map((filter) {
              final count = filter == 'All'
                  ? _allApplications.length
                  : _allApplications.where((a) => a['status'] == filter).length;
              final isSelected = _selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(
                  label: Text('$filter ($count)'),
                  selected: isSelected,
                  onSelected: (_) => _onFilterTabSelected(filter),
                ),
              );
            }).toList(),
          ),
        ),

        // Applications List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                  : _filteredApplications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_late_outlined, size: 56, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No applications found.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          itemCount: _filteredApplications.length,
                          itemBuilder: (context, index) {
                            final app = _filteredApplications[index];
                            final date = DateTime.tryParse(app['applicationDate'] ?? '') ?? DateTime.now();
                            final dateStr = '${date.month}/${date.day}/${date.year}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    (app['companyName'] ?? 'C')[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  app['companyName'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${app['jobTitle'] ?? ''} • Applied $dateStr'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatusTag(app['status'] ?? 'In Progress'),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _deleteApplication(app['applicationId']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    Color tagColor;
    Color textColor;
    switch (status) {
      case 'Offer':
        tagColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'Interview':
        tagColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 'Rejected':
        tagColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'Withdrawn':
        tagColor = Colors.grey[300]!;
        textColor = Colors.grey[800]!;
        break;
      default:
        tagColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
