import 'package:flutter/material.dart';
import '../../config/routes.dart';
import 'dashboard_view.dart';
import 'applications_view.dart';
import 'alerts_view.dart';
import 'documents_view.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;
  Map<String, dynamic>? _user;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_user == null) {
      _user = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) 
          ?? {'userId': 1, 'name': 'Ngoc', 'email': 'student@gsu.edu'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user!;

    Widget currentPage;
    switch (_currentIndex) {
      case 0:
        currentPage = DashboardView(
          key: const ValueKey('dashboard'),
          user: user,
          onNavigateToTab: _navigateToTab,
        );
        break;
      case 1:
        currentPage = ApplicationsView(
          key: const ValueKey('applications'),
          user: user,
        );
        break;
      case 2:
        currentPage = AlertsView(
          key: const ValueKey('alerts'),
          user: user,
        );
        break;
      case 3:
        currentPage = DocumentsView(
          key: const ValueKey('documents'),
          user: user,
        );
        break;
      default:
        currentPage = DashboardView(
          key: const ValueKey('dashboard'),
          user: user,
          onNavigateToTab: _navigateToTab,
        );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.track_changes, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'AppTracker',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'User: ${user['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: SizedBox.expand(
        child: currentPage,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Documents',
          ),
        ],
      ),
    );
  }
}
