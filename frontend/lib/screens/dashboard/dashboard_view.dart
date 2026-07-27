import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/alert_service.dart';

class DashboardView extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(int) onNavigateToTab;

  const DashboardView({
    super.key,
    required this.user,
    required this.onNavigateToTab,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _topAlerts = [];
  List<Map<String, dynamic>> _recentApps = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = widget.user['userId'] ?? 1;
      final apps = await JobService.fetchApplications(userId: userId);
      final alertsList = await AlertService.fetchAlerts(userId);

      // Safe alert list filtering and sorting
      final activeAlerts = alertsList.where((a) => a['isSent'] == false).toList();
      activeAlerts.sort((a, b) {
        final aDate = DateTime.tryParse(a['alertDate'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['alertDate'] ?? '') ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
      final topAlerts = activeAlerts.take(3).toList();

      // Safe applications sorting
      final sortedApps = List<Map<String, dynamic>>.from(apps);
      sortedApps.sort((a, b) {
        final aDate = DateTime.tryParse(a['applicationDate'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['applicationDate'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate); // Descending order (recent first)
      });
      final recentApps = sortedApps.take(4).toList();

      setState(() {
        _applications = apps;
        _alerts = activeAlerts;
        _topAlerts = topAlerts;
        _recentApps = recentApps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Calculations for counts
    final totalCount = _applications.length;
    final inProgressCount = _applications.where((a) => a['status'] == 'In Progress').length;
    final interviewCount = _applications.where((a) => a['status'] == 'Interview').length;
    final offerCount = _applications.where((a) => a['status'] == 'Offer').length;
    final rejectedCount = _applications.where((a) => a['status'] == 'Rejected').length;
    final withdrawnCount = _applications.where((a) => a['status'] == 'Withdrawn').length;

    final topAlerts = _topAlerts;
    final recentApps = _recentApps;
    final userName = widget.user['name'] ?? 'User';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hello header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName! 👋',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's your application overview.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDashboardData,
              )
            ],
          ),
          const SizedBox(height: 24),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context: context,
                    title: 'Total Applications',
                    value: totalCount.toString(),
                    icon: Icons.business_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'In Progress',
                    value: inProgressCount.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'Interview',
                    value: interviewCount.toString(),
                    icon: Icons.people_outline,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    context: context,
                    title: 'Offer',
                    value: offerCount.toString(),
                    icon: Icons.emoji_events_outlined,
                    color: Colors.green,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Middle row containing Ring Chart & Alerts
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildBreakdownCard(
                        inProgress: inProgressCount,
                        interview: interviewCount,
                        offer: offerCount,
                        rejected: rejectedCount,
                        withdrawn: withdrawnCount,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildUpcomingFollowups(topAlerts),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildBreakdownCard(
                      inProgress: inProgressCount,
                      interview: interviewCount,
                      offer: offerCount,
                      rejected: rejectedCount,
                      withdrawn: withdrawnCount,
                    ),
                    const SizedBox(height: 24),
                    _buildUpcomingFollowups(topAlerts),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Recent Applications
          _buildRecentApplications(recentApps),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => widget.onNavigateToTab(0),
              child: Text(
                'View all',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required int inProgress,
    required int interview,
    required int offer,
    required int rejected,
    required int withdrawn,
  }) {
    final total = inProgress + interview + offer + rejected + withdrawn;
    final inProgressPct = total == 0 ? 0.0 : (inProgress / total) * 100;
    final interviewPct = total == 0 ? 0.0 : (interview / total) * 100;
    final offerPct = total == 0 ? 0.0 : (offer / total) * 100;
    final rejectedPct = total == 0 ? 0.0 : (rejected / total) * 100;
    final withdrawnPct = total == 0 ? 0.0 : (withdrawn / total) * 100;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Status Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Custom circular representation
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: total == 0 ? 0.0 : (inProgress + interview + offer) / total,
                        strokeWidth: 16,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                      Text(
                        '$total',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Legend list
                Expanded(
                  child: Column(
                    children: [
                      _buildLegendRow('In Progress', inProgress, inProgressPct, Colors.blue),
                      _buildLegendRow('Interview', interview, interviewPct, Colors.purple),
                      _buildLegendRow('Offer', offer, offerPct, Colors.green),
                      _buildLegendRow('Rejected', rejected, rejectedPct, Colors.red),
                      _buildLegendRow('Withdrawn', withdrawn, withdrawnPct, Colors.grey),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(String title, int count, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$count (${pct.toStringAsFixed(1)}%)',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          )
        ],
      ),
    );
  }

  Widget _buildUpcomingFollowups(List<Map<String, dynamic>> alertsList) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Follow Ups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateToTab(2),
                  child: const Text('View all alerts'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alertsList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green[300], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'All caught up! No pending alerts.',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alertsList.length,
                itemBuilder: (context, index) {
                  final alert = alertsList[index];
                  final alertDate = DateTime.tryParse(alert['alertDate'] ?? '') ?? DateTime.now();
                  final now = DateTime.now();
                  final difference = alertDate.difference(now).inDays;

                  String daysText;
                  Color dateColor;
                  if (difference < 0) {
                    daysText = 'Overdue by ${difference.abs()} days';
                    dateColor = Colors.red;
                  } else if (difference == 0) {
                    daysText = 'Due Today';
                    dateColor = Colors.orange;
                  } else {
                    daysText = 'Follow up in $difference days';
                    dateColor = Colors.green;
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: dateColor.withOpacity(0.1),
                      child: Icon(Icons.notifications, color: dateColor, size: 20),
                    ),
                    title: Text(
                      alert['message'] ?? 'Follow up reminder',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      daysText,
                      style: TextStyle(color: dateColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      '${alertDate.month}/${alertDate.day}/${alertDate.year}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplications(List<Map<String, dynamic>> recentApps) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Applications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateToTab(0),
                  child: const Text('View all applications'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentApps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'No applications added yet.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 40,
                  columns: const [
                    DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Position', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Applied On', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: recentApps.map((app) {
                    final date = DateTime.tryParse(app['applicationDate'] ?? '') ?? DateTime.now();
                    final dateStr = '${date.month}/${date.day}/${date.year}';
                    return DataRow(
                      cells: [
                        DataCell(Text(app['companyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(Text(app['jobTitle'] ?? '')),
                        DataCell(_buildStatusTag(app['status'] ?? 'In Progress')),
                        DataCell(Text(dateStr)),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
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
