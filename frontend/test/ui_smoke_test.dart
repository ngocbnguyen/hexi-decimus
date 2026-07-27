import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/dashboard/dashboard_view.dart';
import 'package:frontend/screens/dashboard/applications_view.dart';
import 'package:frontend/screens/dashboard/alerts_view.dart';
import 'package:frontend/screens/dashboard/documents_view.dart';

void main() {
  final mockUser = {
    'userId': 1,
    'name': 'Ngoc',
    'email': 'student@gsu.edu'
  };

  testWidgets('DashboardView renders with mock data successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardView(
            user: mockUser,
            onNavigateToTab: (index) {},
          ),
        ),
      ),
    );

    // Verify it starts in loading state (since actual HTTP calls fail with 400 in test binding)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ApplicationsView renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApplicationsView(
            user: mockUser,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add Job'), findsOneWidget);
  });

  testWidgets('AlertsView renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertsView(
            user: mockUser,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Follow Up Alerts'), findsOneWidget);
    expect(find.text('Add Alert'), findsOneWidget);
  });

  testWidgets('DocumentsView renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentsView(
            user: mockUser,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Upload File'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });
}
