import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class DocumentService {
  static final String _baseUrl = AppConfig.documentsApiUrl;

  /// Fetches the list of uploaded documents for a specific user.
  static Future<List<Map<String, dynamic>>> fetchDocuments(int userId) async {
    final url = Uri.parse('$_baseUrl/user/$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Uploads a document to the backend using multipart file transfer.
  static Future<Map<String, dynamic>> uploadDocument({
    required int userId,
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final url = Uri.parse('$_baseUrl/upload');
    final request = http.MultipartRequest('POST', url);
    
    request.fields['userId'] = userId.toString();
    request.fields['documentType'] = documentType;
    
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Deletes a document from backend disk and database.
  static Future<void> deleteDocument(int documentId) async {
    final url = Uri.parse('$_baseUrl/$documentId');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection failed. Please verify that the backend server is running.');
    }
  }

  /// Returns the direct download URL for a document.
  static String getDownloadUrl(int documentId) {
    return '$_baseUrl/download/$documentId';
  }
}
