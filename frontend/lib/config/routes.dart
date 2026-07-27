import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_shell.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String applications = '/applications';
  static const String alerts = '/alerts';
  static const String documents = '/documents';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        dashboard: (context) => const DashboardShell(currentIndex: 0),
        applications: (context) => const DashboardShell(currentIndex: 1),
        alerts: (context) => const DashboardShell(currentIndex: 2),
        documents: (context) => const DashboardShell(currentIndex: 3),
      };
}