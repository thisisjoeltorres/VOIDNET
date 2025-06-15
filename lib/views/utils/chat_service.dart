import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  static final String _apiKey = dotenv.env['OPENROUTER_API_KEY']!;
  static final String _apiUrl = dotenv.env['OPENROUTER_API_URL']!;

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-r1:free', // o el modelo que prefieras
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }
}