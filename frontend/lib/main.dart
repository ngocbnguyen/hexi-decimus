import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: SelectableText(
              '⚠️ Render Error:\n${details.exception}\n\nStack Trace:\n${details.stack}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  };
  runApp(const ApplicationTrackerApp());
}

class ApplicationTrackerApp extends StatelessWidget {
  const ApplicationTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}