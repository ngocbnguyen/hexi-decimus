import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class JobService {
  static final String _baseUrl = AppConfig.jobsApiUrl;

  /// Fetches filtered job applications for the logged-in user.
  static Future<List<Map<String, dynamic>>> fetchApplications({
    required int userId,
    String? status,
    String? companyName,
    String? jobTitle,
  }) async {
    // Construct query parameters
    final queryParams = <String, String>{
      'userId': userId.toString(),
    };
    if (status != null && status.isNotEmpty && status != 'All') {
      queryParams['status'] = status;
    }
    if (companyName != null && companyName.isNotEmpty) {
      queryParams['companyName'] = companyName;
    }
    if (jobTitle != null && jobTitle.isNotEmpty) {
      queryParams['jobTitle'] = jobTitle;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load applications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Creates a new job application.
  static Future<Map<String, dynamic>> createApplication(Map<String, dynamic> data) async {
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
        throw Exception('Failed to create application: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Deletes a job application.
  static Future<void> deleteApplication(int applicationId) async {
    final url = Uri.parse('$_baseUrl/$applicationId');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete application: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Updates an existing job application.
  static Future<Map<String, dynamic>> updateApplication(int applicationId, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$applicationId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update application: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }
}
