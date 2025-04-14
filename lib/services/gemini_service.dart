import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  String? _apiKey; // API Key will be fetched dynamically

  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';

  GeminiService() {
    _loadApiKey();
  }

  // Load API Key from SharedPreferences
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('apiKey');
  }

  // Validate API Key by making a simple request to the Gemini API
  Future<bool> validateApiKey() async {
    if (_apiKey == null) {
      return false; // No API key set
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': 'Test API key validity'}]},
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // If the response is valid, assume the API key is valid
        return data['candidates'] != null && data['candidates'].isNotEmpty;
      }
      return false; // Invalid API key response
    } catch (e) {
      print('Error validating API key: $e');
      return false; // Error during validation
    }
  }

  // Example method to use the API key
  Future<String> getResponse(String prompt) async {
    if (_apiKey == null) {
      throw Exception('API key not found');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': prompt}]}
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
      } else {
        throw Exception('Failed to get response: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with Gemini API: $e');
    }
  }
}
