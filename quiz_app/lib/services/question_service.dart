import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  static Future<List<Question>> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((q) => Question.fromJson(q)).toList();
  }
}