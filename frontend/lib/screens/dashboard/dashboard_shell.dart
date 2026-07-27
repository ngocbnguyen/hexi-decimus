import 'package:flutter/material.dart';
import '../../config/routes.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabInfo(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      label: 'Jobs',
      title: 'AppTracker',
      emptyStateIcon: Icons.assignment_outlined,
      emptyStateText: 'Your job applications will show up here',
    ),
    _TabInfo(
      icon: Icons.folder_open_outlined,
      selectedIcon: Icons.folder,
      label: 'Files',
      title: 'Documents',
      emptyStateIcon: Icons.folder_open_outlined,
      emptyStateText: 'Resumes and cover letters will show up here',
    ),
    _TabInfo(
      icon: Icons.notifications_none_outlined,
      selectedIcon: Icons.notifications,
      label: 'Alerts',
      title: 'Reminders',
      emptyStateIcon: Icons.notifications_none_outlined,
      emptyStateText: 'Upcoming reminders and alerts will show up here',
    ),
    _TabInfo(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      title: 'Profile & Settings',
      emptyStateIcon: Icons.person_outline,
      emptyStateText: 'Your profile and settings will show up here',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(currentTab.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _EmptyStateView(
            icon: currentTab.emptyStateIcon,
            text: currentTab.emptyStateText,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add application sheet coming soon!')),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _TabInfo {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String title;
  final IconData emptyStateIcon;
  final String emptyStateText;

  const _TabInfo({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.title,
    required this.emptyStateIcon,
    required this.emptyStateText,
  });
}

/// Shared placeholder look for tabs with no content yet, so the shell
/// doesn't show bare, inconsistently styled Text widgets per tab.
class _EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyStateView({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
