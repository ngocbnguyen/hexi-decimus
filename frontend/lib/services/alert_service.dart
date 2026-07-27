import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AlertService {
  static final String _baseUrl = AppConfig.alertsApiUrl;

  /// Fetches follow-up alerts for a specific user.
  static Future<List<Map<String, dynamic>>> fetchAlerts(int userId) async {
    final url = Uri.parse('$_baseUrl/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load alerts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Creates a new alert.
  static Future<Map<String, dynamic>> createAlert(Map<String, dynamic> data) async {
    final url = Uri.parse(_baseUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create alert: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Deletes a follow-up alert.
  static Future<void> deleteAlert(int alertId) async {
    final url = Uri.parse('$_baseUrl/$alertId');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete alert: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }
}
