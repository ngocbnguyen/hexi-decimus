import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AuthService {
  static final String _baseUrl = AppConfig.authApiUrl;

  /// Registers a new user.
  /// Returns the registered User data as a Map if successful.
  /// Throws an Exception containing the error message from the server on failure.
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Return raw error message from backend (e.g., "Email is already in use")
        throw Exception(response.body);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please check if the backend server is running.');
    }
  }

  /// Authenticates an existing user.
  /// Returns the logged-in User data as a Map if successful.
  /// Throws an Exception containing the error message from the server on failure.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Return raw error message from backend (e.g., "Invalid email or password")
        throw Exception(response.body);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed. Please check if the backend server is running.');
    }
  }
}
