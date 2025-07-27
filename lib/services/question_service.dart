
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:budget_tracker_flutter/models/genai_question.dart';

class QuestionService {
  static const String _endpoint = 'http://raspberrypi4.tailad9f80.ts.net:5001/run';

  static Future<GenAIResponse> askQuestion(GenAIQuestion question) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(question.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return GenAIResponse.fromJson(data);
    } else {
      throw Exception('Failed to get answer: ${response.statusCode}');
    }
  }
}