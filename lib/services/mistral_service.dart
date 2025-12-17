import 'dart:convert';
import 'package:http/http.dart' as http;

class Mistral {
  // To run the app with your API key, use the following command:
  // flutter run --dart-define=MISTRAL_API_KEY=YOUR_API_KEY
  static const String _apiKey = String.fromEnvironment('MISTRAL_API_KEY');
  static const String _apiUrl = 'https://api.mistral.ai/v1/chat/completions';

  Future<String> askMistral(String question) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      'model': 'mistral-tiny',
      'messages': [
        {'role': 'user', 'content': question}
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to load response from Mistral AI: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Mistral AI: $e');
    }
  }
}
