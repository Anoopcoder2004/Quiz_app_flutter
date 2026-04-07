class Question {
  final int id;
  final String question;
  final List<String> options;
  final String answer;
  final String category;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      category: json['category'],
    );
  }
}