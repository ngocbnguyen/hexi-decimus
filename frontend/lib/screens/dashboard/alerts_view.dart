import 'package:flutter/material.dart';
import '../../services/alert_service.dart';
import '../../services/job_service.dart';

class AlertsView extends StatefulWidget {
  final Map<String, dynamic> user;

  const AlertsView({super.key, required this.user});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allAlerts = [];
  List<Map<String, dynamic>> _filteredAlerts = [];
  List<Map<String, dynamic>> _applications = [];
  String _selectedTab = 'Upcoming';
  String _errorMessage = '';

  // Form Fields for Add Alert
  final _formKey = GlobalKey<FormState>();
  int? _selectedApplicationId;
  final _messageController = TextEditingController();
  DateTime _selectedDate = DateTime.now().plusDays(3);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadAlertsAndApps();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAlertsAndApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = widget.user['userId'] ?? 1;
      final alerts = await AlertService.fetchAlerts(userId);
      final apps = await JobService.fetchApplications(userId: userId);

      setState(() {
        _allAlerts = alerts;
        _applications = apps;
        _applyTabFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyTabFilter() {
    final now = DateTime.now();
    setState(() {
      _filteredAlerts = _allAlerts.where((alert) {
        final alertDate =
            DateTime.tryParse(alert['alertDate'] ?? '') ?? DateTime.now();
        final isSent = alert['isSent'] ?? false;
        final differenceInDays = alertDate.difference(now).inDays;

        if (_selectedTab == 'Completed') {
          return isSent;
        } else if (_selectedTab == 'Due Today') {
          return !isSent && differenceInDays == 0;
        } else if (_selectedTab == 'Overdue') {
          return !isSent && differenceInDays < 0;
        } else {
          // Upcoming
          return !isSent && differenceInDays > 0;
        }
      }).toList();
    });
  }

  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
      _applyTabFilter();
    });
  }

  void _showAddAlertSheet() {
    if (_applications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one job application before scheduling follow-ups.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _selectedApplicationId = _applications[0]['applicationId'];
    _messageController.clear();
    _selectedDate = DateTime.now().plusDays(3);
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Schedule Follow Up',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedApplicationId,
                      decoration: const InputDecoration(
                        labelText: 'Job Application',
                      ),
                      items: _applications.map((app) {
                        return DropdownMenuItem(
                          value: app['applicationId'] as int,
                          child: Text(
                            '${app['companyName']} - ${app['jobTitle']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            _selectedApplicationId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Message',
                        prefixIcon: Icon(Icons.message_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Message is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Date picker row
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Date: ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().plusDays(365),
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
                    const SizedBox(height: 8),
                    // Time picker row
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Time: ${_selectedTime.format(context)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                _selectedTime = picked;
                              });
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _submitAlert,
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitAlert() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context); // Close dialog
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = widget.user['userId'] ?? 1;
        final alertDateCombined = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final alertData = {
          'userId': userId,
          'applicationId': _selectedApplicationId,
          'alertDate': alertDateCombined.toIso8601String(),
          'message': _messageController.text.trim(),
          'isSent': false,
          'isResolved': false,
        };

        await AlertService.createAlert(alertData);
        _loadAlertsAndApps();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _deleteAlert(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await AlertService.deleteAlert(id);
      _loadAlertsAndApps();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Title banner & Quick action
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Follow Up Alerts',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddAlertSheet,
                  icon: const Icon(Icons.alarm_add, size: 20),
                  label: const Text('Add Alert'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
  
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                'Upcoming',
                'Due Today',
                'Overdue',
                'Completed',
              ].map((tabName) {
                final isSelected = _selectedTab == tabName;
                final count = _allAlerts.where((alert) {
                  final date = DateTime.tryParse(alert['alertDate'] ?? '') ?? DateTime.now();
                  final isSent = alert['isSent'] ?? false;
                  final difference = date.difference(DateTime.now()).inDays;
  
                  if (tabName == 'Completed') return isSent;
                  if (tabName == 'Due Today') return !isSent && difference == 0;
                  if (tabName == 'Overdue') return !isSent && difference < 0;
                  return !isSent && difference > 0;
                }).length;
  
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text('$tabName ($count)'),
                    selected: isSelected,
                    onSelected: (_) => _onTabSelected(tabName),
                  ),
                );
              }).toList(),
            ),
          ),
  
          // Alerts List
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
                    )
                  : _filteredAlerts.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text('No reminders in this folder.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          itemCount: _filteredAlerts.length,
                          itemBuilder: (context, index) {
                    final alert = _filteredAlerts[index];
                    final date = DateTime.tryParse(alert['alertDate'] ?? '') ?? DateTime.now();
                    final now = DateTime.now();
                    final difference = date.difference(now).inDays;

                    String daysText;
                    Color statusColor;
                    if (alert['isSent'] == true) {
                      daysText = 'Completed / Sent';
                      statusColor = Colors.grey;
                    } else if (difference < 0) {
                      daysText = 'Overdue by ${difference.abs()} days';
                      statusColor = Colors.redAccent;
                    } else if (difference == 0) {
                      daysText = 'Due Today';
                      statusColor = Colors.orange;
                    } else {
                      daysText = 'In $difference days';
                      statusColor = Colors.green;
                    }

                    // Match linked application
                    final app = _applications.firstWhere(
                      (a) => a['applicationId'] == alert['applicationId'],
                      orElse: () => <String, dynamic>{},
                    );
                    final subtitlePrefix = app.isNotEmpty
                        ? '${app['companyName']} (${app['jobTitle']}) • '
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(Icons.notifications_active_outlined, color: statusColor, size: 20),
                        ),
                        title: Text(
                          alert['message'] ?? 'Follow up reminder',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$subtitlePrefix$daysText'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _deleteAlert(alert['alertId']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime plusDays(int days) => add(Duration(days: days));
}
